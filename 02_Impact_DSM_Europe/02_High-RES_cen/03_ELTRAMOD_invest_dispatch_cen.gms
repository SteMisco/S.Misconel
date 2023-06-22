*===============================================================================
*   Modeling investment and dispatch decisions for flexibility options,
*        especially optimization of dispatch decisions for demand-side-management,
*        for EU-27, UK, NO, CH, and Balkan countries
*   This research was funded by the European Commission as a part of
*        the collaborative project ‘REFLEX’, which was part of the European
*        Union’s Horizon 2020 research and innovation programme [GA–No.
*        691685].
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel (supported by Christoph Zöphel)
*   Last updated: 20.04.2020
*===============================================================================


*===============================================================================
*              EQUATIONS for Capacity Investments
*===============================================================================

Variables
TOTAL_COSTS              total costs [EUR]
DSM_OPT(t,c)             optimal dispatch of DSM [MWh per h]
RESDEM_OPT(t,c)          optimized residual load after DSM [MWh per h]
;

Positive Variables
G_P(t,p)                 dipatch of a power plant (exist+new) [MWh per hour]
G_P1(t,p)                dipatch of existing power plants [MWh per hour]
G_P2(t,p)                dipatch of new built power plants [MWh per hour]
CURT_RES(t,c)            curtailment of RES in a country [MWh per hour]
RES_O(t,res,c)           dispatch of other RES [MW]
DUMP_DEM(t,c)            dumping of surplus demand [MWh per hour]
Charge(t,p)              Charging of a storage plant [MWh per hour]
SL(t,p)                  storage level [MW]
EXPORT(t,c,cc)           export from one country A to B (export from A to B corresponds to import in B from A)
LC_UP(t,p)               load change up (fuel-related)[MWh]
LC_DOWN(t,p)             load change down (depreciation-related)[MWh]
C_ADD(p)                 added power plant capacity [MW]
INV(p)                   total investments in a plant excl. fixed costs [EUR]
P2X_UP                   increasing electricity demand (incl. P2X) [MW]
C_P2X                    P2X-capacity [MW]
INV_P2X                  investments in P2X [EUR]
GAS_B(t,c)               dummy variable for gas boiler as alternative for power-to-heat
P2X_UP_trans_ind         increasing electricity demand due to p2g for transport + industry sector [MWh per h]
P2X_UP_surplus           surplus p2g for hydrogen-storage [MWh per h]
;

Equations
target_function
energy_balance
dsm_balance
optimized_resload
curtailment
dispatch_other_renewables
maximum_generation
maximum_generation1
maximum_generation2
maximum_FLH
load_change_calculation
storage_level
storage_level_max
maximum_charge
investments
EXPORT_restriction
minimum_p2g
maximum_heat
maximum_p2x
investment_p2x
surplus_p2g
;

*========== Needed Parameter ===================================================

* RES feed-in and residual load
res_other(res,c)$(char_res(res,'fluc') eq 0)     = res_p(res,c)*char_res(res,'avail');
res_other(res,c)$(char_res(res,'fluc') eq 1)     = 0;
res_in(t,res,c)$(char_res(res,'fluc') eq 1)      = res_av(t,res,c);
res_in(t,res,c)$(char_res(res,'fluc') eq 0)      = 0;
res_ror(t,res,c)$(char_res(res,'fluc') eq 0.5)   = res_av(t,res,c);
res_ror(t,res,c)$(char_res(res,'fluc') eq 0)     = 0;

* residual load calculated as difference between (system load + network losses) - (feed-in of w_on, w_off, pv_rt, pv_gr)
res_dem(t,c) = dem(t,c)*(1+char_c(c,'loss')) - sum(res,res_in(t,res,c));

* maximal residual load per country
res_dem_max(c)=smax(t,res_dem(t,c));

*annuity for expansion planning
an(p)=sum(tech$map_ptech(p,tech),char_tech2(tech,'co_inv','%YEAR%')*((1+i)**char_tech(tech,'eco_life')*i)/((1+i)**char_tech(tech,'eco_life')-1));


*variable costs
co_f(t,p)      = sum(f,n_fpr(t,f,'%year%')$map_pf(p,f));
co_co2(t,p)    = n_fpr(t,'CO2','%year%') * sum(tech$map_ptech(p,tech),char_tech(tech,'co2'));

co_v1(t,exist) = sum(tech$map_ptech(exist,tech),char_tech(tech, 'co_v')) + ((co_f(t,exist) + co_co2(t,exist) * (1 - sum(tech$map_ptech(exist,tech),char_tech(tech, 'x')))) / char_p(exist, 'eta_p'));
eta_p_add(p)   = sum(tech$map_ptech(p,tech),char_tech2(tech,'eta_p','%year%'));
co_v2(t,new)$(eta_p_add(new)>0) = sum(tech$map_ptech(new,tech),char_tech(tech,'co_v')) + ((co_f(t,new) + co_co2(t,new) * (1 - sum(tech$map_ptech(new,tech),char_tech(tech, 'x')))) / eta_p_add(new));


*lines
ntc(c,cc) = ntc_input(c,cc,'%year%');


*load change costs
co_up(t,p)= sum(tech$map_ptech(p,tech),(co_f(t,p) + co_co2(t,p) * (1 - char_tech(tech, 'x'))) * char_tech(tech,'co_rf'));
co_down(p)= sum(tech$map_ptech(p,tech),char_tech(tech,'co_rcd'));


*========== Target Function ====================================================

target_function..
TOTAL_COSTS =e=   sum((t,exist), G_P1(t,exist) * co_v1(t,exist))

                + sum((t,new), G_P2(t,new) * co_v2(t,new))

                + sum((t,p_av), LC_UP(t,p_av) * co_up(t,p_av) + LC_DOWN(t,p_av) * co_down(p_av))

                + sum(p_av,INV(p_av) + (char_p(p_av,'p_inst') + C_ADD(p_av))*sum(tech$map_ptech(p_av,tech),char_tech(tech,'co_f')))

                + sum((t,c), CURT_RES(t,c) * co_curt)

                + sum((t,c), DUMP_DEM(t,c) * co_voll)

                + sum(app, INV_P2X(app) + sum(dev$map_appDev(app,dev),char_dev(dev,'co_f'))*(char_app(app,'inst') + C_P2X(app)))

                + sum((t,app), P2X_UP(t,app) * co_p2x(t,app))

                + sum((t,c), GAS_B(t,c)*(n_fpr(t,'gas','%year%')/char_dev('p2h','eta_opp')))

                + sum((t,c), DSM_OPT(t,c) * co_dsm(c,'%year%') * dsm_ac_share)
;

*========= Energy Balance ======================================================

energy_balance(t,c)..
           sum(p_av$map_pc(p_av,c), G_P(t,p_av))
         + DUMP_DEM(t,c)
         + sum(res,RES_O(t,res,c))

         =e=

           RESDEM_OPT(t,c)
         + CURT_RES(t,c)
         + sum(cc$(ntc_input(c,cc,'%year%')), EXPORT(t,c,cc))
         - sum(cc$(ntc_input(c,cc,'%year%')), EXPORT(t,cc,c))
         + sum(stor$ map_pc(stor,c), Charge(t,stor))
         + sum(app$map_appC(app,c), P2X_UP(t,app))
;

*====== DSM Dispatch ===========================================================

DSM_OPT.up(t,c) = dsm_max(t,c) * dsm_share
;
DSM_OPT.lo(t,c) = dsm_min(t,c) * dsm_share
;

dsm_balance(c)..
sum((t), DSM_OPT(t,c)) =e= 0
;

*====== Optimized System Load ==================================================

* optimized residual load by available DSM potential
optimized_resload(t,c)..
RESDEM_OPT(t,c) =e=  res_dem(t,c) - DSM_OPT(t,c)
;

*======== Investment Restrictions ==============================================

investments(new)..
INV(new) =e= C_ADD(new)*an(new)
;

C_ADD.fx(p)$(char_p(p,'p_feas')eq 0) = 0
;

*upper bound only for nuclear and coal/lignite CCS power plants
C_ADD.up(new)$((char_p(new,'p_add')eq 1)) = char_p(new,'p_new')
;

*======== Technical Constraints Power Plants ===================================

curtailment(t,c)..
CURT_RES(t,c) =l= sum(res,res_in(t,res,c))
;

dispatch_other_renewables(t,res,c)..
RES_O(t,res,c) =l= res_other(res,c) + res_ror(t,res,c)
;

maximum_generation1(t,exist)..
G_P1(t,exist) =l= char_p(exist,'p_inst') * char_p(exist,'avail')
;
G_P1.fx(t,p)$(char_p(p,'p_inst') eq 0) = 0
;

maximum_generation2(t,new)..
G_P2(t,new) =l= C_ADD(new) * char_p(new,'avail')
;
G_P2.fx(t,p)$((char_p(p,'p_feas')eq 0) and (char_p(p,'p_add')eq 0)) = 0
;

maximum_generation(t,p_av)..
G_P(t,p_av) =e=  G_P1(t,p_av) + G_P2(t,p_av)
;

load_change_calculation(t,p_av)$((char_p(p_av,'ther') > 0))..
         LC_UP(t,p_av)- LC_DOWN(t,p_av) =e= G_P(t,p_av)-G_P(t-1,p_av)
;

*======== Storages =============================================================

*reservoir maximum generation
maximum_FLH(reser)..
          sum(t,G_P(t,reser)) =l= char_p(reser,'p_inst') * char_p(reser,'Flh_Max')
;

*storage plants
storage_level(t,stor)..
         SL(t,stor) =e=  SL(t-1,stor) - G_P(t,stor) + Charge(t,stor) * eta_p_add(stor)
;

storage_level_max(t,stor)..
         SL(t,stor) =l=  (char_p(stor,'p_inst') + C_ADD(stor)) * char_p(stor,'p_stor')
;

SL.fx(t,p)$(not char_p(p,'stor'))=0
;

maximum_charge(t,stor)..
         Charge(t,stor) =l= char_p(stor,'p_inst') + C_ADD(stor)
;

Charge.fx(t,p)$(not char_p(p,'stor')) = 0
;



*======== Limitation of Load Flows =============================================

EXPORT_restriction(t,c,cc)..
EXPORT(t,c,cc) =l= ntc_input(c,cc,'%year%')
;

EXPORT.fx(t,c,cc)$(NOT ntc_input(c,cc,'%year%'))=0
;


*======== Heat and P2X =========================================================

*** chp-factor for calibrating chp generation ***
p_chp(p_av)$(char_p(p_av,'ther')eq 1) = sum((tech,c),chp_fac(tech,c)$map_pc(p_av,c)$map_ptech(p_av,tech))
;

maximum_heat(t,c)..
        sum((p2h,dev)$(map_appC(p2h,c)and map_appDev(p2h,dev)),P2X_UP(t,p2h) * char_dev2(dev,'eta','%year%')) + GAS_B(t,c)+ sum(p_av$map_pc(p_av,c), G_P(t,p_av)$(char_p(p_av,'chp')eq 1 and p_chp(p_av)>0 ))
                                                                                 =e= hp(t,c) * dem_heat(c,'%year%')
;


P2X_UP.up(t,p2h)= sum((c,dev)$(map_appC(p2h,c)and map_appDev(p2h,dev)),(hp(t,c) * dem_heat(c,'%year%'))/char_dev2(dev,'eta','%year%'))
;


*minimal electricity demand for p2g (electrolyzer) to cover the hydrogen demand from transport + industry sector (electricity demand for electrolyser for hydrogen production(dem_p2g) )= hydrogen consumption in transport + industry sector / efficiency of electrolyzer)
minimum_p2g(p2g)..
         sum(t,P2X_UP_trans_ind(t,p2g)) =e= sum((c,dev)$ (map_appC(p2g,c) and map_appDev(p2g,dev)),(dem_p2x(c,'p2g','%year%')+ dem_p2x(c,'p2g_ind','%year%'))/ char_dev2(dev,'eta','%year%'))
;
*industry hydrogen production needs to be constant in every hour
         P2X_UP_trans_ind.lo(t,p2g)= sum((c,dev)$ (map_appC(p2g,c) and map_appDev(p2g,dev)),dem_p2x(c,'p2g_ind','%year%')/char_dev2(dev,'eta','%year%'))/8760
;


*surplus of hydrogen for storage (h2 pressurized tank)
surplus_p2g(t,p2g)..
P2X_UP(t,p2g)=e= P2X_UP_trans_ind(t,p2g) + P2X_UP_surplus(t,p2g)
;

maximum_p2x(t,app)..
        P2X_UP(t,app) =l= C_P2X(app) + char_app(app,'inst')
;


*annuity for expansion planning
an_app(app)= sum(dev$map_appDev(app,dev),char_dev2(dev,'co_inv','%YEAR%')*(((1+i)**char_dev(dev,'eco_life')*i)/((1+i)**char_dev(dev,'eco_life')-1)))
;

investment_p2x(app)..
         INV_P2X(app) =e= C_P2X(app) * an_app(app)
;


*P2X-costs
co_p2x(t,p2x)=0
;

*===============================================================================
*                Solving the Model
*===============================================================================

Model ELTRAMOD / target_function
                 energy_balance
                 dsm_balance
                 optimized_resload
                 investments
                 curtailment
                 dispatch_other_renewables
                 maximum_generation1
                 maximum_generation2
                 maximum_generation
                 load_change_calculation
                 maximum_FLH
                 storage_level
                 storage_level_max
                 maximum_charge
                 EXPORT_restriction
                 minimum_p2g
                 maximum_heat
                 maximum_p2x
                 investment_p2x
                 surplus_p2g
               /
;

option lp=CPLEX;
option threads=4;
*option threads=2;
$onecho > cplex.opt
lpmethod         4
solutiontype    2
$offecho
*option SysOut = On;
ELTRAMOD.optfile = 1;
solve ELTRAMOD using lp minimizing TOTAL_COSTS;




*===============================================================================
*                  Solving Algorithms
*===============================================================================
$ontext
*lpmethod 0       automatic selection of an optimizer
*lpmethod 1       primal simplex optimizer
*lpmethod 2       dual simplex optimizer
*lpmethod 4       barrier interior point optimizer (line below -> solutiontype 2 -> turns off crossover -> small scaled solutions -> faster model runs)


*option threads=4;  use of four CPUs for one optimization problem => necessary to accelerate barrier algorithm
*option threads=2;  use of two CPUs for one optimization problem => necessary if simultaneous runs of two problems
$offtext








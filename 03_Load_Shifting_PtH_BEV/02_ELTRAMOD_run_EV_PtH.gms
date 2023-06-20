*===============================================================================
*   Modeling investment and dispatch decisions for flexibility options,
*        especially optimization of dispatch / load shifting for
*         power-to-heat and battery electric vehicles, for Germany.
*   The research was performed within the MODEX-EnSAVes
*         project supported by the Federal Ministry for Economic Affairs
*         and Energy of Germany under grant numbers FKZ BMWi
*         03ET4079A (TUD, ELTRAMOD).
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel
*   Last updated: 02.03.2021
*===============================================================================

* dispatch model for MODEX-EnSAVes project (without investments)
* fixed power plant fleet from system perspective comparison 1
* comparison of system perspective 2.2

*===============================================================================
*              EQUATIONS for Dispatch Decisions
*===============================================================================

Variables
TOTAL_COSTS              total costs [EUR]
EXPORT(t,y)              export from one country A to B (export from A to B corresponds to import in B from A)
;

Positive Variables
G_P(t,p)                 dipatch of a power plant (exist+new) [MWh per hour]
*G_P1(t,p)                dipatch of existing power plants [MWh per hour]
*G_P2(t,p)                dipatch of new built power plants [MWh per hour]
CURT_RES(t,c)            curtailment of RES in a country [MWh per hour]
DUMP_DEM(t,c)            dumping of surplus demand [MWh per hour]
Charge(t,p)              Charging of a storage plant [MWh per hour]
SL(t,p)                  storage level [MW]
LC_UP(t,p)               load change up (fuel-related)[MWh]
LC_DOWN(t,p)             load change down (depreciation-related)[MWh]
*C_ADD(p)                 added power plant capacity [MW]
*INV(p)                   total investments in a plant excl. fixed costs [EUR]
RES_O(t,res,c)           dispatch of other RES [MW]

EV_CHARGE(c,ev,t)                Electric vehicle charging profile [MWh per hour]
EV_L(c,ev,t)                     Electric vehicle storage level profile [MWh per hour]
EV_GED(c,ev,t)                   Driving profile for ev - grid electricity demand for mobility of ev [MWh per hour]

P2H_OPT(t,app)                   Increasing electricity demand by P2H [MW]
HSTOR_IN(t,app)                  Heat storage charging [MWh per hour]
HSTOR_OUT(t,app)                 Heat storage discharging [MWh per hour]
HSTOR_L(t,app)                   Heat storage level [MWh per hour]
;

Equations
target_function
energy_balance
curtailment
dispatch_other_renewables
maximum_generation
*maximum_generation1
*maximum_generation2
load_change_calculation
maximum_FLH
storage_level
storage_level_max
maximum_charge
*investments
export_restriction
;

*======== EQUATIONS FOR DSM (EV & P2H) =========================================

Equations
* Electric vehicles
ev_energy_balance                Energy balance of electric vehicles (for uncontrolled and controlled charging)
ev_chargelev_start               Cumulative charging level in the first hour (for uncontrolled charging)
ev_chargelev                     Cumulative charging level in hour h (for uncontrolled and controlled charging)
ev_chargelev_max                 Cumulative maximal charging level (for uncontrolled and controlled charging)
ev_charge_maxin                  Cumulative maximal charging power (for uncontrolled charging)
ev_chargelev_ending              Cumulative charging level in the last hour (for uncontrolled charging)
ev_charge_maxin_limit            Cumulative maximal charging limit (for uncontrolled charging)


* Power-to-heat and heat storages
heat_balance                     Heat balance
maximum_p2h                      Maximal electricity increase by p2h
hstor_chargelev_start            Cumulative charging level in the first hour
hstor_chargelev                  Cumulative charging level in hour h
hstor_chargelev_max              Cumulative maximal charging level
*hstor_chargelev_ending           Cumulative charging level in the last hour
hstor_charge_maxin_limit         Cumulative maximal charging limit
hstor_discharge_maxout_limit     Cumulative maximal discharging limit
;

*========== Needed Parameter ===================================================

* RES feed-in and residual load
res_other(t,res,c)$(char_res(res,'fluc') eq 0)   = res_p(res,c)*char_res(res,'avail');
res_other(t,res,c)$(char_res(res,'fluc') eq 1)   = 0;
res_in(t,res,c)$(char_res(res,'fluc') eq 1)      = res_av(t,res,c);
res_in(t,res,c)$(char_res(res,'fluc') eq 0)      = 0;
res_ror(t,res,c)$(char_res(res,'fluc')eq 0.5)    = res_av(t,res,c);
res_ror(t,res,c)$(char_res(res,'fluc')eq 0)      = 0;

* residual load calculated as difference between (system load + network losses) - (feed-in of w_on, w_off, pv, ror)
res_dem(t,c) = dem(t,c) - sum(res,res_in(t,res,c)) - sum(res,res_ror(t,res,c));

* maximal residual load per country
res_dem_max(c) = smax(t,res_dem(t,c));

*annuity for expansion planning
an(p) = sum(tech$map_ptech(p,tech),char_tech2(tech,'co_inv','%YEAR%')*((1+i)**char_tech(tech,'eco_life')*i)/((1+i)**char_tech(tech,'eco_life')-1));

*variable costs
co_f(t,p)      = sum(f,n_fpr(t,f,'%year%')$map_pf(p,f));
co_co2(t,p)    = n_fpr(t,'CO2','%year%') * sum(tech$map_ptech(p,tech),char_tech(tech,'co2'));

*co_v1(t,exist) = sum(tech$map_ptech(exist,tech),char_tech(tech, 'co_v')) + ((co_f(t,exist) + co_co2(t,exist) * (1 - sum(tech$map_ptech(exist,tech),char_tech(tech, 'x')))) / char_p(exist, 'eta_p'));
co_v(t,exist) = sum(tech$map_ptech(exist,tech),char_tech(tech, 'co_v')) + ((co_f(t,exist) + co_co2(t,exist) * (1 - sum(tech$map_ptech(exist,tech),char_tech(tech, 'x')))) / char_p(exist, 'eta_p'));
eta_p_add(p)   = sum(tech$map_ptech(p,tech),char_tech2(tech,'eta_p','%year%'));
*co_v2(t,new)$(eta_p_add(new)>0) = sum(tech$map_ptech(new,tech),char_tech(tech,'co_v')) + ((co_f(t,new) + co_co2(t,new) * (1 - sum(tech$map_ptech(new,tech),char_tech(tech, 'x')))) / eta_p_add(new));

*load change costs
co_up(t,p)= sum(tech$map_ptech(p,tech),(co_f(t,p) + co_co2(t,p) * (1 - char_tech(tech, 'x'))) * char_tech(tech,'co_rf'));
co_down(p)= sum(tech$map_ptech(p,tech),char_tech(tech,'co_rcd'));


*========== Target Function ====================================================

target_function..
TOTAL_COSTS =e=   sum((t,exist), G_P(t,exist) * co_v(t,exist))

*                + sum((t,exist), G_P1(t,exist) * co_v1(t,exist))

*                + sum((t,new), G_P2(t,new) * co_v2(t,new))

                + sum((t,exist), LC_UP(t,exist) * co_up(t,exist) + LC_DOWN(t,exist) * co_down(exist))

*                + sum((t,p_av), LC_UP(t,p_av) * co_up(t,p_av) + LC_DOWN(t,p_av) * co_down(p_av))

*                + sum(p_av,INV(p_av) + ((char_p(p_av,'p_inst') + C_ADD(p_av)) * sum(tech$map_ptech(p_av,tech),char_tech(tech,'co_f'))))

                + sum((t,c), CURT_RES(t,c) * co_curt )

                + sum((t,c), DUMP_DEM(t,c) * co_voll )

;

*========= Energy Balance ======================================================

energy_balance(t,c)..
           sum(p_av$map_pc(p_av,c), G_P(t,p_av))
         + DUMP_DEM(t,c)
         + sum(res,res_other(t,res,c))

         =e=

           res_dem(t,c)
         + CURT_RES(t,c)
         + sum(y$(exch(t,'%year%')), EXPORT(t,y))
         + sum(stor$ map_pc(stor,c), Charge(t,stor))
         + sum(map_n_ev(c,ev), EV_CHARGE(c,ev,t))
         + sum(app$map_appC(app,c), P2H_OPT(t,app))
;

*======== Investment Restrictions ==============================================
$ontext
investments(new)..
INV(new) =e= C_ADD(new)*an(new)
;

C_ADD.fx(p)$((char_p(p,'p_feas')eq 0) and (char_p(p,'p_add')eq 0)) = 0
;

*upper bound only for storages
C_ADD.up(new)$((char_p(new,'p_add')eq 1)) = char_p(new,'p_new')
;
$offtext

*======== Technical Constraints Power Plants ===================================

curtailment(t,c)..
CURT_RES(t,c) =l= sum(res,res_in(t,res,c))
;

dispatch_other_renewables(t,res,c)..
RES_O(t,res,c) =e= res_other(t,res,c) + res_ror(t,res,c)
;

$ontext
maximum_generation1(t,exist)..
G_P1(t,exist) =l= char_p(exist,'p_inst') * sum(tech$map_ptech(exist,tech),av(t,tech))
;
G_P1.fx(t,p)$(char_p(p,'p_inst') eq 0) = 0
;


maximum_generation2(t,new)..
G_P2(t,new) =l= C_ADD(new) * sum(tech$map_ptech(new,tech),av(t,tech))
;
G_P2.fx(t,p)$((char_p(p,'p_feas')eq 0) and (char_p(p,'p_add')eq 0)) = 0
;


maximum_generation(t,p_av)..
G_P(t,p_av) =e=  G_P1(t,p_av) + G_P2(t,p_av)
;
$offtext


maximum_generation(t,exist)..
G_P(t,exist) =l= char_p(exist,'p_inst') * sum(tech$map_ptech(exist,tech),av(t,tech))
;
G_P.fx(t,p)$(char_p(p,'p_inst') eq 0) = 0
;


load_change_calculation(t,p_av)$((char_p(p_av,'ther')eq 1))..
         LC_UP(t,p_av)- LC_DOWN(t,p_av) =e= G_P(t,p_av) - G_P(t-1,p_av)
;


*reservoir maximum generation
maximum_FLH(reser)..
          sum(t,G_P(t,reser)) =l= char_p(reser,'p_inst')* char_p(reser,'Flh_Max')
;


*======== Storages =============================================================

*storage plants
storage_level(t,stor)..
         SL(t,stor) =e=  SL(t-1,stor) - G_P(t,stor) + Charge(t,stor) * eta_p_add(stor)
;

storage_level_max(t,stor)..
         SL(t,stor) =l=  char_p(stor,'p_inst') * char_p(stor,'p_stor')
*         SL(t,stor) =l=  (char_p(stor,'p_inst') + C_ADD(stor)) * char_p(stor,'p_stor')
;

SL.fx(t,p)$(NOT char_p(p,'stor'))=0
;

maximum_charge(t,stor)..
         Charge(t,stor) =l= char_p(stor,'p_inst')
*         Charge(t,stor) =l= char_p(stor,'p_inst')+ C_ADD(stor)
;

Charge.fx(t,p)$(NOT char_p(p,'stor')) = 0
;


*======== Limitation of Load Flows =============================================

*exogenous given hourly load flows for DE and neighbouring countries (here: net-exports of DE implemented)
export_restriction(t,y)..
EXPORT(t,y) =e= exch(t,'%year%')
;

EXPORT.fx(t,y)$(NOT exch(t,'%year%')) = 0
;

*====== EV =====================================================================

$include 04_EV.gms

*====== PtH ====================================================================

$include 05_PtH.gms

*===============================================================================
*                Solving the Model
*===============================================================================

Model ELTRAMOD / target_function
                 energy_balance
*                 investments
                 curtailment
                 dispatch_other_renewables
*                 maximum_generation1
*                 maximum_generation2
                 maximum_generation
                 load_change_calculation
                 maximum_FLH
                 storage_level
                 storage_level_max
                 maximum_charge
                 export_restriction

*$ontext
                 ev_energy_balance
                 ev_chargelev_start
                 ev_chargelev
                 ev_chargelev_max
                 ev_charge_maxin
                 ev_chargelev_ending
                 ev_charge_maxin_limit
*$offtext

*$ontext
                 heat_balance
                 maximum_p2h
                 hstor_chargelev_start
                 hstor_chargelev
                 hstor_chargelev_max
*                 hstor_chargelev_ending
                 hstor_charge_maxin_limit
                 hstor_discharge_maxout_limit
*$offtext
               /
;


option lp=CPLEX;
*option threads=4;
option threads=2;
$onecho > cplex.opt
lpmethod 2
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
*lpmethod 4       barrier interior point optimizer (line below -> solutiontype 2)


*option threads=4;  use of four CPUs for one optimization problem
*option threads=2;  use of two CPUs for one optimization problem => necessary if simultaneous runs of two problems
$offtext





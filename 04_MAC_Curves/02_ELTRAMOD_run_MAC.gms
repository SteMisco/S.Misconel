*===============================================================================
*   Modeling dispatch decisions for flexibility options with an integrated
*         multi-iterative capacity expansion algorithm to determine marginal
*         CO2 abatement cost curves for Germany from 2030 to 2045.
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel (supported by Hannes Hobbie, Matteo Giacomo Prina)
*   Last updated: 01.12.2022
*===============================================================================


*===============================================================================
*              EQUATIONS for Dispatch Decisions
*===============================================================================

Variables
TC                               Total costs [EUR]
EXPORT(t,y)                      Export from one country A to B (export from A to B corresponds to import in B from A)
;

Positive Variables
G_P(t,p)                         Dipatch of a power plant (exist+new) [MWh per hour]
CURT_RES(t,*)                    Curtailment of RES in a country [MWh per hour]
DUMP_DEM(t,c)                    Dumping of surplus demand [MWh per hour]
Charge(t,p)                      Charging of a storage plant [MWh per hour]
SL(t,p)                          Storage level [MW]
LC_UP(t,p)                       Load change up (fuel-related)[MWh]
LC_DOWN(t,p)                     Load change down (depreciation-related)[MWh]
RES_O(t,p)                       Dispatch of other RES [MW]
VRES_IN(t,p)                     Dispatch of volatile RES [MW]
GAS_B(t)

EV_CHARGE(c,ev,t)                Electric vehicle charging profile [MWh per hour]
EV_DISCHARGE(c,ev,t)
EV_L(c,ev,t)                     Electric vehicle storage level profile [MWh per hour]
EV_GED(c,ev,t)                   Driving profile for ev - grid electricity demand for mobility of ev [MWh per hour]

P2H_OPT(t,app)                   Increasing electricity demand by P2H [MW]
HSTOR_IN(t,app)                  Heat storage charging [MWh per hour]
HSTOR_OUT(t,app)                 Heat storage discharging [MWh per hour]
HSTOR_L(t,app)                   Heat storage level [MWh per hour]
GP_CHP(t,p)

P2G_OPT(t,dev)                   Increasing electricity demand by optimized P2G [MW]
H2STOR_IN(t,dev)                 H2 storage charging [MWh per hour]
H2STOR_OUT(t,dev)                H2 storage discharging [MWh per hour]
H2STOR_L(t,dev)                  H2 storage level [MWh per hour]
;

Equations
target_function
energy_balance
curtailment
dispatch_other_renewables
dispatch_volatile_renewables
maximum_generation
load_change_calculation
maximum_FLH
storage_level_start
storage_level
storage_level_max
maximum_charge
storage_level_end
export_restriction

*======== EQUATIONS FOR DSM (EV & P2H) =========================================
*$ontext
Equations
* Electric vehicles
ev_energy_balance                Energy balance of electric vehicles (for uncontrolled and controlled charging)
ev_chargelev_start               Cumulative charging level in the first hour (for uncontrolled charging)
ev_chargelev                     Cumulative charging level in hour h (for uncontrolled and controlled charging)
ev_chargelev_max                 Cumulative maximal charging level (for uncontrolled and controlled charging)
ev_charge_maxin                  Cumulative maximal charging power (for uncontrolled charging)
ev_chargelev_ending              Cumulative charging level in the last hour (for uncontrolled charging)
ev_charge_maxin_level            Cumulative maximal charging limit (for uncontrolled charging)
ev_discharge_maxout
ev_discharge_maxout_level
*$offtext

* Power-to-heat and heat storages
heat_balance                     Heat balance
maximum_p2h                      Maximal electricity increase by p2h
maximum_p2h_flh
hstor_chargelev_start            Cumulative charging level in the first hour
hstor_chargelev                  Cumulative charging level in hour h
hstor_chargelev_max              Cumulative maximal charging level
hstor_charge_maxin_level         Cumulative maximal charging limit
hstor_charge_maxin
hstor_discharge_maxout_level     Cumulative maximal discharging limit
hstor_charge_maxout
hstor_chargelev_ending
chp_must_run
maximum_gasboiler

* Power-to-gas and h2 storages
h2_balance                       H2 balance
maximum_p2g                      Maximum electricity increase by p2g
h2stor_chargelev_start           Cumulative charging level in the first hour
h2stor_chargelev                 Cumulative charging level in hour h
h2stor_chargelev_max             Cumulative maximal charging level
h2stor_charge_maxin
h2stor_charge_maxin_level        Cumulative maximal charging limit
h2stor_charge_maxout
h2stor_discharge_maxout_level    Cumulative maximal discharging limit
h2stor_chargelev_ending
;

*========== Needed Parameter ===================================================
$ontext
inc('fo1','DE_pv_gr')      = 0 ;
inc('fo2','DE_pv_rt')      = 0 ;
inc('fo3','DE_w_on')       = 0 ;
inc('fo4','DE_w_off')      = 0 ;

inc('fo5','DE_battery_LI') = 0 ;
inc('fo6','DE_battery_RF') = 0 ;
*$ontext
p2p_inc('fo7','p2g')       = 0 ;
p2p_inc('fo7','h2stor')    = 0 ;
p2p_inc('fo7','fc')        = 0 ;
*$offtext
p2h_inc('fo8','p2h')       = 0 ;
p2h_inc('fo8','hstor')     = 0 ;
*$ontext
ev_inc('fo9','ev_fleet')   = 0 ;
ev_inc('fo9','ev_private') = 0 ;

*inc('fo10','DE_A-CAES')    = 0 ;
$offtext

*$ontext
inc('fo1','DE_pv_gr')      = 1549.165903 ;
inc('fo2','DE_pv_rt')      = 1549.165903 ;
inc('fo3','DE_w_on')       = 581.6022672 ;
inc('fo4','DE_w_off')      = 418.1181662 ;
inc('fo5','DE_battery_LI') = 1000 ;
inc('fo6','DE_battery_RF') = 1000 ;
*$offtext
p2p_inc('fo7','p2g')       = 914.9435042

 ;
p2p_inc('fo7','h2stor')    = 914.9435042

;
p2p_inc('fo7','fc')        = 914.9435042

 ;

*$ontext
p2h_inc('fo8','p2h')       = 320.9943805 ;
p2h_inc('fo8','hstor')     = 320.9943805 ;
*$offtext
*$ontext
ev_inc('fo9','ev_fleet')   = 64771.88693 ;
ev_inc('fo9','ev_private') = 58797.59886 ;

*inc('fo10','DE_A-CAES')    = 1000 ;

*$offtext

*annuity for expansion planning
an(p)         = (sum(tech$map_ptech(p,tech),char_tech2(tech,'co_inv','%year%')*((1+i)**char_tech(tech,'eco_life')*i)/((1+i)**char_tech(tech,'eco_life')-1)) / 8760) * t_opt;
an_dev(dev)   = ((char_dev(dev,'p2p_co_inv','%YEAR%') * ((1+i)**char_dev(dev,'p2p_eco_life','%YEAR%')*i)/((1+i)**char_dev(dev,'p2p_eco_life','%YEAR%')-1))  / 8760) * t_opt;
an_app(app)   = ((char_app(app,'p2h_co_inv','%YEAR%') * ((1+i)**char_app(app,'p2h_eco_life','%YEAR%')*i)/((1+i)**char_app(app,'p2h_eco_life','%YEAR%')-1))  / 8760) * t_opt;
*an_ev         = (sum((c,ev), ev_data(c,ev,'ev_co_inv') * ((1+i)**ev_data(c,ev,'ev_eco_life')*i)/((1+i)**ev_data(c,ev,'ev_eco_life')-1))  / 8760) * t_opt;

cap_max(p)  =  char_p(p,'p_new');
p2p_max(dev)=  char_dev(dev,'p2p_pot','%YEAR%');
p2h_max(app)=  char_app(app,'p2h_pot','%YEAR%');
ev_max(c,ev)=  ev_data(c,ev,'ev_pot');

* RES feed-in
res_other(t,tech,c)$ sum(res$ map_ptech(res,tech),char_p(res,'fluc') eq 0)   = sum(res$(map_ptech(res,tech) and map_pc(res,c)),char_p(res,'p_inst')*char_p(res,'avail'));

*residual demand (without network losses)
*res_dem(t,c)     = dem(t,c)*(1+char_c(c,'loss')) - sum(tech,res_in(t,tech,c)) - sum(tech,res_ror(t,tech,c));
*res_dem(t,c)     = dem(t,c) - sum(tech,res_in(t,tech,c)) - sum(tech,res_ror(t,tech,c));
*res_dem_max(c)   = smax(t,res_dem(t,c));

*variable costs
co_f(t,p)     = sum(f,n_fpr(t,f,'%year%')$map_pf(p,f));
co_co2(t,p)   = n_fpr(t,'CO2','%year%') * sum(tech$map_ptech(p,tech),char_tech(tech,'co2'));

co_v(t,exist) = sum(tech$map_ptech(exist,tech),char_tech(tech, 'co_v')) + ((co_f(t,exist) + co_co2(t,exist) * (1 - sum(tech$map_ptech(exist,tech),char_tech(tech, 'x')))) / char_p(exist, 'eta_p'));
eta_p_add(p)  = sum(tech$map_ptech(p,tech),char_tech2(tech,'eta_p','%year%'));

*load change costs
co_up(t,p)    = sum(tech$map_ptech(p,tech),(co_f(t,p) + co_co2(t,p) * (1 - char_tech(tech, 'x'))) * char_tech(tech,'co_rf'));
co_down(p)    = sum(tech$map_ptech(p,tech),char_tech(tech,'co_rcd'));

*========== Target Function ====================================================

*total system costs
target_function..
TC        =e=     sum((t,p_av), G_P(t,p_av) * co_v(t,p_av))

                + sum((t,p_av), LC_UP(t,p_av) * co_up(t,p_av) + LC_DOWN(t,p_av) * co_down(p_av))

                + sum(p_av, cost(p_av))

                + sum((t,c), CURT_RES(t,c) * co_curt)

                + sum((t,c), DUMP_DEM(t,c) * co_voll)

                + sum(dev, p2p_cost(dev))

                + sum(app, p2h_cost(app))

                + sum(t, GAS_B(t) * (n_fpr(t,'gas','%year%') / char_app('p2h','eta_opp','%year%')))

                + sum((c,ev), ev_cost_new(c,ev))

;

*========= Energy Balance ======================================================

energy_balance(t,c)..
           sum(p_av$map_pc(p_av,c), G_P(t,p_av))
         + DUMP_DEM(t,c)
         + sum(ores$map_pc(ores,c), RES_O(t,ores))
         + sum(vres$map_pc(vres,c), VRES_IN(t,vres))
*         + GP_FC(t)
         + sum(h2stor, H2STOR_OUT(t,h2stor)) / 0.4789
         + sum(map_n_ev(c,ev), EV_DISCHARGE(c,ev,t))

         =e=

           dem(t,c)
         + CURT_RES(t,c)
         + sum(y$(exch(t,'%year%')), EXPORT(t,y))
         + sum(stor$ map_pc(stor,c), Charge(t,stor))
*         + P2G_TRANS(t)
         + sum(p2g$map_devC(p2g,c), P2G_OPT(t,p2g))
         + sum(p2h$map_appC(p2h,c), P2H_OPT(t,p2h))
         + sum(map_n_ev(c,ev), EV_CHARGE(c,ev,t))
;

*======== Technical Constraints Power Plants ===================================

dispatch_other_renewables(t,ores)..
RES_O(t,ores) =e= sum((tech,c)$(map_ptech(ores,tech) and map_pc(ores,c)), res_other(t,tech,c))
;

*volatile RES
dispatch_volatile_renewables(t,vres)..
VRES_IN(t,vres)  =e= cap_new(vres) * sum((tech,c)$(map_ptech(vres,tech) and map_pc(vres,c)), res_av(t,tech,c))
;

curtailment(t,c)$(sum(vres$map_pc(vres,c), char_p(vres,'fluc')eq 1))..
CURT_RES(t,c) =l= sum((vres,tech)$ map_ptech(vres,tech),cap_new(vres)* res_av(t,tech,c))
;

maximum_generation(t,p_av)..
G_P(t,p_av) =l= cap_new(p_av) * sum(tech$map_ptech(p_av,tech),av(t,tech))
;
G_P.fx(t,p)$((char_p(p,'p_inst') eq 0) and char_p(p,'stor')eq 0) = 0
;

load_change_calculation(t,p_av)$((char_p(p_av,'ther')eq 1))..
         LC_UP(t,p_av)- LC_DOWN(t,p_av) =e= G_P(t,p_av) - G_P(t-1,p_av)
;

*reservoir maximum generation
maximum_FLH(reser)..
          sum(t,G_P(t,reser)) =l= ((char_p(reser,'p_inst')* char_p(reser,'Flh_Max')) / 8760) * t_opt
;

*======== Storages =============================================================
*storage start level
storage_level_start(t,stor)$(ord(t) = 1)..
         SL(t,stor) =e=  0.5 * cap_new(stor) * char_p(stor,'p_stor') - G_P(t,stor) + Charge(t,stor) * eta_p_add(stor)
;

*storage plants
storage_level(t,stor)$(ord(t) > 1)..
         SL(t,stor) =e=  SL(t-1,stor) - G_P(t,stor) + Charge(t,stor) * eta_p_add(stor)
;

storage_level_max(t,stor)..
         SL(t,stor) =l=  cap_new(stor) * char_p(stor,'p_stor')
;

SL.fx(t,p)$(NOT char_p(p,'stor'))=0
;

maximum_charge(t,stor)..
         Charge(t,stor) =l= cap_new(stor)
;

Charge.fx(t,p)$(NOT char_p(p,'stor')) = 0
;

*storage end level
storage_level_end(t,stor)$ (ord(t) = card(t))..
         SL(t,stor) =e=  0.5 * cap_new(stor) * char_p(stor,'p_stor')
;

*======== Limitation of Load Flows =============================================

*exogenous given hourly load flows for DE and neighbouring countries (here: net-exports of DE implemented)
export_restriction(t,y)..
EXPORT(t,y) =e= exch(t,'%year%')
;

EXPORT.fx(t,y)$(NOT exch(t,'%year%')) = 0
;

*====== EV =====================================================================

$include 04_EV_MAC.gms

*====== PtH ====================================================================

$include 05_PtH_MAC.gms

*====== PtG ====================================================================

$include 06_PtG_MAC.gms

*===============================================================================
*                Solving the Model
*===============================================================================

Model ELTRAMOD / target_function
                 energy_balance
                 curtailment
                 dispatch_other_renewables
                 dispatch_volatile_renewables
                 maximum_generation
                 load_change_calculation
                 maximum_FLH
                 storage_level_start
                 storage_level
                 storage_level_max
                 maximum_charge
                 storage_level_end
                 export_restriction

*$ontext
                 ev_energy_balance
                 ev_chargelev_start
                 ev_chargelev
                 ev_chargelev_max
                 ev_charge_maxin
                 ev_chargelev_ending
                 ev_charge_maxin_level
                 ev_discharge_maxout
                 ev_discharge_maxout_level
*$offtext

*$ontext
                 heat_balance
                 maximum_p2h
                 maximum_p2h_flh
                 hstor_chargelev_start
                 hstor_chargelev
                 hstor_chargelev_max
                 hstor_charge_maxin_level
                 hstor_charge_maxin
                 hstor_discharge_maxout_level
                 hstor_charge_maxout
                 chp_must_run
                 maximum_gasboiler
*$offtext

*$ontext
                 h2_balance
                 maximum_p2g
                 h2stor_chargelev_start
                 h2stor_chargelev
                 h2stor_chargelev_max
                 h2stor_charge_maxin
                 h2stor_charge_maxin_level
                 h2stor_charge_maxout
                 h2stor_discharge_maxout_level
                 h2stor_chargelev_ending

*$offtext
               /
;

*===============================================================================
*                             LOOP STATEMENT
*===============================================================================

parameter
limit(fo)
result(it,fo,*)
result_best(it,*)
results_best_gen(it,tech,*)
results_best_res(it,*)
results_best_tc(it,tech,*)
results_best_cap(it,tech,*)
results_best_flh(it,tech,*)
results_best_f_use(it,tech,*)
results_best_co2(it,tech,*)
results_best_curt(it,*)
results_best_lcoe(it,tech,*)
results_best_stor(it,tech,*)
results_best_ptx(it,*)

results_best_co2_trans(it,car,*)
results_best_co2_gasb(it,*)
results_best_co2_chp(it,tech,*)

results_best_tc_trans(it,*)
results_best_tc_p2p(it,dev,*)
results_best_tc_p2h(it,app,*)
results_best_tc_gasb(it,*)
results_best_tc_dump(it,*)
results_best_tc_chp(it,tech,*)
;

limit(fo) = 0;

set map_fop(fo,p);
map_fop('fo1','DE_pv_gr') = 1;
map_fop('fo2','DE_pv_rt') = 1;
map_fop('fo3','DE_w_on') = 1;
map_fop('fo4','DE_w_off') = 1;
map_fop('fo5','DE_battery_LI') = 1;
map_fop('fo6','DE_battery_RF') = 1;
*map_fop('fo10','DE_A-CAES') = 1;

set map_fodev(fo,dev);
map_fodev('fo7',dev) = 1;

set map_foapp(fo,app);
map_foapp('fo8',app) = 1;

set map_foev(fo,ev);
map_foev('fo9',ev) = 1;

set p2(p);
p2('DE_pv_gr') = yes;
p2('DE_pv_rt') = yes;
p2('DE_w_on') = yes;
p2('DE_w_off') = yes;
p2('DE_battery_LI') = yes;
p2('DE_battery_RF') = yes;
*p2('DE_A-CAES') = yes;

set dev2(dev);
dev2(dev) = yes;

set app2(app);
app2(app) = yes;

set ev2(ev);
ev2(ev) = yes;
*ev2('ev_fleet') = yes;
*ev2('ev_private') = yes;

co2_em_best = co2_em_ref;
cca_best = cca_ref;
an_prev_fo(p) = 0;
an_prev_dev(dev) = 0;
an_prev_app(app) = 0;
ev_prev_cost(c,ev) = 0;

file results / results.gdx /;
put results


loop(it,


    loop(fo $ (limit(fo)=0),

                 cap_new(p) = char_p(p,'p_inst')+ inc(fo,p);
                 an_new(p) = inc(fo,p) * an(p) + an_prev_fo(p);
                 cost(p)   = an_new(p) + (((cap_new(p) * sum(tech$map_ptech(p,tech),char_tech(tech,'co_f')))/8760) * t_opt);

                 p2p_new(dev)    = char_dev(dev,'p2p_inst','%YEAR%') + p2p_inc(fo,dev);
                 an_dev_new(dev) = p2p_inc(fo,dev) * an_dev(dev) +  an_prev_dev(dev);
                 p2p_cost(dev)   = an_dev_new(dev) + (((p2p_new(dev) * char_dev(dev,'p2p_co_f','%YEAR%'))/8760) * t_opt);
                 h2_demand(t,p2g)= char_dev('p2g','p2p_cap_fac','%YEAR%') * p2p_new('p2g') * char_dev('p2g','p2p_eta','%YEAR%');

                 p2h_new(app)    = char_app(app,'p2h_inst','%YEAR%') + p2h_inc(fo,app);
                 an_app_new(app) = p2h_inc(fo,app) * an_app(app) +  an_prev_app(app);
                 p2h_cost(app)   = an_app_new(app) + (((p2h_new(app) * char_app(app,'p2h_co_f','%YEAR%'))/8760) * t_opt);

                 ev_new(c,ev)     = ev_data(c,ev,'ev_quant') + ev_inc(fo,ev);
                 ev_cost_new(c,ev)= ev_inc(fo,ev) * ev_data(c,ev,'ev_co') + ev_prev_cost(c,ev);
                 ev_add           = sum(ev,ev_inc(fo,ev));

                 if ((ev_add > 0),
                      car_new(c,car)      = transport_data(c,car,'car_quant') + transport_data(c,car,'car_factor') * ev_add;
                      co2_em_trans(c,car) = car_new(c,car) * transport_data(c,car,'co2em_inc');

                 elseif (ev_add <= 0),
                      car_new(c,car)      = transport_data(c,car,'car_quant') ;
                      co2_em_trans(c,car) = car_new(c,car) * transport_data(c,car,'co2em_inc');
                 );

                 solve ELTRAMOD using LP minimizing TC;

                 pr_el(t,c)            = energy_balance.m(t,c);
                 pr_el_av              = sum((t,c),pr_el(t,c))/card(t);

                 res_dem(t,c)          = dem(t,c) - sum(vres, VRES_IN.l(t,vres));
                 res_dem_max           = smax((t,c),res_dem(t,c))/10**3;
                 dem_max               = smax((t,c),dem(t,c))/10**3;

                 gen(y,t,tech)         = sum(p$ map_ptech(p,tech), G_P.l(t,p));
                 gen_res(y,t,tech)     = sum(p$ map_ptech(p,tech), VRES_IN.l(t,p) + RES_O.l(t,p));
                 gen_vres(y,t,tech)    = sum(p$ map_ptech(p,tech), VRES_IN.l(t,p));
                 f_use(y,tech)$((sum(p$map_ptech(p,tech),char_p(p,'ther') > 0))and(sum((p,t)$map_ptech(p,tech),G_P.l(t,p)>0))) = sum(t,gen(y,t,tech))/char_tech2(tech,'eta_p','%year%');
                 f_use_gasboiler       = sum(t,GAS_B.l(t))/0.95;

                 co2_em_tech(y,tech)   = f_use(y,tech)*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x')));
                 co2_em_gasboiler      = (sum(t,GAS_B.l(t))/0.95) * char_tech('CCGT','co2');
*already included in total co2 emissions from conventional power plants
                 co2_em_chp(tech)      = (sum((p_av,t)$map_ptech(p_av,tech),GP_CHP.l(t,p_av))/char_tech2(tech,'eta_p','%year%'))*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x')));
                 co2_em_dh             = sum(tech,co2_em_chp(tech)) + co2_em_gasboiler;
                 curt(t,c)             = CURT_RES.l(t,c);
                 stor_charge(t,stor)   = Charge.l(t,stor);
                 stor_discharge(t,stor)= G_P.l(t,stor);
                 gen_fc(t,h2stor)      = H2STOR_OUT.l(t,h2stor) / sum(fc$map_h2storFC(h2stor,fc),char_dev('fc','p2p_eta','%YEAR%'));

                 if ((sum(p2h,p2h_new(p2h))>0),
                          flh_pth(p2h)       = sum(t, P2H_OPT.l(t,p2h)) / p2h_new(p2h);
                 );

                 if ((sum(p2g,p2p_new(p2g))>0),
                          flh_ptg(p2g)    = sum(t, P2G_OPT.l(t,p2g)) / p2p_new(p2g);
                 );

*co2_em_tech includes co2_el + co2_chp + co2_trans
*                 co2_em_total          = sum((y,tech), co2_em_tech(y,tech)) + sum((c,car), co2_em_trans(c,car));
                 co2_em_total          = sum((y,tech), co2_em_tech(y,tech)) + co2_em_gasboiler + sum((c,car), co2_em_trans(c,car));
*                + (co2_import * 10**6);
                 co2_red               = co2_em_total - co2_em_ref;
                 co2_red_cum           = co2_em_total -   254970657.12556115 ;

                 if ((co2_red < 0),
                 tc_delta              = TC.l - tc_ref;
                 cca                   = (TC.l - tc_ref) / (co2_em_ref - co2_em_total);

                 elseif (co2_red >= 0),
                 cca                   = 0;
                 );

                 result(it,fo,'cca')          = cca;
                 result(it,fo,'co2_em_total') = co2_em_total;
                 result(it,fo,'co2_red')      = co2_red;
                 result(it,fo,'co2_red_cum')  = co2_red_cum;
                 result(it,fo,'tc')           = TC.l;
                 result(it,fo,'tc_delta')     = tc_delta;
                 result(it,fo,'curt')         = sum((t,c),curt(t,c));

                 result(it,fo,'pv_gr_cap')    = cap_new('DE_pv_gr');
                 result(it,fo,'pv_rt_cap')    = cap_new('DE_pv_rt');
                 result(it,fo,'won_cap')      = cap_new('DE_w_on');
                 result(it,fo,'woff_cap')     = cap_new('DE_w_off');
                 result(it,fo,'battery_LI')   = cap_new('DE_battery_LI');
                 result(it,fo,'battery_RF')   = cap_new('DE_battery_RF');
*                 result(it,fo,'A-CAES')       = cap_new('DE_A-CAES');

                 result(it,fo,'p2g')          = p2p_new('p2g');
                 result(it,fo,'h2stor')       = p2p_new('h2stor');
                 result(it,fo,'fc')           = p2p_new('fc');

                 result(it,fo,'p2h')          = p2h_new('p2h');
                 result(it,fo,'hstor')        = p2h_new('hstor');

                 result(it,fo,'ev')           = sum((c,ev),ev_new(c,ev));

                         if (((co2_red < 0)
                             and (cca < cca_best)

                            ),

                             co2_em_best      = co2_em_total;
                             co2_red_best     = co2_red;
                             co2_red_cum_best = co2_red_cum;
                             cca_best         = cca;
                             cap_best(p)      = char_p(p,'p_inst') + inc(fo,p);
                             tc_best          = TC.l;
                             an_best(p)       = inc(fo,p) * an(p) + an_prev_fo(p);

                             an_dev_best(dev) = p2p_inc(fo,dev) * an_dev(dev) + an_prev_dev(dev);
                             p2p_best(dev)    = char_dev(dev,'p2p_inst','%YEAR%') + p2p_inc(fo,dev);

                             an_app_best(app) = p2h_inc(fo,app) * an_app(app) + an_prev_app(app);
                             p2h_best(app)    = char_app(app,'p2h_inst','%YEAR%') + p2h_inc(fo,app);

                             ev_cost_best(c,ev)= ev_inc(fo,ev) * ev_data(c,ev,'ev_co') + ev_prev_cost(c,ev);
                             ev_best(c,ev)     = ev_data(c,ev,'ev_quant') + ev_inc(fo,ev);
                             car_best(c,car)   = car_new(c,car);

                             gen_best(y,t,tech)      = gen(y,t,tech);
                             gen_best_year(tech)     = sum((y,t), gen(y,t,tech));
                             gen_res_best(y,t,tech)  = gen_res(y,t,tech);
                             gen_res_best_year(tech) = sum((y,t), gen_res(y,t,tech));
                             gen_vres_best(y,t,tech) = gen_vres(y,t,tech);
                             cost_best(p)            = cost(p);
                             p2p_cost_best(dev)      = p2p_cost(dev);
                             p2h_cost_best(app)      = p2h_cost(app);

                             lc_best(p_av)           = sum(t, (LC_UP.l(t,p_av) * co_up(t,p_av) + LC_DOWN.l(t,p_av) * co_down(p_av)));
                             pr_el_av_best           = pr_el_av;

                             flh_plant_best(tech)$((gen_best_year(tech)>0) and (sum(p$map_ptech(p,tech), cap_best(p))>0)) = gen_best_year(tech)/sum(p$map_ptech(p,tech), cap_best(p));
                             flh_res_best(tech)$(sum(p$map_ptech(p,tech), cap_best(p))>0) = gen_res_best_year(tech)/(sum(p$map_ptech(p,tech),cap_best(p)));
                             flh_chp(tech)$(sum(p$map_ptech(p,tech), char_p(p,'chp')=1 and cap_best(p)>0)) = sum((t,p)$map_ptech(p,tech), GP_CHP.l(t,p) / cap_best(p));

                             f_use_best(tech)         = sum(y, f_use(y,tech));
                             co2_best(tech)           = sum(y, co2_em_tech(y,tech));
                             curt_best                = sum((t,c), curt(t,c));
                             stor_charge_best(stor)   = sum(t, stor_charge(t,stor));
                             stor_discharge_best(stor)= sum(t, stor_discharge(t,stor));

                             gen_fc_best              = sum((t,h2stor), gen_fc(t,h2stor));
                             ptg_best                 = sum((t,dev),P2G_OPT.l(t,dev));
                             h2stor_in_best           = sum((t,dev),H2STOR_IN.l(t,dev));
                             pth_best                 = sum((t,app),P2H_OPT.l(t,app));
                             hstor_in_best            = sum((t,app),HSTOR_IN.l(t,app));
                             hstor_out_best           = sum((t,app),HSTOR_OUT.l(t,app));
                             gasboiler_best           = sum(t, GAS_B.l(t));
                             gasboiler_best_hourly(t) = GAS_B.l(t);
                             chp_best                 = sum((t,p),GP_CHP.l(t,p));
                             chp_best_hourly(t,p)     = GP_CHP.l(t,p);
                             dump_dem_best            = sum((t,c),DUMP_DEM.l(t,c));
                             ev_charge_best           = sum((c,ev,t),EV_CHARGE.l(c,ev,t));
                             ev_discharge_best        = sum((c,ev,t),EV_DISCHARGE.l(c,ev,t));
                             dump_dem_best            = sum((t,c),DUMP_DEM.l(t,c));
                             co2_gasboiler_best       = co2_em_gasboiler;
                             co2_trans_best(car)      = sum(c, co2_em_trans(c,car));
                             co2_chp_best(tech)       = co2_em_chp(tech);

                             lcoe_p_best(tech)$(sum((y,t),gen_best(y,t,tech))>0)
                                                     = (sum((y,t), gen_best(y,t,tech)* sum(p$map_ptech(p,tech),co_v(t,p)))
                                                     + sum(p$map_ptech(p,tech), lc_best(p))
                                                     + sum(p$map_ptech(p,tech), cost_best(p)))
                                                     / sum((y,t), gen_best(y,t,tech));

                             lcoe_res_best(tech)$(sum((y,t),gen_res_best(y,t,tech))>0)
                                                     = (sum((y,t), gen_res_best(y,t,tech) * sum(p$map_ptech(p,tech),co_v(t,p)))
                                                     + sum(p$map_ptech(p,tech), cost_best(p)))
                                                     / sum((y,t), gen_res_best(y,t,tech));
                            );

                             result_best(it,'pv_gr')      = cap_best('DE_pv_gr');
                             result_best(it,'pv_rt')      = cap_best('DE_pv_rt');
                             result_best(it,'w_on')       = cap_best('DE_w_on');
                             result_best(it,'w_off')      = cap_best('DE_w_off');
                             result_best(it,'battery_LI') = cap_best('DE_battery_LI');
                             result_best(it,'battery_RF') = cap_best('DE_battery_RF');
*                             result_best(it,'A-CAES')     = cap_best('DE_A-CAES');
                             result_best(it,'p2g')        = p2p_best('p2g');
                             result_best(it,'h2stor')     = p2p_best('h2stor');
                             result_best(it,'fc')         = p2p_best('fc');
                             result_best(it,'hstor')      = p2h_best('hstor');
                             result_best(it,'p2h')        = p2h_best('p2h');
                             result_best(it,'ev')         = sum((c,ev), ev_best(c,ev));

                             result_best(it,'cca_best')    = cca_best;
                             result_best(it,'tc_best')     = tc_best;
                             result_best(it,'co2_red')     = co2_red_best;
                             result_best(it,'co2_red_cum') = co2_red_cum_best;
                             result_best(it,'co2_em_best') = co2_em_best;
                             result_best(it,'pr_el_av')    = pr_el_av_best;
                             result_best(it,'curt')        = curt_best;


                             results_best_tc(it,tech,'tc')        = (sum((y,t,p_av)$ map_ptech(p_av,tech), gen_best(y,t,tech) * co_v(t,p_av))
                                                                  + sum(p_av $ map_ptech(p_av,tech), lc_best(p_av) + cost_best(p_av)));

                             results_best_tc_trans(it,'tc_charging_stations') = sum((c,ev),ev_cost_best(c,ev));
                             results_best_tc_p2p(it,dev,'tc_p2p')             = p2p_cost_best(dev);
                             results_best_tc_p2h(it,app,'tc_p2h')             = p2h_cost_best(app);
                             results_best_tc_gasb(it,'tc_gasb')               = sum(t, gasboiler_best_hourly(t) * n_fpr(t,'gas','%year%')) / char_app('p2h','eta_opp','%year%');
                             results_best_tc_dump(it,'dump_dem')              = dump_dem_best * co_voll;
$ontext
                             results_best_tc_chp(it,tech,'tc_chp')$(sum((t,p)$map_ptech(p,tech), chp_best_hourly(t,p) >0))
                                                                              = sum((t,p) $ map_ptech(p,tech), chp_best_hourly(t,p) * co_v(t,p))
                                                                              + sum(p $ map_ptech(p,tech), lc_best(p) + cost_best(p)));
$offtext
                             results_best_cap(it,tech,'cap')      = sum(p$map_ptech(p,tech), cap_best(p));
                             results_best_flh(it,tech,'flh')      = flh_plant_best(tech) + flh_res_best(tech);
                             results_best_f_use(it,tech,'f_use')  = f_use_best(tech);
                             results_best_co2(it,tech,'co2_em')   = co2_best(tech);
                             results_best_curt(it,'curt')         = curt_best;
                             results_best_lcoe(it,tech,'lcoe')    = lcoe_p_best(tech) + lcoe_res_best(tech);
                             results_best_stor(it,tech,'stor_charge')       = sum(stor$map_ptech(stor,tech), stor_charge_best(stor));
                             results_best_stor(it,tech,'stor_discharge')    = sum(stor$map_ptech(stor,tech), stor_discharge_best(stor));

                             results_best_ptx(it,'fc_gen')          = gen_fc_best;
                             results_best_ptx(it,'ptg')             = ptg_best;
                             results_best_ptx(it,'h2stor_charge')   = h2stor_in_best;
                             results_best_ptx(it,'pth')             = pth_best;
                             results_best_ptx(it,'hstor_charge')    = hstor_in_best;
                             results_best_ptx(it,'hstor_discharge') = hstor_out_best;
                             results_best_ptx(it,'gas_boiler')      = gasboiler_best;
                             results_best_ptx(it,'chp')             = chp_best;
                             results_best_ptx(it,'ev_charge')       = ev_charge_best;
                             results_best_ptx(it,'ev_discharge')    = ev_discharge_best;
                             results_best_ptx(it,'dump_dem')        = dump_dem_best;

                             results_best_gen(it,tech,'gen_best')    = sum((y,t), gen_best(y,t,tech) + gen_res_best(y,t,tech));
                             results_best_res(it,'res_share')        = sum((y,t,tech), gen_res_best(y,t,tech))/ (sum((t,c),dem(t,c))- sum(c,char_c(c,'%YEAR%')) + ptg_best + pth_best + ev_charge_best);
                             results_best_res(it,'res_share_wcurt')  = (sum((y,t,tech), gen_res_best(y,t,tech)) - curt_best)/ (sum((t,c),dem(t,c))- sum(c,char_c(c,'%YEAR%'))+ ptg_best + pth_best + ev_charge_best);
                             results_best_res(it,'vres_share')       = sum((y,t,tech), gen_vres_best(y,t,tech))/ (sum((t,c),dem(t,c))- sum(c,char_c(c,'%YEAR%'))+ ptg_best + pth_best + ev_charge_best);
                             results_best_res(it,'vres_share_wcurt') = (sum((y,t,tech), gen_vres_best(y,t,tech)) - curt_best)/ (sum((t,c),dem(t,c))- sum(c,char_c(c,'%YEAR%'))+ ptg_best + pth_best + ev_charge_best);


                             results_best_co2_trans(it,car,'co2_trans')   = co2_trans_best(car);
                             results_best_co2_gasb(it,'co2_gasboiler')    = co2_gasboiler_best;
                             results_best_co2_chp(it,tech,'co2_chp')      = co2_chp_best(tech);

                             put_utility 'gdxOut' / 'output','_',it.tl:0,'/results','_',it.tl:0,'_',fo.tl:0,'_y2030';
                             execute_unload ;
            );


                                 loop(p2,
                                     if((cap_best(p2) + sum(fo$map_fop(fo,p2), inc(fo,p2))) >= cap_max(p2),
                                     limit(fo)$(map_fop(fo,p2)) = 1;
                                     );
                                 );

                                 loop(dev2,
*                                     if(p2p_best(dev2) >= p2p_max(dev2),
                                     if((p2p_best(dev2) + sum(fo$map_fodev(fo,dev2), p2p_inc(fo,dev2))) >= p2p_max(dev2),
                                     limit(fo)$(map_fodev(fo,dev2)) = 1;
                                     );
                                 );

                                 loop(app2,
*                                     if(p2h_best(app2) >= p2h_max(app2),
                                     if((p2h_best(app2) + sum(fo$map_foapp(fo,app2), p2h_inc(fo,app2))) >= p2h_max(app2),
                                     limit(fo)$(map_foapp(fo,app2)) = 1;
                                     );
                                 );

                                 loop(ev2,
*                                     if(sum(c,ev_best(c,ev2)) >= sum(c,ev_max(c,ev2)),
                                     if((sum(c,ev_best(c,ev2)) + sum(fo$map_foev(fo,ev2), ev_inc(fo,ev2))) >= sum(c,ev_max(c,ev2)),
                                     limit(fo)$(map_foev(fo,ev2)) = 1;
                                     );
                                 );

                                 break $ ( sum(fo, limit(fo) = 9)) 1;

                                 char_p(p,'p_inst')                = cap_best(p);
                                 char_dev(dev,'p2p_inst','%YEAR%') = p2p_best(dev);
                                 char_app(app,'p2h_inst','%YEAR%') = p2h_best(app);
                                 ev_data(c,ev,'ev_quant')          = ev_best(c,ev);
                                 transport_data(c,car,'car_quant') = car_best(c,car);

                                 co2_em_ref = co2_em_best;
                                 tc_ref     = tc_best;

                                 an_prev_fo(p)      = an_best(p);
                                 an_prev_dev(dev)   = an_dev_best(dev);
                                 an_prev_app(app)   = an_app_best(app);
                                 ev_prev_cost(c,ev) = ev_cost_best(c,ev);

                                 cca_best = 100000;

    );


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





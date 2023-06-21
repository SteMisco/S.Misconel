*===============================================================================
*   Modeling investment and dispatch decisions for flexibility options for
*        EU-27, UK, NO, CH, and Balkan countries
*   This research was funded by the European Commission as a part of
*        the collaborative project ‘REFLEX’, which was part of the European
*        Union’s Horizon 2020 research and innovation programme [GA–No.
*        691685].
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel (supported by Christoph Zöphel)
*   Last updated: 12.11.2019
*===============================================================================



*===============================================================================
*                RESULTS ELTRAMOD INVEST-DISPATCH
*===============================================================================
parameter
cap_add                  added capacity per country [in MWel]
cap_new                  added + installed capacity per country (new power plant portfolio) [in MWel]
cap_exist(y,tech,c)      capacity of existing plants [MW]
cap_dsm_exist(y,c,dev)   capacity of existing dsm-applications [MW] (p2g and p2h)
gen(t,tech,c)          hourly generation of power plants and storages [MWh per hour]

ratio_capp_add           ratio of added to total capacity per technology and country
eta_new(c,tech)          average eta of power plant portfolio considering larger values of added plants and lower values of existing plants

cap_p2x(c,dev)           added DSM capacity per country [in MWel]
cap_dsm_new(c,dev)       added + installed DSM capacity per country [MW]

pr_el(t,c)               hourly electricity price per country [EUR per MWhel]
pr_el_av(c)              yearly average electricity price per country [EUR per MWhel]

f_use(y,tech,c)          fuel consumption per technology and country [MWhth]
co2_em(y,tech,c)         co2 emissions per technology and country [tCO2]
spec_co2_em(tech,c)      specific co2 emissions [tCO2 per MWhel]
flh_plant(tech,c)        full load hours of power plants [hours per year]

p2g_use(app,c)           used electricity of p2g per country [MWhel]
pr_el_p2g(app,c)         average electricity price for p2g per country [EUR per MWhel]
flh(app,c)               full load hours of power-to-gas [h]
;

cap_add(c,tech) = sum(p$(map_pc(p,c) and map_ptech(p,tech)), C_ADD.l(p));
cap_new(c,tech) = sum(p$(map_pc(p,c) and map_ptech(p,tech)), char_p(p,'p_inst')) + cap_add(c,tech);

cap_exist(y,tech,c)    = sum(p$(map_ptech(p,tech) and map_pc(p,c)), char_p(p,'p_inst'));
cap_dsm_exist(y,c,dev) = sum(app$(map_appC(app,c) and map_appDev(app,dev)), char_app(app,'inst'));
gen(t,tech,c)        = sum(p$(map_ptech(p,tech) and map_pc(p,c)),G_P.l(t,p));

ratio_capp_add(c,tech)$(cap_new(c,tech)>0)= cap_add(c,tech) / cap_new(c,tech);
eta_new(c,tech) = ratio_capp_add(c,tech) * char_tech2(tech,'eta_p','%year%') + (1-ratio_capp_add(c,tech)) * sum(p$(map_ptech(p,tech) and map_pc(p,c)),char_p(p, 'eta_p'));

cap_p2x(c,dev)       = sum(app$(map_appC(app,c) and map_appDev(app,dev)), C_P2X.l(app));
cap_dsm_new(c,dev)   = sum(app$(map_appC(app,c) and map_appDev(app,dev)),  char_app(app,'inst')) + cap_p2x(c,dev);

pr_el(t,c)  = energy_balance.m(t,c);
pr_el_av(c) = sum(t,pr_el(t,c))/card(t);

f_use(y,tech,c)$eta_new(c,tech) = sum(t,(gen(t,tech,c)/eta_new(c,tech)));
co2_em(y,tech,c)                = f_use(y,tech,c)*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x')));
flh_plant(tech,c)$(sum(p$(map_ptech(p,tech) and map_pc(p,c)), char_p(p,'p_inst'))>0) = sum((p,t)$(map_ptech(p,tech) and map_pc(p,c)),G_P.l(t,p)) /  cap_new(c,tech);
spec_co2_em(tech,c)$(sum((p,t)$(map_ptech(p,tech) and map_pc(p,c)),G_P.l(t,p))>0)    = sum(y,(f_use(y,tech,c)*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x'))))) / sum((p,t)$(map_ptech(p,tech) and map_pc(p,c)),G_P.l(t,p));

p2g_use(p2g,c) = sum(t,DSM_UP_trans_ind.l(t,p2g)$map_appC(p2g,c));
pr_el_p2g(p2g,c)$(p2g_use(p2g,c)>0) = sum(t,pr_el(t,c) * DSM_UP_trans_ind.l(t,p2g)$map_appC(p2g,c)) / p2g_use(p2g,c);
flh(p2g,c)$(p2g_use(p2g,c)>0)= p2g_use(p2g,c) /(C_P2X.l(p2g)+char_app(p2g,'inst')$map_appC(p2g,c));

*crossover of barrier algorithm switched off (solutionstype 2)
cap_add(c,tech)$(sum(p$(map_pc(p,c) and map_ptech(p,tech)), C_ADD.l(p) < 5.0))            =       0;
cap_p2x(c,dev)$(sum(app$(map_appC(app,c) and map_appDev(app,dev)), C_P2X.l(app) < 5.0))   =       0;
cap_new(c,tech)$(sum(p$(map_pc(p,c) and map_ptech(p,tech)), (char_p(p,'p_inst') + cap_add(c,tech)) < 5.0)) = 0;
cap_dsm_new(c,dev)$(sum(app$(map_appC(app,c) and map_appDev(app,dev)),  (char_app(app,'inst') + cap_p2x(c,dev)) < 5.0)) = 0;

execute_unload "%resultfile1%.gdx" ;
execute_unload "%resultfile2%.gdx" cap_new, cap_add, C_ADD.l, eta_new, C_P2X.l, cap_p2x, cap_dsm_new;

*===============================================================================
*               Output Excel
*===============================================================================
$ontext
execute 'gdxxrw.exe %resultfile%.gdx O=%resultfile%.xlsm SQ=N EPSOut=0 par=pr_el_av rng=el_pr!a3';
$offtext

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
*                RESULTS ELTRAMOD INVEST AND DISPATCH
*===============================================================================
Parameter
*cap_add(p)                added capacity per country [in MWel]
cap_new(p)                existing power plants (installed - decomm.) plus total added capacities of previous and recent year [in MWel]
cap_exist(y,p)            capacity of existing plants [MW]
gen(y,t,tech)             hourly generation of power plants and storages [MWh per hour]

f_use(y,tech)             fuel consumption per technology and country [MWhth]
co2_em(y,tech)            CO2 emissions per technology and country [tCO2]
spec_co2_em(tech)         specific CO2 emissions [tCO2 per MWhel]
flh_plant(tech)           full load hours of power plants [hours per year]

pr_el(t,c)                hourly electricity price per country [EUR per MWhel]
pr_el_av(y,c)             yearly average electricity price per country [EUR per MWhel]
;

*cap_add(p)           =  C_ADD.l(p);
*cap_new(p)           =  char_p(p,'p_inst') + cap_add(p);
cap_exist(y,p)       =  char_p(p,'p_inst');

gen(y,t,tech)        = sum(p$ map_ptech(p,tech),G_P.l(t,p));

f_use(y,tech)        =  sum(t,(gen(y,t,tech)))/char_tech2(tech,'eta_p','%year%');
co2_em(y,tech)       =  f_use(y,tech)*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x')));

flh_plant(tech)$(sum(p$ map_ptech(p,tech), char_p(p,'p_inst'))>0)   =  sum((p,t)$ map_ptech(p,tech),G_P.l(t,p)) /  sum(p$ map_ptech(p,tech), cap_new(p));
spec_co2_em(tech)$(sum((p,t)$ map_ptech(p,tech),G_P.l(t,p))>0)      =  sum(y,(f_use(y,tech)*(char_tech(tech,'co2')*(1 - char_tech(tech, 'x'))))) / sum((p,t)$ map_ptech(p,tech), G_P.l(t,p));

pr_el(t,c)       = energy_balance.m(t,c);
pr_el_av(y,c)    = sum(t,pr_el(t,c))/card(t);


*execute_unload "%resultfile1%.gdx" cap_new, cap_add, C_ADD.l;
execute_unload "%resultfile2%.gdx";

*===============================================================================
*                                Output Excel
*===============================================================================
$ontext
execute 'gdxxrw.exe %resultfile%.gdx O=%resultfile%.xlsm SQ=N EPSOut=0 par=pr_el rng=el_pr!a7';
$offtext

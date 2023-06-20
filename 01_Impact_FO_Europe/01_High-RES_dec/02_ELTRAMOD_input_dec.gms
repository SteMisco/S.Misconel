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
*   Last updated: 12.12.2019
*===============================================================================

*===============================================================================
*                INPUT FILE ELTRAMOD INVEST DISPATCH
*===============================================================================

Set
t                        modelling hours /t%From% * t%To%/
y                        modelling years /%Year%/
*t                        modelling hours /t1*t100/
*y                        modelling years /y2020/
ch_p                     list of power plant characteristics (directly read from excel)
ch_c                     list of country specific characteristics (directly read from excel)
ch_f                     list of fuel charactristics
ch_res                   list of res technology characteristics
p                        list of power plants (directly read from excel)
f                        list of fuels
c                        country
li                       line (connection between two countries)
tech                     technology (only conventional)
res                      renewable technologies

map_ptech(p,tech)        map plant to technology
map_pc(p,c)              map plant to country
map_pf(p,f)              map plant to fuel

*======== DSM ==================================================================
app                      flexible application for DSM
dev                      flexible device for DSM
ch_app                   list of application characteristics
ch_dev                   list of device characteristics
ch_tech                  list of technology characteristics

map_appC(app,c)          map application to country
map_appDev(app,dev)      map application to device

p2x(app)                 power-to-X-technologies (flexible application for DSM)
p2h(app)                 power-to-heat (heat pumps to cover distrcit heat demand)
;

alias
(c,cc)
(t,tt)
(f,ff)
;

set
p_av(p)                  available power plants (either for dispatch or for expansion)
exist(p)                 existing power plants
new(p)                   new (added) power plants
conv(p)                  conventional power plants
stor(p)                  energy storage plants
psp(p)                   pumped storage plants
reser(p)                 reservoir plants
first(t)                 first time step (relevant for storage level of pump storage plants)
last(t)                  last time step (relevant for storage level of pump storage plants)
;

scalar
co_voll                  value of lost load for DUMP_DEM [EUR per MWh]           / 800 /
co_dumpgen               price for dumping surplus generation [EUR per MWh]      / 300 /
co_curt                  costs for RES curtailment [EUR per MWh]                 / 0 /
i                        interest rate                                           / 0.07 /
;


Parameters
t_opt                    optimisation period [h]
*========= Prices ==============================================================
pr_f(f,y)                fuel prices [EUR per MWhth] and CO2-prices [EUR per tCO2]
n_fpr(t,f,y)             hourly fuel price time series [EUR per MWhth] and CO2 price time series [EUR per tCO2] for considered year

*========= Costs ===============================================================
an                       annuity [EUR]
co_curt                  cost for curtailment of renewables [EUR per MWh]
co_f(t,p)                cost for fuel (fuel price + mark up + transport costs) [EUR per MWhth]
co_co2(t,p)              cost for CO2 (CO2-allowances * emission factor) [EUR per MWhth]
co_v1(t,p)               variable cost for existing plants [EUR per MWhel]
co_v2(t,p)               variable cost for new plants [EUR per MWhel]

co_up(t,p)               cost for ramping up (fuel related) [MWhth per MW]
co_down(p)               cost for ramping down power plant (depreciation) [EUR per MWel]

*========= Load and Reserve ====================================================
char_c(c,ch_c)           country specific characteristics
dem(t,c)                 system load [MWh per hour]
hp(t,c)                  district heat demand in % of annual district heat demand [MWhth] -> scaled district heat demand profil
dem_heat(c,y)            district heat demand [MWhth per year]

res_dem(t,c)             residual load (system load - feed-in of RES including wind onshore + wind offshore + pv) [MWh per hour]
res_dem_max              maximum of residual load [MWh per hour]

*======== Power Plants =========================================================
char_p(p,ch_p)           all characteristics of a plant
char_tech(tech,ch_tech)  characteristics categorized by technology
char_tech2(tech,ch_p,y)  characteristics categorized by technology and changing per year
avail(c,tech,t)          hourly availability factor of technology tech in country c [-]

eta_p_add(p)             power plant efficiency of new plants [-]
eta_new(c,tech)          average eta of power plant portfolio considering larger values of added plants and lower values of existing plants [-]

cap_new(c,tech)          power plant portfolio including installed and added capacity [MW]
cap_add(c,tech)          added power plant capacity [MW]
cap_p2x(c,dev)           added DSM capacity per country [in MWel]
p_dec(p,y)               decommissioned power plant capacities [MW]
cap_dsm_new(c,dev)       added + installed DSM capacity per country including p2g and p2h [MW]
char_chp(c,tech,y)       lower bound for installed chp-capacities per country and fuel [MW]

*======= RES ===================================================================
char_res                 all characteristics of RES technologies
res_p(res,c)             installed capacity of RES plants per country [MW]
res_av(t,res,c)          feed-in profiles from intermittent RES technologies per country and timestep [MWh]
res_in(t,res,c)          feed-in of intermittent RES technologies (wind onshore + wind offshore + pv rooftop + pv ground mounted) per country and timestep [MWh]
res_other(res,c)         feed-in of non intermittent RES technologies (biomass + other RES) [MWh]
res_ror(t,res,c)         feed-in of run-of-river technologies per country and timestep [MWh]

*======== NTC & Load Flows =====================================================
ntc_input(c,cc,y)        net transfer capacity between country A and country B for all years [MW]
ntc(c,cc)                net transfer capacity between country A and country B [MW]

*======== DSM ==================================================================
char_app(app,ch_app)     application characteristics
char_dev(dev,ch_dev)     device characteristics
char_dev2(dev,ch_dev,y)  year-dependent application characteristics
dem_p2x(c,dev,y)         need of district heating [MWhth] and electricity demand of electrolyser for hydrogen production (minimum demand for P2G)[MWhel]

dem_p2h(app)             need of district heating (maximum demand for P2H) [MWhel]

p2x_max(t,app)           maximum load increase of P2X technologies [MW]
p2x_exist(app)           p2x-capacity from previous time steps [MW]

an_app                   annuity of DSM applications [EUR]
co_p2x(t,app)            activation costs for P2X application (=Dispatch)[EUR per MWhel]

co_dsm_opp(t,dev)        cost for opportunity fuel (relevant for load increase like p2g or p2h)[EUR]
co_dsm(t,app)            costs for activating DSM application (=Dispatch)[EUR]
;

Positive Variable
C_P2X                    capacity of P2X technologies (provided by ELTRMAOD_INVEST) [MW]
;

t_opt = card(t)
;
*============ Unload data to GDX File ==========================================

$onecho >temp1.tmp
set=p            rng=Plants!A4           rdim=1  cdim=0
set=tech         rng=technologies!A4     rdim=1  cdim=0
set=ch_p         rng=Plants!A3           rdim=0  cdim=1
set=ch_tech      rng=Technologies!A3     rdim=0  cdim=1
set=c            rng=countries!A4        rdim=1  cdim=0
set=ch_c         rng=countries!A3        rdim=0  cdim=1
set=f            rng=Fuel!B3             rdim=1  cdim=0
set=map_pf       rng=Plants!BK3          rdim=2  cdim=0
set=map_pc       rng=Plants!BM3          rdim=2  cdim=0
set=map_ptech    rng=Plants!BI3          rdim=2  cdim=0

par=pr_f         rng=Fuel!B3             rdim=1  cdim=1
par=n_fpr        rng=Fuel_timeseries!A5  rdim=1  cdim=2
par=char_p       rng=Plants!A3           rdim=1  cdim=1
par=char_c       rng=Countries!A3        rdim=1  cdim=1
par=char_tech    rng=Technologies!A3     rdim=1  cdim=1
par=char_tech2   rng=Tech2!A3            rdim=1  cdim=2
par=p_dec        rng=plants_dec!A3       rdim=1  cdim=1
par=char_chp     rng=CHP!A3              rdim=1  cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %data%.xlsm O=%data%.gdx SQ=N SE=10 cmerge=1 @temp1.tmp"
$gdxin  %data%.gdx
$load p tech ch_p c ch_c ch_tech f map_pf map_pc map_ptech
$load pr_f n_fpr char_p char_c char_tech char_tech2 char_chp p_dec
$gdxin
$offUNDF


$onecho >temp2.tmp
par=dem          rng=Demand!A1           rdim=1  cdim=1
par=hp           rng=Heat_Profile!A1     rdim=1  cdim=1
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %datatime%.xlsx O=%datatime%.gdx SQ=N SE=10 cmerge=1 @temp2.tmp"
$gdxin %datatime%.gdx
$load dem hp
$gdxin
$offUNDF

$onecho >temp3.tmp
par=ntc_input    rng=ntc!A3              rdim=2  cdim=1
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataNTC%.xlsx O=%dataNTC%.gdx SQ=N SE=10 cmerge=1 @temp3.tmp"
$gdxin %dataNTC%.gdx
$load  ntc_input
$gdxin
$offUNDF


$onecho >temp4.tmp
set=ch_res       rng=tech!B3              rdim=0  cdim=1
set=res          rng=tech!B3              rdim=1  cdim=0

par=char_res     rng=tech!B3              rdim=1  cdim=1
par=res_p        rng=p_inst!A3            rdim=1  cdim=1
par=res_av       rng=profile!A1           rdim=1  cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataRES%.xlsx O=%dataRES%.gdx SQ=N SE=10 cmerge=1 @temp4.tmp"
$gdxin %dataRES%.gdx
$load  ch_res res
$load  char_res res_p res_av
$gdxin
$offUNDF

$onecho >temp5.tmp
set=app          rng=app!A5              rdim=1  cdim=0
set=dev          rng=char!A5             rdim=1  cdim=0
set=ch_app       rng=app!A4              rdim=0  cdim=1
set=ch_dev       rng=char!A4             rdim=0  cdim=1
set=map_appDev   rng=app!I5              rdim=2  cdim=0
set=map_appC     rng=app!K5              rdim=2  cdim=0

par=dem_p2x      rng=P2X!A2              rdim=1  cdim=2
par=char_app     rng=app!A4              rdim=1  cdim=1
par=char_dev     rng=char!A4             rdim=1  cdim=1
par=char_dev2    rng=char_2!A3           rdim=1  cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataP2X%.xlsx O=%dataP2X%.gdx SQ=N SE=10 cmerge=1 @temp5.tmp"
$gdxin %dataP2X%.gdx
$load    app dev  ch_app ch_dev map_appDev map_appC
$load    dem_p2x char_app char_dev char_dev2
$gdxin
$offUNDF

*=========== Implementing Parameter from ELTRAMOD-INVEST =======================

char_p(p,'p_inst')=char_p(p,'p_inst')- p_dec(p,'%year%');

$ifThen set prevYear

$onUNDF
$gdxin %dataCnew%.gdx
$load    eta_new cap_add cap_new cap_p2x cap_dsm_new
$gdxin
$offUNDF

char_p(p,'p_add')$(char_p(p,'p_add')>0) = char_p(p,'p_add')- sum((c,tech)$(map_pc(p,c) and map_ptech(p,tech)),cap_add(c,tech));
char_p(p,'p_inst')= sum((c,tech)$(map_pc(p,c) and map_ptech(p,tech)),cap_new(c,tech))- p_dec(p,'%year%');
char_p(p,'p_inst')$(sum((c,tech)$(map_pc(p,c) and map_ptech(p,tech)),cap_new(c,tech))< p_dec(p,'%year%'))= 0;
char_p(p,'eta_p') = sum((c,tech)$(map_pc(p,c) and map_ptech(p,tech)),eta_new(c,tech));

char_app(app,'inst')= sum((c,dev)$(map_appC(app,c) and map_appDev(app,dev)), cap_dsm_new(c,dev));

$endIf

*============ Subsets ==========================================================
p_av(p)     = YES$(char_p(p,'p_inst') or char_p(p,'p_feas')= 1);
exist(p)    = YES$char_p(p,'p_inst');
new(p)      = YES$(char_p(p,'p_feas')= 1);
stor(p)     = YES$char_p(p,'stor');
psp(p)      = YES$map_ptech(p,'psp');
reser(p)    = YES$map_ptech(p,'reservoir');
p2x(app)    = YES$(map_appDev(app,'p2g') or map_appDev(app,'p2h'));
p2h(app)    = YES$map_appDev(app,'p2h');
first(t)    = YES$(ord(t) = 1);
last(t)     = YES$(ord(t) = card(t));










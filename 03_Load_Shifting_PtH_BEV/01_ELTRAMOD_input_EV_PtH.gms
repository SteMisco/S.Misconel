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
*                INPUT FILE ELTRAMOD DISPATCH
*===============================================================================

Set
t                        modelling hours /t%FROM% * t%TO%/
y                        modelling years /%YEAR%/
*t                        modelling hours /t1 * t1000/
*y                        modelling years /y2020/
ch_p                     list of power plant characteristics (directly read from excel)
ch_c                     list of country specific characteristics (directly read from excel)
ch_tech                  list of technology characteristics
ch_f                     list of fuel characteristics
ch_res                   list of res technology characteristics
p                        list of power plants (directly read from excel)
f                        list of fuels
c                        country
li                       line (connection between two countries)
tech                     technology (only conventional)
res                      renewable technologies
hp                       heat profile region

map_ptech(p,tech)        map plant to technology
map_pc(p,c)              map plant to country
map_pf(p,f)              map plant to fuel
char_exch                list of load flow exchange characteristics (auxiliary set for net-exports DE)
;

Alias
(c,cc)
(t,tt)
(f,ff)
;

Set
p_av(p)                  available power plants (either for dispatch or for expansion)
exist(p)                 existing power plants
new(p)                   new (added) power plants
stor(p)                  energy storage plants
psp(p)                   pumped storage plants
reser(p)                 reservoir plants
first(t)                 first time step (relevant for storage level of pump storage plants)
last(t)                  last time step (relevant for storage level of pump storage plants)
;

Scalar
co_voll                  value of lost load for DUMP_DEM [EUR per MWh]           / 800 /
co_curt                  costs for RES curtailment [EUR per MWh]                 / 50 /
i                        interest rate                                           / 0.09 /
p2h_eta_opp              opportunity efficiency of power-to-heat (for gas boiler)/ 0.90 /
;

Parameters
t_opt                    optimisation period [h]

*========= Prices ==============================================================
pr_f(f,y)                fuel price [EUR per MWhth] and CO2 price [EUR per tCO2]
n_fpr(t,f,y)             fuel price time series and CO2 price time series for considered year

*========= Costs ===============================================================
an                       annuity [EUR]
co_curt                  cost for curtailment of renewables [EUR per MWh]
co_f(t,p)                cost for fuel (fuel price + mark up + transport costs) [EUR per MWhth]
co_co2(t,p)              cost for CO2 (CO2-allowances * emission factor) [EUR per MWhth]
co_v(t,p)                variable cost for existing plants [EUR per MWhel]
*co_v1(t,p)               variable cost for existing plants [EUR per MWhel]
*co_v2(t,p)               variable cost for new plants [EUR per MWhel]

co_up(t,p)               cost for ramping up (fuel related) [MWhth per MW]
co_down(p)               cost for ramping down power plant (depreciation) [EUR per MWel]

*========= System Load and District Heat =======================================
char_c(c,ch_c)           country specific characteristics
dem(t,c)                 system load [MWh per hour]

res_dem(t,c)             residual load (system load (incl. network losses) - feed-in of RES including wind onshore + wind offshore + pv) [MWh per hour]
res_dem_max              maximum of residual load [MWh per hour]

*======== Power Plants==========================================================
char_p(p,ch_p)           all characteristics of a plant
char_tech(tech,ch_tech)  characteristics categorized by technology
char_tech2(tech,ch_p,y)  characteristics categorized by technology and changing per year
av(t,tech)               hourly availability factor of technology tech in country c [-]
chp_fac(tech,c)          factor for calibrating chp-generation
*p_chp(p)                 factor for calibrating or declaring chp-plants (check if necessary factor adaption)

eta_p_add(p)             power plant efficiency of new plants [-]
eta_new(p)               average eta of power plant portfolio considering larger values of added plants and lower values of existing plants [-]
cap_new(p)               power plant portfolio including installed and added capacity [MW]
cap_add(p)               added power plant capacity [MW]
p_dec(p,y)               decommissioned power plant capacities [MW]

*======== RES ==================================================================
char_res                 all characteristics of RES technologies
res_p(res,c)             installed capacity of RES plants per country [MW]
res_av(t,res,c)          feed-in profiles from intermittent RES technologies per country and timestep [MWh]
res_in(t,res,c)          feed-in of intermittent RES technologies (wind onshore + wind offshore + pv) per country and timestep [MWh]
res_other(t,res,c)       feed-in of non-intermittent RES technologies (biomass + other RES) [MWh]
res_ror(t,res,c)         feed-in of run-of-river technologies per country and timestep [MWh]

*======== NTC & Load Flows =====================================================
exch(t,y)                hourly netto-exports from DE to neighbouring countries [MWh per h] (exogenously given due to model comparison in MODEX-EnSAVes)
;
t_opt = card(t)
;

*======== Input Data DSM (Electric Vehicle & PtH) ============================================
Set
*Electric vehicles
c_DE(c)                  subset for country (Germany) (DSM)
ev                       electric vehicle types
headers_ev               electric vehicle data - upload headers
headers_time_ev          electric vehicle temporal data - upload headers
map_n_ev(c,ev)           share of ev per load profile in actual scenario [0 1]

*Power-to-heat and heat storages
app                      flexible application for PtH
apphstor                 flexible application for heat storage
ch_app                   list of application characteristics for PtH
ch_apphstor              list of application characteristics for heat storage

map_appC                 map application to country
;

Parameter
*Electric vehicles
ev_data                  ev techno-economic characteristics
ev_time_data_upload      ev timeseries load profile and availability profile (parking profile)

n_ev_p_upload            availability (power rating) of the charging connection in hour h [MW - 0 when car is in use or parked without grid connection]
ev_ed_upload             electricity demand for mobility vehicle profile ev in hour h [MW]

ev_quant                 number of electric vehicles (fleet and private ev)
c_m_ev                   marginal costs of discharging V2G [EUR per MWh]
eta_ev_in                ev efficiency of charging (G2V) [0 1]
eta_ev_out               ev efficiency of discharging (V2G) [0 1]
ev_chargelev_ini         ev charging level in initial period [0 1]

ev_battery_cap           ev battery capacity [MWh]
ev_load_cap              ev load power [MW]
ev_stor_vol              ev storage volume [MWh]

ev_charge_av             ev charging availability [% of parked cars with grid connection]
ev_ed                    ev driving electricity demand [MWh]

*Power-to-heat and heat storages
char_app                 characteristics application PtH
char_apphstor            characteristics application heat storage
p2h_inst(app)            installed capacities of power-to-heat [MW] -> exogenous parameter from FORECAST
p2h_eta(app)             efficiency of power-to-heat [COP]
p2h_cons(app)            yearly electricity consumption of heat pumps
p2h_profile              non-optimized p2h load profile [MWhel]
hstor_data

hstor_inst(apphstor)          installed heat storage capacities
hstor_co_f(apphstor)          fixed costs for heat storages
hstor_eta_in(apphstor)        efficiency of charging heat storages
hstor_eta_out(apphstor)       efficiency of discharging heat storages
hstor_chargelev_ini(apphstor) charge starting level of heat storages
;


*============ Unload Data to GDX File ==========================================


$onecho >temp1.tmp
set=p            rng=Plants!A4           rdim=1  cdim=0
set=tech         rng=Technologies!A4     rdim=1  cdim=0
set=ch_p         rng=Plants!A3           rdim=0  Cdim=1
set=ch_tech      rng=Technologies!A3     rdim=0  Cdim=1
set=c            rng=Countries!A4        rdim=1  cdim=0
set=ch_c         rng=Countries!A3        rdim=0  Cdim=1
set=f            rng=Fuel!B3             rdim=1  cdim=0
set=map_ptech    rng=Plants!BM3          rdim=2  cdim=0
set=map_pf       rng=Plants!BO3          rdim=2  cdim=0
set=map_pc       rng=Plants!BQ3          rdim=2  cdim=0

par=pr_f         rng=Fuel!B3             rdim=1  cdim=1
par=n_fpr        rng=Fuel_timeseries!A5  rdim=1  cdim=2
par=char_p       rng=Plants!A3           rdim=1  cdim=1
par=char_c       rng=Countries!A3        rdim=1  cdim=1
par=char_tech    rng=Technologies!A3     rdim=1  cdim=1
par=char_tech2   rng=Tech2!A3            rdim=1  cdim=2
par=p_dec        rng=plants_dec!A3       rdim=1  cdim=1
Par=chp_fac      rng=chp_factor!A2       rdim=1  cdim=1
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %data%.xlsx O=%data%.gdx SQ=N SE=10 cmerge=1 @temp1.tmp"
$gdxin %data%.gdx
$load p tech ch_p ch_tech c ch_c  f map_ptech map_pf map_pc
$load pr_f n_fpr char_p char_c char_tech char_tech2 chp_fac p_dec
$gdxin
$offUNDF



$onecho >temp2.tmp
par=dem          rng=Demand!A1           Rdim=1  Cdim=1
par=av           rng=Availability!A1     Rdim=1  cdim=1
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %datatime%.xlsx O=%datatime%.gdx SQ=N SE=10 cmerge=1 @temp2.tmp"
$gdxin %datatime%.gdx
$load dem av
*dem_heat
$gdxin
$offUNDF



$onecho >temp3.tmp
par=exch         rng=exchange!A4         RDim=1  CDim=1
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataNTC%.xlsx O=%dataNTC%.gdx SQ=N SE=10 cmerge=1 @temp3.tmp"
$gdxin %dataNTC%.gdx
$load  exch
$gdxin
$offUNDF


$onecho >temp4.tmp
set=ch_res       rng=tech!B3              RDim=0  CDim=1
set=res          rng=tech!B4              RDim=1  CDim=0

par=char_res     rng=tech!B3              RDim=1  CDim=1
par=res_p        rng=p_inst!A3            RDim=1  CDim=1
par=res_av       rng=profile!A1           Rdim=1  Cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataRES%.xlsx O=%dataRES%.gdx SQ=N SE=10 cmerge=1 @temp4.tmp"
$gdxin %dataRES%.gdx
$load  ch_res res
$load  char_res res_p res_av
$gdxin
$offUNDF

$onecho >temp5.tmp
set=ev                   rng=EV_input_data!B6         Rdim=1  Cdim=0
set=headers_ev           rng=EV_input_data!A5         Rdim=0  Cdim=1
set=map_n_ev             rng=EV_input_data!A6         Rdim=2  Cdim=0
*set=headers_time_ev      rng=EV_timeseries!A4         Rdim=0  Cdim=2

par=ev_data              rng=EV_input_data!A5         Rdim=2  Cdim=1
par=ev_time_data_upload  rng=EV_timeseries!A4         Rdim=1  Cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataEV%.xlsx O=%dataEV%.gdx maxdupeerrors=100 SQ=N SE=10 cmerge=1 @temp5.tmp"
$gdxin %dataEV%.gdx
$load  ev  headers_ev  map_n_ev
*$load  headers_time_ev
$load  ev_data  ev_time_data_upload
$load
$gdxin
$offUNDF


$onecho >temp6.tmp
set=app                   rng=PtH_input_data!A7    Rdim=1  Cdim=0
set=apphstor              rng=HSTOR_input_data!A6  Rdim=1  Cdim=0

set=ch_app                rng=PtH_input_data!A5    Rdim=1  Cdim=2
set=map_appC              rng=PtH_input_data!K6    Rdim=2  Cdim=0

par=char_app              rng=PtH_input_data!A5    Rdim=1  Cdim=2
par=char_apphstor         rng=HSTOR_input_data!A5  Rdim=1  Cdim=2
par=p2h_profile           rng=PtH_timeseries!A3    Rdim=1  Cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %dataPtH%.xlsx O=%dataPtH%.gdx SQ=N SE=10 cmerge=1 @temp6.tmp"
$gdxin %dataPtH%.gdx
$load  app apphstor ch_app
$load  map_appC
$load  char_app char_apphstor
$load  p2h_profile
$gdxin
$offUNDF

*=========== Re-Defining Parameters ============================================

$ontext

char_p(p,'p_inst')=char_p(p,'p_inst')- p_dec(p,'%year%');

$ifThen set prevYear

$onUNDF
$gdxin %dataCnew%.gdx
$load  cap_new cap_add
$gdxin
$offUNDF

char_p(p,'p_inst')= cap_new(p) - p_dec(p,'%year%');
char_p(p,'p_inst')$(cap_new(p) < p_dec(p,'%year%'))= 0;

$endIf

$offtext

*=========== Implementing Parameter from ELTRAMOD-INVEST =======================

$onUNDF
$gdxin %dataCnew%.gdx
$load cap_new
$gdxin
$offUNDF

char_p(p,'p_inst')  = cap_new(p);

*============ Subsets ==========================================================
p_av(p)     = YES$ ((char_p(p,'p_inst')) or (char_p(p,'p_feas')= 1));
exist(p)    = YES$  char_p(p,'p_inst');
new(p)      = YES$ (char_p(p,'p_feas')= 1);
stor(p)     = YES$ (char_p(p,'stor')= 1);
psp(p)      = YES$  map_ptech(p,'psp');
reser(p)    = YES$  map_ptech(p,'reservoir');
first(t)    = YES$ (ord(t) = 1);
last(t)     = YES$ (ord(t) = card(t));


*=========== Parameter Electric Vehicles =======================================

ev_quant(c,ev)           = ev_data(c,ev,'ev_quant') ;
c_m_ev(c,ev)             = ev_data(c,ev,'mc') ;
eta_ev_in(c,ev)          = ev_data(c,ev,'efficiency_charge') ;
eta_ev_out(c,ev)         = ev_data(c,ev,'efficiency_discharge') ;
ev_chargelev_ini(c,ev)   = ev_data(c,ev,'ev_start') ;

*ev_battery_cap(c,ev)     = ev_data(c,ev,'ev_battery_cap') ;
ev_load_cap(c,ev)        = ev_data(c,ev,'ev_load_cap') ;
ev_stor_vol(c,ev)        = ev_data(c,ev,'ev_stor_vol') ;

ev_charge_av(c,ev,t)     = ev_time_data_upload(t,'ev_char_av',ev) ;
ev_ed(c,ev,t)            = ev_time_data_upload(t,'ev_ed',ev) ;

*=========== Parameter Power-to-Heat and Heat Storages =========================

p2h_inst(app)            = char_app(app,'p2h_inst','%YEAR%') ;
p2h_eta(app)             = char_app(app,'p2h_eta','%YEAR%') ;
p2h_cons(app)            = char_app(app,'p2h_cons','%YEAR%') ;
p2h_profile(t,app,y)     = p2h_profile(t,'p2h','%YEAR%');

hstor_inst(apphstor)         = char_apphstor(apphstor,'inst_hstor','%YEAR%') ;
hstor_eta_in(apphstor)       = char_apphstor(apphstor,'hstor','efficiency_charge') ;
hstor_eta_out(apphstor)      = char_apphstor(apphstor,'hstor','efficiency_discharge') ;
hstor_chargelev_ini(apphstor)= char_apphstor(apphstor,'hstor','hstor_start') ;



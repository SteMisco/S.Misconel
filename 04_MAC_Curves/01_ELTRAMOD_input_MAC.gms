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
*                INPUT FILE ELTRAMOD DISPATCH
*===============================================================================

Set
t                        modelling hours /t%FROM% * t%TO%/
y                        modelling years /%YEAR%/
*t                        modelling hours /t1 * t8760/
*y                        modelling years /y2030/

it                       iteration loops / it1*it1 /
fo                       flexibility options / fo1*fo9 /

ch_p                     list of power plant characteristics (directly read from excel)
ch_c                     list of country specific characteristics (directly read from excel)
ch_tech                  list of technology characteristics
ch_f                     list of fuel characteristics
ch_res                   list of res technology characteristics
p                        list of power plants (directly read from excel)
f                        list of fuels
c                        country
li                       line (connection between two countries)
tech                     technology

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
res(p)                   all renewable technologies
vres(p)                  volatile renewable technologies
ores(p)                  other renewable technologies
first(t)                 first time step (relevant for storage level of pump storage plants)
last(t)                  last time step (relevant for storage level of pump storage plants)

;

Scalar
co_voll                  value of lost load for DUMP_DEM [EUR per MWh]                / 800 /
co_curt                  costs for RES curtailment [EUR per MWh]                      / 0 /
i                        interest rate                                                / 0.09 /
p2h_eta_opp              opportunity efficiency of power-to-heat (for gas boiler)     / 0.90 /
*co2_import               co2 emissions from import 2030 (MODEX IDILES-JMM) in MtCO2   / 11.2 /
;

Parameters
t_opt                    optimisation period [h]
inc(fo,p)                incremental capacity expansion [MW]

cap_max(p)               maximum added capacity [MW]
cap_new(p)

tc_ref                   total system costs of reference system in [EUR]   / 40919982779.309242 /
co2_em_ref               total CO2 emissions of reference system in [tCO2] / 254970657.12556115 /
cca_ref                  start dummy cost of co2 abatement of reference system in [EUR per saved tCO2] / 10000 /

*price(t)
co2_em(t)                hourly CO2 emissions in [tCO2]
co2_em_total             total CO2 emissions in [tCO2]
cca                      cost of CO2 abatement in [EUR per tCO2]
co2_red                  total CO2 reduction compared to reference case [tCO2] (pos.value=increase and neg.value=decrease)
co2_red_cum              cumulative total CO2 reduction [tCO2]
tc_delta                 delta of total system costs compared to reference case (pos. = additional costs) in [EUR]
cap_best(p)              installed capacity of best solution in respective iteration loop in [MW]
cca_best                 CO2 abatement costs of best solution in respective iteration loop in [EUR per saved tCO2]
co2_em_best              total CO2 emissions of best solution in respective iteration loop in [tCO2]
co2_red_best
co2_red_cum_best         cumulative CO2 emission reduction of best solution in respective iteration loop in [tCO2]
tc_best                  total system costs of best solution in respective iteration loop in [MWh per hour]
cost(p)                  annuity and fixed costs of power plants and flexibility options

an_new(p)                annuity for current iteration run
an_prev_fo(p)            annuity previous flexibility options
an_best(p)               annuity of best iteration run saved for next iteration

gen(y,t,tech)            hourly generation of power plants and storages [MWh per hour]
gen_res(y,t,tech)        electricity generation of all renewables in [MWh per hour]
gen_vres(y,t,tech)       electricity generation of volatile renewables in [MWh per hour]
gen_best(y,t,tech)       electricity generation of conventional power plants of best solution in respective iteration loop in [MWh per hour]
gen_best_year(tech)
gen_res_best_year(tech)
gen_res_best(y,t,tech)   electricity generation of all renewables of best solution in respective iteration loop in [MWh per hour]
gen_vres_best(y,t,tech)  electricity generation of volatile renewables of best solution in respective iteration loop in [MWh per hour]

cost_best(p)               annual fixed and annuity costs of best solution in respective iteration loop in [EUR]
lc_best(p)               load change costs of best solution in respective iteration loop in [EUR]

f_use(y,tech)            fuel consumption in [MWhth]
co2_em_tech(y,tech)      produced CO2 emissions per technology in [tCO2]
pr_el(t,c)               hourly electricity price per country [EUR per MWhel]
pr_el_av                 yearly average electricity price per country [EUR per MWhel]

pr_el_av_best
flh_plant_best(tech)
flh_res_best(tech)
f_use_best(tech)
co2_best(tech)
curt(t,c)
curt_best
stor_charge(t,p)
stor_discharge(t,p)
stor_charge_best(p)
stor_discharge_best(p)
lcoe_p_best(tech)
lcoe_res_best(tech)

f_use_gasboiler          fuel use of gas boilers in [MWhth]
co2_em_gasboiler         co2 emissions of gas boilers in [tCO2]

co2_gasboiler_best
co2_trans_best
co2_chp_best

gasboiler_best_hourly(t)
chp_best_hourly(t,p)
dump_dem_best

*========= Prices ==============================================================
pr_f(f,y)                fuel price [EUR per MWhth] and CO2 price [EUR per tCO2]
n_fpr(t,f,y)             fuel price time series and CO2 price time series for considered year

*========= Costs ===============================================================
an(p)                    annuity of expanded power plants
an_ev                    annuity of expanded electric vehicles
an_app                   annuity of expanded power-to-heat applications
an_dev                   annuity of expanded power-to-gas devices
co_curt                  cost for curtailment of renewables [EUR per MWh]
co_f(t,p)                cost for fuel (fuel price + mark up + transport costs) [EUR per MWhth]
co_co2(t,p)              cost for CO2 (CO2-allowances * emission factor) [EUR per MWhth]
co_v(t,p)                variable cost for existing plants [EUR per MWhel]
co_up(t,p)               cost for ramping up (fuel related) [MWhth per MW]
co_down(p)               cost for ramping down power plant (depreciation) [EUR per MWel]

*========= System Load and Residual Load =======================================
char_c(c,ch_c)           country specific characteristics
dem(t,c)                 system load [MWh per hour]
res_dem(t,c)             residual load calculated as difference between (system load + network losses) - (feed-in of w_on w_off pv_rt pv_gr)
res_dem_max              maximal residual load per country
dem_max

*======== Power Plants==========================================================
char_p(p,ch_p)           all characteristics of a plant
char_tech(tech,ch_tech)  characteristics categorized by technology
char_tech2(tech,ch_p,y)  characteristics categorized by technology and changing per year

av(t,tech)               hourly availability factor of technology tech in country c [-]
eta_p_add(p)             power plant efficiency of new plants [-]
eta_new(p)               average eta of power plant portfolio considering larger values of added plants and lower values of existing plants [-]
p_dec(p,y)               decommissioned power plant capacities [MW]
cap_new(p)               existing power plants (installed - decomm.) plus total added capacities of previous and recent year [in MWel]

*======== RES ==================================================================
res_av(t,tech,c)         feed-in profiles from intermittent RES technologies per country and timestep [MWh]
*res_in(t,tech,c)         feed-in of intermittent RES technologies (wind onshore + wind offshore + pv rooftop + pv ground mounted) per country and timestep [MWh]
res_other(t,tech,c)      feed-in of non intermittent RES technologies (biomass + other RES) [MWh]
*res_ror(t,tech,c)        feed-in of run-of-river technologies per country and timestep [MWh]

*======== NTC & Load Flows =====================================================
exch(t,y)                hourly netto-exports from DE to neighbouring countries [MWh per h] (exogenously given due to model comparison in MODEX-EnSAVes)
;

t_opt = card(t)
;

*======== Input Data DSM (Electric Vehicle & PtH) ==============================
Set
*$ontext
*Electric vehicles
c_DE(c)                  subset for country (Germany) (DSM)
ev                       electric vehicle types
headers_ev               electric vehicle data - upload headers
headers_time_ev          electric vehicle temporal data - upload headers
map_n_ev(c,ev)           share of ev per load profile in actual scenario [0 1]
car                      internal combustion engines (incl. PHEV)
*$offtext

*Power-to-heat and heat storages
app                      flexible application for PtH
p2h(app)                 power-to-heat application
hstor(app)               heat storage
ch_app                   list of application characteristics for PtH
map_appC                 map application to country
map_hstorP2H             map heating storage with heat pump


*Power-to-gas and h2 storages
dev                      flexible device for PtG
ch_dev                   list of device characteristics for PtG
map_devC                 map device to country
map_p2pG                 map h2-storage and fuel cell to PtG (electrolyzer)
map_h2storFC             map fuel cell to h2-storage
h2stor(dev)              h2 tanks as subset of device
fc(dev)                  fuel cells as subset of device
p2g(dev)                 electrolyzers as subset of device
;

Parameter
*$ontext
*Electric vehicles
ev_data                  ev techno-economic characteristics
ev_time_data_upload      ev timeseries load profile and availability profile (parking profile)
n_ev_p_upload            availability (power rating) of the charging connection in hour h [MW - 0 when car is in use or parked without grid connection]
ev_ed_upload             electricity demand for mobility vehicle profile ev in hour h [MW]
ev_quant                 number of electric vehicles (fleet and private ev)
eta_ev(c,ev)             ev efficiency of dis- and charging (V2G and G2V) [0 1]
ev_chargelev_ini         ev charging level in initial period [0 1]
ev_battery_cap           ev battery capacity [MWh]
ev_load_cap              ev load power [MW]
ev_stor_vol              ev storage volume [MWh]
ev_charge_av             ev charging availability [% of parked cars with grid connection]
ev_ed                    ev driving electricity demand per electric vehicle in [MWh]
ev_new                   existing and added number of ev [-]
transport_data           transportation data about internal combustion engines
ev_prev_cost(c,ev)       infrastructure costs for charging stations from previous iteration loops in [EUR]
ev_cost_new(c,ev)        infrastructure costs for charging stations in [EUR]
ev_inc(fo,ev)            additional electric vehicles per iteration loop [-]
ev_cost_best(c,ev)       infrastructure costs for charging stations in [EUR] from best solution in iteration loop
ev_best(c,ev)            total number of electric vehicles from best solution in iteration loop in [-]
ev_max(c,ev)             maximum potential or number of electric vehicles [-]
car_new(c,car)           total number of combustion engine cars which are substituted by additional electric vehicles [-]
ev_add                   additional electric vehicles (needed for if-statement)
car_best(c,car)          total number of combustion engine cars from best solution in iteration loop [-]
co2_em_trans(c,car)      co2 emissions from combustion engine cars in [tCO2]
*ev_cost(c,ev)

*$offtext

*Power-to-heat and heat storages
char_app                 characteristics application PtH
p2h_profile              non-optimized p2h load profile (capacity factors) [h]
chp_factor(p,c)          combined heat and power factor [-]
p2h_new(app)             existing and added p2h capacity
p2h_new(app)             existing and added p2h capacity
an_app(app)              annuity of pth and heat storages [EUR] per time period
p2h_max(app)             maximum potential of pth and and heat storages [MW]
p2h_cost(app)            annuity and fixed costs of pth and and heat storages [EUR]
an_app_new(app)          new annuity (with added cap) of pth and heat storages [EUR] per time period
p2h_inc(fo,app)          additional pth and heat storage capacity per iteration loop [-]
an_prev_app(app)         annuity and fixed costs of previous iteration loop for pth and and heat storages [EUR]
an_app_best(app)         annuity and fixed costs of pth and and heat storages [EUR] from best solution in iteration loop
p2h_best(app)            pth and heat storage capacity [MW] from best solution in iteration loop
p2h_cost_best(app)       annuity and fixed costs of pth and and heat storages [EUR] from best solution in iteration loop
co2_em_chp
co2_em_dh
gasboiler_best           yearly generation by gas boilers [MWh]
heat_dem

*$ontext
*Power-to-gas and h2 storages
char_dev                 characteristics device PtG
h2_demand(t,*)           hydrogen demand in electricity demand for electrolyzer [MWhel]
p2p_new(dev)             existing and added p2g capacity
an_dev(dev)              annuity of ptg and h2 tank and fuel cell [EUR] per time period
p2p_max(dev)             maximum potential of  ptg and h2 tank and fuel cell [MW]
p2p_cost(dev)            annuity and fixed costs of ptg and h2 tank and fuel cell [EUR]
an_dev_new(dev)          new annuity (with added cap) of ptg and h2 tank and fuel cell [EUR] per time period
p2p_inc(fo,dev)          additional ptg and h2 tank and fuel cell capacity per iteration loop [-]
an_prev_dev(dev)         annuity and fixed costs of previous iteration loop for ptg and h2 tanks and fuel cells [EUR]
an_dev_best(dev)         annuity and fixed costs of ptg and h2 tanks and fuel cells [EUR] from best solution in iteration loop
p2p_best(dev)            ptg and h2 tanks and fuel cells [MW] from best solution in iteration loop
p2p_cost_best(dev)       annuity and fixed costs of ptg and h2 tanks and fuel cells [EUR] from best solution in iteration loop
gen_fc(t,dev)            generation by fuel cells [MWh]

*gasboiler                yearly generation by gas boilers [MWh]
flh_chp(tech)            full load hours of chp power plants [h]
flh_pth(app)             full load hours of pth [h]
flh_ptg(dev)             full load hours of ptg [h]

gen_fc_best
ptg_best
h2stor_in_best
pth_best
hstor_in_best
hstor_out_best
gasboiler_best
chp_best
ev_charge_best
ev_discharge_best
dump_dem_best
;

*============ Unload Data to GDX File ==========================================


$onecho >temp1.tmp
set=p                     rng=Plants!A4             Rdim=1  Cdim=0
set=tech                  rng=Technologies!A4       Rdim=1  Cdim=0
set=ch_p                  rng=Plants!A3             Rdim=0  Cdim=1
set=ch_tech               rng=Technologies!A3       Rdim=0  Cdim=1
set=c                     rng=Countries!A4          Rdim=1  Cdim=0
set=ch_c                  rng=Countries!A3          Rdim=0  Cdim=1
set=f                     rng=Fuel!B3               Rdim=1  Cdim=0

set=map_ptech             rng=Plants!BO3            Rdim=2  Cdim=0
set=map_pf                rng=Plants!BQ3            Rdim=2  Cdim=0
set=map_pc                rng=Plants!BS3            Rdim=2  Cdim=0

par=pr_f                  rng=Fuel!B3               Rdim=1  Cdim=1
par=n_fpr                 rng=Fuel_timeseries!A5    Rdim=1  Cdim=2
par=char_p                rng=Plants!A3             Rdim=1  Cdim=1
par=char_c                rng=Countries!A3          Rdim=1  Cdim=1
par=char_tech             rng=Technologies!A3       Rdim=1  Cdim=1
par=char_tech2            rng=Tech2!A3              Rdim=1  Cdim=2
par=p_dec                 rng=plants_dec!A3         Rdim=1  Cdim=1

set=ev                    rng=EV_input_data!B6      Rdim=1  Cdim=0
set=headers_ev            rng=EV_input_data!A5      Rdim=0  Cdim=1
set=map_n_ev              rng=EV_input_data!A6      Rdim=2  Cdim=0
set=car                   rng=Trans_input_data!B6   Rdim=1  Cdim=0

par=ev_data               rng=EV_input_data!A5      Rdim=2  Cdim=1
par=ev_time_data_upload   rng=EV_timeseries!A4      Rdim=1  Cdim=2
par=transport_data        rng=Trans_input_data!A5   Rdim=2  Cdim=1

set=app                   rng=PtH_input_data!A7     Rdim=1  Cdim=0
set=ch_app                rng=PtH_input_data!A5     Rdim=1  Cdim=2
set=map_appC              rng=PtH_input_data!H7     Rdim=2  Cdim=0
set=map_hstorP2H          rng=PtH_input_data!J7     Rdim=2  Cdim=0

par=char_app              rng=PtH_input_data!A5     Rdim=1  Cdim=2
par=p2h_profile           rng=PtH_timeseries!A3     Rdim=1  Cdim=2
par=chp_factor            rng=CHP_fac!A1            Rdim=1  Cdim=1

set=dev                   rng=PtG_input_data!A7     Rdim=1  Cdim=0
set=ch_dev                rng=PtG_input_data!A5     Rdim=1  Cdim=2
set=map_devC              rng=PtG_input_data!K7     Rdim=2  Cdim=0
set=map_p2pG              rng=PtG_input_data!M7     Rdim=2  Cdim=0
set=map_h2storFC          rng=PtG_input_data!O7     Rdim=2  Cdim=0

par=char_dev              rng=PtG_input_data!A5     Rdim=1  Cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %data%.xlsx O=%data%.gdx SQ=N SE=10 cmerge=1 @temp1.tmp"
$gdxin %data%.gdx
$load    p tech ch_p ch_tech c ch_c  f map_ptech map_pf map_pc
$load    pr_f n_fpr char_p char_c char_tech char_tech2 p_dec
$load    ev  headers_ev  map_n_ev ev_data  ev_time_data_upload
$load    transport_data
$load    car
$load    app ch_app map_appC map_hstorP2H
$load    char_app p2h_profile chp_factor
$load    dev ch_dev map_devC map_p2pG map_h2storFC
$load    char_dev
$gdxin
$offUNDF


$onecho >temp2.tmp
par=dem          rng=Demand!A1           Rdim=1  Cdim=1
par=av           rng=Availability!A1     Rdim=1  Cdim=1
par=res_av       rng=RES_Profile!A1      Rdim=1  Cdim=2
$offecho

$onUNDF
$if set LoadExcel $call "gdxxrw %datatime%.xlsx O=%datatime%.gdx SQ=N SE=10 cmerge=1 @temp2.tmp"
$gdxin %datatime%.gdx
$load dem av
$load res_av
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

*============ Subsets ==========================================================
p_av(p)     = YES$ ((char_p(p,'p_inst')) or (char_p(p,'p_feas')= 1));
exist(p)    = YES$  char_p(p,'p_inst');
new(p)      = YES$ (char_p(p,'p_feas')= 1);
stor(p)     = YES$ (char_p(p,'stor')= 1);
vres(p)     = YES$ (char_p(p,'res')= 1 and (char_p(p,'fluc')= 1 or char_p(p,'fluc')= 0.5));
ores(p)     = YES$ (char_p(p,'res')= 1 and char_p(p,'fluc')= 0 );
res(p)      = YES$ (char_p(p,'res')= 1);
psp(p)      = YES$  map_ptech(p,'psp');
reser(p)    = YES$  map_ptech(p,'reservoir');
first(t)    = YES$ (ord(t) = 1);
last(t)     = YES$ (ord(t) = card(t));

h2stor(dev) = YES$ (char_dev(dev,'storage','%YEAR%')= 1);
fc(dev)     = YES$ (char_dev(dev,'fuelcell','%YEAR%')= 1);
p2g(dev)    = YES$ (char_dev(dev,'storage','%YEAR%')= 0 and (char_dev(dev,'fuelcell','%YEAR%')= 0));

hstor(app)  = YES$ (char_app(app,'heat_storage','%YEAR%')= 1);
p2h(app)    = YES$ (char_app(app,'heat_storage','%YEAR%')= 0);

*=========== Parameter Electric Vehicles =======================================
*$ontext
ev_quant(c,ev)           = ev_data(c,ev,'ev_quant') ;
eta_ev(c,ev)             = ev_data(c,ev,'eta_charge') ;
ev_chargelev_ini(c,ev)   = ev_data(c,ev,'ev_start') ;
ev_load_cap(c,ev)        = ev_data(c,ev,'ev_load_cap') ;
ev_stor_vol(c,ev)        = ev_data(c,ev,'ev_stor_vol') ;
ev_charge_av(c,ev,t)     = ev_time_data_upload(t,'ev_char_av',ev) ;
ev_ed(c,ev,t)            = ev_time_data_upload(t,'ev_ed',ev) ;
*$offtext

*$stop

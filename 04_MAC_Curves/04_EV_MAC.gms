*===============================================================================
*   Modeling dispatch decisions for flexibility options with an integrated
*         multi-iterative capacity expansion algorithm to determine marginal
*         CO2 abatement cost curves for Germany from 2030 to 2045.
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel (supported by Hannes Hobbie, Matteo Giacomo Prina)
*   Last updated: 01.12.2022
*===============================================================================


*====================== EQUATIONS FOR ELECTRIC VEHICLES ========================

*(EV_a) Energy balance of electric vehicles - electricity demand for electric vehicles
ev_energy_balance(c,ev,t)..
         ev_ed(c,ev,t) * ev_new(c,ev)
         =e= EV_GED(c,ev,t)
;

*(EV_b) Cumulative charging level in the first hour [MWh]
ev_chargelev_start(ev,t,c)$ (ord(t) = 1)..
         EV_L(c,ev,t) =e=
                         ev_chargelev_ini(c,ev) * ev_stor_vol(c,ev) * ev_new(c,ev)
                         + EV_CHARGE(c,ev,t) * 0.96
                         - EV_GED(c,ev,t)
                         - EV_DISCHARGE(c,ev,t) / 0.96
;

*(EV_c) Cumulative charging level in hour h [MWh]
ev_chargelev(c,ev,t)$ (ord(t) > 1)..
         EV_L(c,ev,t) =e= EV_L(c,ev,t-1)
                          + EV_CHARGE(c,ev,t) * 0.96
                          - EV_GED(c,ev,t)
                          - EV_DISCHARGE(c,ev,t) / 0.96
;

*(EV_d) Cumulative maximal charging level [MWh]
ev_chargelev_max(c,ev,t)..
         EV_L(c,ev,t) =l=   ev_new(c,ev) * ev_stor_vol(c,ev)
;

*(EV_e) Cumulative maximal charging power [MW]
ev_charge_maxin(c,ev,t)..
        EV_CHARGE(c,ev,t) =l= ev_load_cap(c,ev) * ev_new(c,ev) * ev_charge_av(c,ev,t)
;

*(EV_f) Cumulative charging level in the last hour [MWh]
ev_chargelev_ending(c,ev,t)$ (ord(t) = card(t))..
         EV_L(c,ev,t) =e= ev_chargelev_ini(c,ev) * ev_stor_vol(c,ev) * ev_new(c,ev)
;

*(EV_g) Cumulative maximal charging limit [MW]
ev_charge_maxin_level(c,ev,t)..
        EV_CHARGE(c,ev,t) * 0.96  =l=  ev_stor_vol(c,ev) * ev_new(c,ev)  - EV_L(c,ev,t-1)
;


*(EV_h) Cumulative maximal discharging power [MW]
ev_discharge_maxout(c,ev,t)..
        EV_DISCHARGE(c,ev,t) =l= ev_load_cap(c,ev) * (ev_new(c,ev)*0.5) * ev_charge_av(c,ev,t)
;

*(EV_i) Cumulative maximal discharging limit [MW]
ev_discharge_maxout_level(c,ev,t)..
        EV_DISCHARGE(c,ev,t) / 0.96  =l=  EV_L(c,ev,t-1)
;


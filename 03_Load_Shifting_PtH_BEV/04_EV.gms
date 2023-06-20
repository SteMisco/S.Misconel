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

*====================== EQUATIONS FOR ELECTRIC VEHICLES ========================

*(EV_a) Energy balance of electric vehicles - electricity demand for electric vehicles (for uncontrolled and controlled charging)
ev_energy_balance(c,ev,t)..
         ev_ed(c,ev,t)
         =e= EV_GED(c,ev,t)
;

*(EV_b) Cumulative charging level in the first hour (for uncontrolled charging) [MWh]
ev_chargelev_start(ev,t,c)$ (ord(t) = 1)..
         EV_L(c,ev,t) =e=
                         ev_chargelev_ini(c,ev) * ev_stor_vol(c,ev) * ev_quant(c,ev)
                         + EV_CHARGE(c,ev,t)
                         - EV_GED(c,ev,t)
;

*(EV_c) Cumulative charging level in hour h (for uncontrolled and controlled charging) [MWh]
ev_chargelev(c,ev,t)$ (ord(t) > 1)..
         EV_L(c,ev,t) =e= EV_L(c,ev,t-1)
                          +  EV_CHARGE(c,ev,t)
                          -  EV_GED(c,ev,t)
;

*(EV_d) Cumulative maximal charging level (for uncontrolled and controlled charging) [MWh]
ev_chargelev_max(c,ev,t)..
         EV_L(c,ev,t) =l=  ev_quant(c,ev) * ev_stor_vol(c,ev)
;

*(EV_e) Cumulative maximal charging power (for uncontrolled charging)  [MW]
ev_charge_maxin(c,ev,t)..
        EV_CHARGE(c,ev,t) =l= ev_load_cap(c,ev) * ev_quant(c,ev) * ev_charge_av(c,ev,t)
;


*(EV_f) Cumulative charging level in the last hour (for uncontrolled charging) [MWh]
ev_chargelev_ending(c,ev,t)$ (ord(t) = card(t))..
         EV_L(c,ev,t) =e= ev_chargelev_ini(c,ev) * ev_stor_vol(c,ev) * ev_quant(c,ev)
;


*(EV_g) Cumulative maximal charging limit (for uncontrolled charging)  [MW]
ev_charge_maxin_limit(c,ev,t)..
        EV_CHARGE(c,ev,t)  =l=  ev_stor_vol(c,ev) * ev_quant(c,ev) - EV_L(c,ev,t-1)
;


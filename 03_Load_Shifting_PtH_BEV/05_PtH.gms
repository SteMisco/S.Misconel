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

*===== EQUATIONS FOR POWER-TO-HEAT AND HEAT STORAGES ===========================

*(PtH_a) heat balance
heat_balance(t,app)..
           sum(y,p2h_profile(t,app,y))
         + HSTOR_IN(t,app)

           =e=

           P2H_OPT(t,app)
         + HSTOR_OUT(t,app)

;

*$ontext
*(PtH_b) maximum of load increase by PtH
maximum_p2h(t,app)..
       P2H_OPT(t,app) =l=  p2h_inst(app)
;
*$offtext


*===== Heat Storage Dis/Charging ===============================================
*$ontext
*(PtH_c) Cumulative charging level in the first hour
hstor_chargelev_start(t,app)$( ord(t) = 1 )..
         HSTOR_L(t,app)   =e=  0.5 * p2h_inst(app)
                               +  HSTOR_IN(t,app)
                               -  HSTOR_OUT(t,app)

;
*$offtext

*(PtH_d) Cumulative charging level in hour h
hstor_chargelev(t,app)$ ( ord(t) > 1 ) ..
         HSTOR_L(t,app)   =e=  HSTOR_L(t-1,app)
                               +  HSTOR_IN(t,app)
                               -  HSTOR_OUT(t,app)
;

*(PtH_e) Cumulative maximal charging level
hstor_chargelev_max(t,app)..
         HSTOR_L(t,app) =l=   p2h_inst(app)
;

*$ontext
*(PtH_f) Cumulative charging level in the last hour
*hstor_chargelev_ending(t,app)$( ord(t) = card(t) )..
         HSTOR_L.fx(t,app)$( ord(t) = card(t)) =    0.5 * p2h_inst(app)
;
*$offtext


*(PtH_g) Cumulative maximal charging limit
hstor_charge_maxin_limit(t,app)..
         HSTOR_IN(t,app) =l=  p2h_inst(app)
;


*(PtH_h) Cumulative maximal discharging limit
hstor_discharge_maxout_limit(t,app)..
         HSTOR_OUT(t,app)  =l=  p2h_inst(app)
;




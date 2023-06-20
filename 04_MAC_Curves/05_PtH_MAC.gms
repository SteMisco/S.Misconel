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
*                EQUATIONS FOR POWER-TO-HEAT AND HEAT STORAGES
*===============================================================================
*(PtH_a) heat balance
heat_dem(t)= sum((p2h,y), p2h_profile(t,'p2h','%year%') * char_app('p2h','dh_demand','%year%'))
;

heat_balance(t)..
           sum((p2h,y), p2h_profile(t,'p2h','%year%') * char_app('p2h','dh_demand','%year%'))
         + sum(hstor, HSTOR_IN(t,hstor) * 0.9 )

           =e=

           sum(p2h, P2H_OPT(t,p2h) * char_app('p2h','p2h_eta','%YEAR%'))
         + sum(hstor, HSTOR_OUT(t,hstor) / 0.9)
         + GAS_B(t)
         + sum(p_av, GP_CHP(t,p_av))
;

chp_must_run(t,p_av)$(char_p(p_av,'chp')=1)..
GP_CHP(t,p_av) =l= G_P(t,p_av) * sum(c, chp_factor(p_av,c))
;

GP_CHP.fx(t,p)$(NOT char_p(p,'chp')) = 0
;

*maximum of gas boiler capacity
maximum_gasboiler(t)..
GAS_B(t) =l= sum(p2h, p2h_max(p2h));


*(PtH_b) maximum of load increase by PtH
maximum_p2h(t,p2h)..
       P2H_OPT(t,p2h) =l=  p2h_new(p2h)
;

*PtH maximum full load hours
maximum_p2h_flh(p2h)..
sum(t, P2H_OPT(t,p2h)) =e= ((p2h_new(p2h) * char_app('p2h','p2h_flh','%YEAR%')) / 8760) * t_opt
;

*===============================================================================
*                        HEAT STORAGE DIS/CHARGING
*===============================================================================
*(PtH_c) Cumulative charging level in the first hour
hstor_chargelev_start(t,hstor)$( ord(t) = 1 )..
         HSTOR_L(t,hstor)   =e=  0.5 * p2h_new(hstor) * char_app(hstor,'EPR','%YEAR%')
                               +  HSTOR_IN(t,hstor) * 0.9
                               -  HSTOR_OUT(t,hstor) / 0.9
;

*(PtH_d) Cumulative charging level in hour h
hstor_chargelev(t,hstor)$ ( ord(t) > 1 ) ..
         HSTOR_L(t,hstor)   =e=  HSTOR_L(t-1,hstor)
                               +  HSTOR_IN(t,hstor) * 0.9
                               -  HSTOR_OUT(t,hstor) / 0.9
;

*(PtH_e) Cumulative maximal charging level
hstor_chargelev_max(t,hstor)..
         HSTOR_L(t,hstor) =l=   p2h_new(hstor) * char_app(hstor,'EPR','%YEAR%')
;

*(PtH_f) Cumulative charging level in the last hour
hstor_chargelev_ending(t,hstor)$( ord(t) = card(t) )..
         HSTOR_L(t,hstor)$( ord(t) = card(t) ) =e= 0.5 * p2h_new(hstor) * char_app(hstor,'EPR','%YEAR%')
;

hstor_charge_maxin(t,hstor)..
         HSTOR_IN(t,hstor) =l=  p2h_new(hstor)
;

*(PtH_g) Cumulative maximal charging limit
hstor_charge_maxin_level(t,hstor)..
         HSTOR_IN(t,hstor) * 0.9  =l=   p2h_new(hstor) * char_app(hstor,'EPR','%YEAR%')  - HSTOR_L(t-1,hstor)
;

hstor_charge_maxout(t,hstor)..
         HSTOR_OUT(t,hstor) =l= p2h_new(hstor)
;

*(PtH_h) Cumulative maximal discharging limit
hstor_discharge_maxout_level(t,hstor)..
         HSTOR_OUT(t,hstor) / 0.9 =l=   HSTOR_L(t-1,hstor)
;




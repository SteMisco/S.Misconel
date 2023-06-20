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
*                  EQUATIONS FOR POWER-TO-GAS AND H2-TANKS
*===============================================================================
*(PtG_a) H2 balance
h2_balance(t)..
              sum(p2g, h2_demand(t,p2g))
            + sum(h2stor, H2STOR_IN(t,h2stor)) * 0.9

           =e=

              sum(p2g, P2G_OPT(t,p2g)) * char_dev('p2g','p2p_eta','%YEAR%')
            + sum(h2stor, H2STOR_OUT(t,h2stor)) / 0.9
;

maximum_p2g(t,p2g)..
         P2G_OPT(t,p2g) =l= p2p_new(p2g)
;
*===============================================================================
*         POWER-TO-GAS-TO-POWER / H2 STORAGE AND FUEL CELLS GENERATION
*===============================================================================
*(PtG_e) Cumulative charging level in the first hour
h2stor_chargelev_start(t,h2stor)$( ord(t) = 1 )..
         H2STOR_L(t,h2stor) =e= 0.8 * p2p_new(h2stor) * char_dev(h2stor,'EPR_H2','%YEAR%')
                               +  H2STOR_IN(t,h2stor) * 0.9
                               -  H2STOR_OUT(t,h2stor) / 0.9
;

*(PtG_f) Cumulative charging level in hour h
h2stor_chargelev(t,h2stor)$ ( ord(t) > 1 ) ..
         H2STOR_L(t,h2stor) =e=  H2STOR_L(t-1,h2stor)
                                +  H2STOR_IN(t,h2stor) * 0.9
                                -  H2STOR_OUT(t,h2stor) / 0.9
;

*(PtG_g) Cumulative maximal charging level
h2stor_chargelev_max(t,h2stor)..
         H2STOR_L(t,h2stor) =l=   p2p_new(h2stor) * char_dev(h2stor,'EPR_H2','%YEAR%')
;

h2stor_charge_maxin(t,h2stor)..
         H2STOR_IN(t,h2stor) =l= sum(p2g$map_p2pG(h2stor,p2g), p2p_new(p2g))
;

*(PtG_i) Cumulative maximal charging limit
h2stor_charge_maxin_level(t,h2stor)..
         H2STOR_IN(t,h2stor) * 0.9 =l=  p2p_new(h2stor) * char_dev(h2stor,'EPR_H2','%YEAR%') - H2STOR_L(t-1,h2stor)
;

h2stor_charge_maxout(t,h2stor)..
         H2STOR_OUT(t,h2stor) =l= sum(p2g$map_p2pG(h2stor,p2g), p2p_new(p2g))
;

*(PtG_j) Cumulative maximal discharging limit
h2stor_discharge_maxout_level(t,h2stor)..
         H2STOR_OUT(t,h2stor) / 0.9  =l=   H2STOR_L(t-1,h2stor)
;

*(PtG_h) Cumulative charging level in the last hour
h2stor_chargelev_ending(t,h2stor)$( ord(t) = card(t) )..
         H2STOR_L(t,h2stor)$( ord(t) = card(t) ) =e= 0.8 * p2p_new(h2stor) * char_dev(h2stor,'EPR_H2','%YEAR%')
;



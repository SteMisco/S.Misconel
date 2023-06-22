*===============================================================================
*   Modeling investment and dispatch decisions for flexibility options,
*        especially optimization of dispatch decisions for demand-side-management,
*        for EU-27, UK, NO, CH, and Balkan countries
*   This research was funded by the European Commission as a part of
*        the collaborative project ‘REFLEX’, which was part of the European
*        Union’s Horizon 2020 research and innovation programme [GA–No.
*        691685].
*   This model was developed based on the ELTRAMOD model family of the
*        Chair of Energy Economics at TU Dresden, Germany
*   Author: Steffi Misconel (supported by Christoph Zöphel)
*   Last updated: 20.04.2020
*===============================================================================



*===============================================================================


*===============================================================================
*       MASTER FILE GAMS Options and General Adjustments
*===============================================================================

*Listing File
$onUNDF

*$offlisting offsymxref offsymlist
OPTION LIMROW = 100, LIMCOL = 100;
*SOLPRINT = silent;
OPTION profile = 10;
OPTION profiletol = 10;



*Begrenzung der Rechenzeit
option reslim = 1E9;
$set LoadExcel
$set RunModel
$set WriteExcel

*$set CounterfactMode

*$set From 1
*$set To 100
*$set Year y2014
*$set dsm_share 1.00
*$set dsm_ac_share 1.00
*$set prevYear y2040
*$set Run dsm100_cen100_200420

*Paths
$set data           data/MOD_input_cen
$set datatime       data/MOD_timeseries_%Year%_nonoptsyscen
$set dataNTC        data/NTC_cen
$set dataRES        data/RES_%Year%_cen100
$set dataP2X        data/P2X_cen
$set dataDSM        data/DSM_%Year%_cen
$set dataCnew       output/cap_new_%prevYear%_%Run%

$set resultfile1    output/results_dispatch_%Year%_%Run%
$set resultfile2    output/cap_new_%Year%_%Run%


$ifthen.master set LoadExcel
$set EnterInput
$endif.master
$ifthen.master set RunModel
$set EnterInput
$endif.master

*===============================================================================
*         data upload
*===============================================================================
$ifthen.master set EnterInput
$include 02_ELTRAMOD_input_cen.gms
$endif.master


*===============================================================================
*         model implementation
*===============================================================================
$ifthen.master set RunModel
$include 03_ELTRAMOD_invest_dispatch_cen.gms
$endif.master


*===============================================================================
*         model output
*===============================================================================
$include 04_ELTRAMOD_results_cen.gms



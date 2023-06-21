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
*   Last updated: 12.11.2019
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

$set From 1
$set To 100
$set Year y2014
*$set prevYear y2040
$set Run mod_191211

*Paths
$set data           data/MOD_input_mod
$set datatime       data/MOD_timeseries_%Year%_mod
$set dataNTC        data/NTC_mod
$set dataRES        data/RES_%Year%_mod
$set dataP2X        data/P2X_mod
$set dataCnew       output/cap_new_%prevYear%_%Run%

$set resultfile1    output/results_%Year%_%Run%
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
$include 02_ELTRAMOD_input_mod.gms
$endif.master


*===============================================================================
*         model implementation
*===============================================================================
$ifthen.master set RunModel
$include 03_ELTRAMOD_REFLEX_mod.gms
$endif.master


*===============================================================================
*         model output
*===============================================================================
$include 04_ELTRAMOD_results_mod.gms


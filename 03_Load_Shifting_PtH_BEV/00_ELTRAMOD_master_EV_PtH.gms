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
$set Year y2020
*$set prevYear y2016
$set WJ WJ16
$set Run 210302_TEST

*Paths
$set data           data\MOD_input
$set datatime       data\MOD_timeseries_%WJ%_%Year%
$set dataNTC        data\NTC
$set dataRES        data\RES_%WJ%_%Year%
$set dataEV         data\EV_%WJ%_%Year%
$set dataPtH        data\PtH_%WJ%
*$set dataCnew       output\cap_new_%WJ%_%prevYear%_%Run%
$set dataCnew       data\cap_new_%Year%

*$set resultfile1    output\cap_new_%WJ%_%Year%_%Run%
$set resultfile2    output\results_%WJ%_%Year%_%Run%


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
$include 01_ELTRAMOD_input_EV_PtH.gms
$endif.master


*===============================================================================
*         model implementation
*===============================================================================
$ifthen.master set RunModel
$include 02_ELTRAMOD_run_EV_PtH.gms
$endif.master


*===============================================================================
*         model output
*===============================================================================
$include 03_ELTRAMOD_results_EV_PtH.gms



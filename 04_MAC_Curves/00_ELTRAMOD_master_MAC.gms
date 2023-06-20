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
$set Year y2030
*$set FO ref
*$set refCase ref
*$set prevYear y2016
*$set Run It1_210819_2020

*Paths
$set data           data\MOD_input_%Year%
$set datatime       data\MOD_timeseries_%Year%
$set dataNTC        data\NTC_wo
*$set dataNTC        data\NTC
*$set dataEV         data\EV
*$set dataPtH        data\PtH
*$set dataCnew       output\cap_new_%Year%_%refCase%
*$set dataCnew       output\cap_new_%WJ%_%prevYear%_%Run%

*$set resultfile1    output\cap_new_%Year%_%FO%_%Run%
*$set resultfile2    output\results_%Year%_%FO%_%Run%

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
$include 01_ELTRAMOD_input_MAC.gms
$endif.master


*===============================================================================
*         model implementation
*===============================================================================
$ifthen.master set RunModel
$include 02_ELTRAMOD_run_MAC.gms
$endif.master





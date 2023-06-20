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

*--------------------------------------------------------------------------------------------*
*                call function to start model runs
*--------------------------------------------------------------------------------------------*

$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ16    --Run=210302  --From=1   --To=8760   --Year=y2020
$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ16    --Run=210302  --From=1   --To=8760   --Year=y2025
$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ16    --Run=210302  --From=1   --To=8760   --Year=y2030

$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ12    --Run=210302  --From=1   --To=8760   --Year=y2020
$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ12    --Run=210302  --From=1   --To=8760   --Year=y2025
$call gams   00_ELTRAMOD_master_EV_PtH.gms   --WJ=WJ12    --Run=210302  --From=1   --To=8760   --Year=y2030

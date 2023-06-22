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


*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*
*            call function to start model runs
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_cen100_200420         --dsm_share=1.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_cen100_200420         --dsm_share=1.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_cen100_200420         --dsm_share=1.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_cen100_200420         --dsm_share=1.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_cen100_200420         --dsm_share=1.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_cen100_200420          --dsm_share=0.50     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_cen100_200420          --dsm_share=0.50     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_cen100_200420          --dsm_share=0.50     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_cen100_200420          --dsm_share=0.50     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_cen100_200420          --dsm_share=0.50     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm25_cen100_200420          --dsm_share=0.25     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm25_cen100_200420          --dsm_share=0.25     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm25_cen100_200420          --dsm_share=0.25     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm25_cen100_200420          --dsm_share=0.25     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm25_cen100_200420          --dsm_share=0.25     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm75_cen100_200420          --dsm_share=0.75     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm75_cen100_200420          --dsm_share=0.75     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm75_cen100_200420          --dsm_share=0.75     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm75_cen100_200420          --dsm_share=0.75     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm75_cen100_200420          --dsm_share=0.75     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm0_cen100_200420           --dsm_share=0.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm0_cen100_200420           --dsm_share=0.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm0_cen100_200420           --dsm_share=0.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm0_cen100_200420           --dsm_share=0.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm0_cen100_200420           --dsm_share=0.00     --dsm_ac_share=1.00     --From=1   --To=8760   --Year=y2050   --prevYear=y2040

*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac2.00_cen100_200420  --dsm_share=1.00   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac2.00_cen100_200420  --dsm_share=1.00   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac2.00_cen100_200420  --dsm_share=1.00   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac2.00_cen100_200420  --dsm_share=1.00   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac2.00_cen100_200420  --dsm_share=1.00   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac2.00_cen100_200420   --dsm_share=0.50   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac2.00_cen100_200420   --dsm_share=0.50   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac2.00_cen100_200420   --dsm_share=0.50   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac2.00_cen100_200420   --dsm_share=0.50   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac2.00_cen100_200420   --dsm_share=0.50   --dsm_ac_share=2.00       --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac50_cen100_200420    --dsm_share=1.00   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac50_cen100_200420    --dsm_share=1.00   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac50_cen100_200420    --dsm_share=1.00   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac50_cen100_200420    --dsm_share=1.00   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm100_ac50_cen100_200420    --dsm_share=1.00   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac50_cen100_200420     --dsm_share=0.50   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac50_cen100_200420     --dsm_share=0.50   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac50_cen100_200420     --dsm_share=0.50   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac50_cen100_200420     --dsm_share=0.50   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms    --Run=dsm50_ac50_cen100_200420     --dsm_share=0.50   --dsm_ac_share=0.50       --From=1   --To=8760   --Year=y2050   --prevYear=y2040



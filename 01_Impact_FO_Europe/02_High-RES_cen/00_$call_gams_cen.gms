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
*   Last updated: 12.12.2019
*===============================================================================

*--------------------------------------------------------------------------------------------------------*
*                call function to start model runs
*--------------------------------------------------------------------------------------------------------*

$call gams   01_ELTRAMOD_master_cen.gms            --Run=cen_191112       --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen.gms            --Run=cen_191112       --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen.gms            --Run=cen_191112       --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen.gms            --Run=cen_191112       --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen.gms            --Run=cen_191112       --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_cen100.gms         --Run=cen100_191112    --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_cen100.gms         --Run=cen100_191112    --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_cen100.gms         --Run=cen100_191112    --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_cen100.gms         --Run=cen100_191112    --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_cen100.gms         --Run=cen100_191112    --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_nonoptsyscen.gms   --Run=nonoptsyscen_191112    --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_nonoptsyscen.gms   --Run=nonoptsyscen_191112    --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_nonoptsyscen.gms   --Run=nonoptsyscen_191112    --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_nonoptsyscen.gms   --Run=nonoptsyscen_191112    --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_nonoptsyscen.gms   --Run=nonoptsyscen_191112    --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_battery50_cen.gms  --Run=battery50_cen_191112   --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_battery50_cen.gms  --Run=battery50_cen_191112   --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_battery50_cen.gms  --Run=battery50_cen_191112   --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_battery50_cen.gms  --Run=battery50_cen_191112   --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_battery50_cen.gms  --Run=battery50_cen_191112   --From=1   --To=8760   --Year=y2050   --prevYear=y2040

$call gams   01_ELTRAMOD_master_NTC_delay_cen.gms  --Run=NTC_delay_cen_191112   --From=1   --To=8760   --Year=y2014
$call gams   01_ELTRAMOD_master_NTC_delay_cen.gms  --Run=NTC_delay_cen_191112   --From=1   --To=8760   --Year=y2020   --prevYear=y2014
$call gams   01_ELTRAMOD_master_NTC_delay_cen.gms  --Run=NTC_delay_cen_191112   --From=1   --To=8760   --Year=y2030   --prevYear=y2020
$call gams   01_ELTRAMOD_master_NTC_delay_cen.gms  --Run=NTC_delay_cen_191112   --From=1   --To=8760   --Year=y2040   --prevYear=y2030
$call gams   01_ELTRAMOD_master_NTC_delay_cen.gms  --Run=NTC_delay_cen_191112   --From=1   --To=8760   --Year=y2050   --prevYear=y2040

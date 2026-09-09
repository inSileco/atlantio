# Atlantis parameter set

To access the set of parameter included in Atlantis as of version
3-6722, use:

``` r

# only version 3-6722 is available
atl  <- list_atlantis_parameters(version = "3-6722")
atl$meta[1:3]
#> $atlantis_source
#> [1] "AtlantisTrunk/atlantis"
#> 
#> $atlantis_version
#> [1] 3.6722
#> 
#> $bm_struct
#> [1] "MSEBoxModel"
atl$parameters[1:2]
#> [[1]]
#> [[1]]$name
#> [1] "include_atmosphere"
#> 
#> [[1]]$description
#> [1] "Switch enabling the atmospheric exchange concentrations block"
#> 
#> [[1]]$source_file
#> [1] "physics_prm"
#> 
#> [[1]]$value_type
#> [1] "int"
#> 
#> [[1]]$dimension
#> [1] "scalar"
#> 
#> [[1]]$units
#> NULL
#> 
#> [[1]]$bm_member
#> [1] "bm->include_atmosphere"
#> 
#> [[1]]$reader
#> [[1]]$reader$fn
#> [1] "readkeyprm_i"
#> 
#> [[1]]$reader$at
#> [1] "atphysics/atphysics.c:229"
#> 
#> [[1]]$reader$check
#> [1] "none"
#> 
#> 
#> [[1]]$conditional_on
#> NULL
#> 
#> 
#> [[2]]
#> [[2]]$name
#> [1] "atmospheric_NH"
#> 
#> [[2]]$description
#> [1] "Atmospheric ammonia concentration"
#> 
#> [[2]]$source_file
#> [1] "physics_prm"
#> 
#> [[2]]$value_type
#> [1] "double"
#> 
#> [[2]]$dimension
#> [1] "scalar"
#> 
#> [[2]]$units
#> [1] "mg N m-3"
#> 
#> [[2]]$bm_member
#> [1] "bm->atmospheric_NH"
#> 
#> [[2]]$reader
#> [[2]]$reader$fn
#> [1] "readkeyprm_d"
#> 
#> [[2]]$reader$at
#> [1] "atphysics/atphysics.c:233"
#> 
#> [[2]]$reader$check
#> [1] "none"
#> 
#> 
#> [[2]]$conditional_on
#> [1] "bm->include_atmosphere"
```

The table below display the entire set of parameters, note that the
followwing abbreviations are used: - : groups abbreviation - :
fisheries - : cohort - : move group code - : tracer name

## Biology parameters

### Biology

| Name | Description | Units | Type | Dimension |
|:---|:---|:---|:---|:---|
| ecotest | Ecology test/diagnostic verbosity flag |  | int | scalar |
| availflag | Switch controlling how prey availability is interpreted |  | int | scalar |
| flagrandom | Enable stochastic/random processes |  | int | scalar |
| readin_popratio | Read population ratio (stock) data flag |  | int | scalar |
| flagresp | Respiration submodel flag |  | int | scalar |
| flagavgmig | Average migration flag |  | int | scalar |
| flagbactstim | Bacterial stimulation flag |  | int | scalar |
| flagtrackpops | Track populations flag |  | int | scalar |
| flagseason | Seasonal forcing flag |  | int | scalar |
| flaglight | Light limitation model flag |  | int | scalar |
| flaglightopt | Light optimisation option |  | int | scalar |
| lim_sun_hours | Limit primary production to daylight hours flag |  | int | scalar |
| flagmodeltemp | Temperature dependence model flag |  | int | scalar |
| flagq10 | Global Q10 temperature scaling flag |  | int | scalar |
| O2case | Oxygen limitation case selector |  | int | scalar |
| flagnut | Nutrient limitation flag |  | int | scalar |
| flagmicro | Microbial loop flag |  | int | scalar |
| flagtempchange | Apply prescribed temperature change flag |  | int | scalar |
| flagsaltchange | Apply prescribed salinity change flag |  | int | scalar |
| flagpHchange | Apply prescribed pH change flag |  | int | scalar |
| flagstarve | Starvation mortality flag |  | int | scalar |
| flagdegrade | Detritus degradation flag |  | int | scalar |
| flagroc | Rate-of-change effects flag |  | int | scalar |
| flaghomog_sp | Homogeneous spatial distribution flag |  | int | scalar |
| flagagestruct | Age structure global flag |  | int | scalar |
| flagsenesce | Senescence mortality flag |  | int | scalar |
| flagtsforcerecruit | Time-series forced recruitment flag |  | int | scalar |
| flag_modify_KWSR | Modify weight-at-spawn ratio flag |  | int | scalar |
| flag_extpop_growth_option | External population growth option |  | int | scalar |
| juv_transition_thresh | Juvenile-to-adult size transition threshold |  | double | scalar |
| mat_transition_thresh | Maturity transition threshold |  | double | scalar |
| norm_larval_distrib | Normalise larval distribution flag |  | int | scalar |
| larvae_connect_only | Larvae connectivity-only flag |  | int | scalar |
| enviro_independ_larvae | Environment-independent larvae flag |  | int | scalar |
| flag_recruit_effect | Recruitment environmental effect flag |  | int | scalar |
| flag_macro_model | Macrophyte/seagrass model flag |  | int | scalar |
| flag_benthos_sediment_link | Benthos-sediment coupling flag |  | int | scalar |
| flag_competing_epiff | Competing epibenthic filter feeders flag |  | int | scalar |
| max_available_habitat | Maximum available habitat fraction |  | double | scalar |
| flag_invert_biohab | Invertebrate biogenic habitat flag |  | int | scalar |
| flag_olddiet | Use legacy diet handling flag |  | int | scalar |
| flag_fine_ontogenetic_diets | Fine-grained per-age diet matrices flag |  | int | scalar |
| UseHardFeedingWindow | Use hard (step) feeding window flag |  | int | scalar |
| UseBiLogisticFeedingWindow | Use bi-logistic feeding window flag |  | int | scalar |
| flag_satiation | Predator satiation flag |  | int | scalar |
| flag_shrinkfat | Allow shrinking/fat loss flag |  | int | scalar |
| flag_predratiodepend | Ratio-dependent predation flag |  | int | scalar |
| flag_dynamicXRS | Dynamic reserve/structural ratio flag |  | int | scalar |
| flag_repcostSpawn | Reproduction cost at spawning flag |  | int | scalar |
| flag_lengthSN | Length from structural N flag |  | int | scalar |
| XRS_cap | Cap on reserve-to-structural ratio |  | double | scalar |
| flag_rel_cover | Relative cover model flag |  | int | scalar |
| flag_report_water_detritus | Report water-column detritus flag |  | int | scalar |
| flag_refuge_model | Prey refuge model flag |  | int | scalar |
| flag_rugosity_model | Rugosity model flag |  | int | scalar |
| flag_georugosity | Geological (background) rugosity flag |  | int | scalar |
| RugCover_Coefft | Rugosity-cover relationship coefficient |  | double | scalar |
| RugCover_Const | Rugosity-cover relationship constant |  | double | scalar |
| RugCover_Cap | Rugosity-cover relationship cap |  | double | scalar |
| min_rugosity | Minimum rugosity |  | double | scalar |
| max_rugosity | Maximum rugosity |  | double | scalar |
| rugosity_const | Rugosity baseline constant |  | double | scalar |
| rugosity_bozec_a | Bozec rugosity model coefficient a |  | double | scalar |
| rugosity_bozec_b | Bozec rugosity model coefficient b |  | double | scalar |
| rugosity_bozec_c | Bozec rugosity model coefficient c |  | double | scalar |
| rugosity_bozec_d | Bozec rugosity model coefficient d |  | double | scalar |
| flagmodelpH | pH dynamics model flag |  | int | scalar |
| pH_sensitivity_model | pH sensitivity model selector |  | int | scalar |
| flagPHmortcase | pH mortality case selector |  | int | scalar |
| pH_surface_depth | Surface pH layer depth boundary | m | double | scalar |
| pH_mid_depth | Mid pH layer depth boundary | m | double | scalar |
| pH_surface_coefft_T | Surface pH regression coefficient on temperature |  | double | scalar |
| pH_surface_coefft_S | Surface pH regression coefficient on salinity |  | double | scalar |
| pH_surface_coefft_O | Surface pH regression coefficient on oxygen |  | double | scalar |
| pH_surface_const | Surface pH regression constant |  | double | scalar |
| pH_mid_coefft_T | Mid-layer pH regression coefficient on temperature |  | double | scalar |
| pH_mid_coefft_S | Mid-layer pH regression coefficient on salinity |  | double | scalar |
| pH_mid_coefft_O | Mid-layer pH regression coefficient on oxygen |  | double | scalar |
| pH_mid_const | Mid-layer pH regression constant |  | double | scalar |
| pH_deep_coefft_T | Deep-layer pH regression coefficient on temperature |  | double | scalar |
| pH_deep_coefft_S | Deep-layer pH regression coefficient on salinity |  | double | scalar |
| pH_deep_coefft_O | Deep-layer pH regression coefficient on oxygen |  | double | scalar |
| pH_deep_const | Deep-layer pH regression constant |  | double | scalar |
| flagmodelArag | Aragonite saturation model flag |  | int | scalar |
| K_max_num_DHW | Max number of degree heating weeks records |  | int | scalar |
| Karag_A | Aragonite regression coefficient A |  | double | scalar |
| Karag_B | Aragonite regression coefficient B |  | double | scalar |
| Karag_C | Aragonite regression coefficient C |  | double | scalar |
| Karag_pH | Aragonite regression coefficient on pH |  | double | scalar |
| Kca_const | Calcium constant for calcification |  | double | scalar |
| K_Ks | Calcification saturation half-constant |  | double | scalar |
| Ksmother_coefft | Smothering coefficient |  | double | scalar |
| Ksmother_const | Smothering constant |  | double | scalar |
| Pads_r_t0 | Phosphate adsorption rate at reference temp |  | double | scalar |
| Pads_K | Phosphate adsorption half-saturation |  | double | scalar |
| Pads_KO | Phosphate adsorption oxygen dependence |  | double | scalar |
| r_immob_PIP_t0 | Particulate inorganic P immobilisation rate at reference temp |  | double | scalar |
| Enviro_turb | Environmental turbidity switch |  | int | scalar |
| K_TUR | Turbidity half-saturation |  | double | scalar |
| K_TUR_DEP | Turbidity depth dependence |  | double | scalar |
| K_MAX_TUR | Maximum turbidity |  | double | scalar |
| K_IRR | Irradiance half-saturation |  | double | scalar |
| K_MAX_IRR | Maximum irradiance |  | double | scalar |
| K_MIN_IRR | Minimum irradiance |  | double | scalar |
| r_DC_T15 | Labile detritus carbon breakdown rate at 15C | d-1 | double | scalar |
| r_DL_T15 | Labile detritus breakdown rate at 15C | d-1 | double | scalar |
| r_DR_T15 | Refractory detritus breakdown rate at 15C | d-1 | double | scalar |
| r_DON_T15 | Dissolved organic N breakdown rate at 15C | d-1 | double | scalar |
| r_DSi_T15 | Dissolved silica regeneration rate at 15C | d-1 | double | scalar |
| FDR_DC | Fraction of refractory detritus to DC |  | double | scalar |
| FDR_DL | Fraction of refractory detritus to DL |  | double | scalar |
| FDON_D | Fraction of detritus to DON |  | double | scalar |
| R_0_T15 | Base remineralisation rate at 15C | d-1 | double | scalar |
| R_D_T15 | Detritus remineralisation rate at 15C | d-1 | double | scalar |
| Dmax | Maximum depth for remineralisation | m | double | scalar |
| K_nit_T15 | Nitrification rate at 15C | d-1 | double | scalar |
| K_conc | Nitrification concentration half-saturation |  | double | scalar |
| p_NH_anad | Proportion NH from anaerobic decomposition |  | double | scalar |
| X_ON | Oxygen-to-nitrogen Redfield ratio |  | double | scalar |
| X_CN | Carbon-to-nitrogen Redfield ratio |  | double | scalar |
| X_CHLN | Chlorophyll-to-nitrogen ratio |  | double | scalar |
| X_SiN | Silica-to-nitrogen ratio |  | double | scalar |
| X_FeN | Iron-to-nitrogen ratio |  | double | scalar |
| k_wetdry | Wet/dry weight conversion factor |  | double | scalar |
| k_w_cdepth | Light attenuation coefficient at critical depth | m-1 | double | scalar |
| k_w_depth | Light attenuation coefficient with depth | m-1 | double | scalar |
| k_w_deep | Deep-water light attenuation coefficient | m-1 | double | scalar |
| k_w_shallow | Shallow-water light attenuation coefficient | m-1 | double | scalar |
| k_PN | Light attenuation per unit particulate N |  | double | scalar |
| k_DON | Light attenuation per unit DON |  | double | scalar |
| k_DL | Light attenuation per unit labile detritus |  | double | scalar |
| k_IS | Light attenuation per unit inorganic suspended matter |  | double | scalar |
| k_SED | Light attenuation per unit sediment |  | double | scalar |
| KIOP_min | Minimum I-optimal half-saturation |  | double | scalar |
| KIOP_shift | I-optimal shift parameter |  | double | scalar |
| KI_avail | Irradiance availability scalar |  | double | scalar |
| K_addepth | Additional depth offset for light calc | m | double | scalar |
| swr_scalar | Shortwave radiation scaling factor |  | double | scalar |
| swr_const | Shortwave radiation constant |  | double | scalar |
| swr_cos_coefft | Shortwave radiation seasonal cosine coefficient |  | double | scalar |
| swr_cos_offset | Shortwave radiation seasonal cosine offset |  | double | scalar |
| albedo_ice | Ice albedo |  | double | scalar |
| k_bs | Light attenuation under bare snow |  | double | scalar |
| k_bi | Light attenuation under bare ice |  | double | scalar |
| k_rs | Light attenuation under refrozen snow |  | double | scalar |
| k_ri | Light attenuation under refrozen ice |  | double | scalar |
| R_bi | Reflectance of bare ice |  | double | scalar |
| k_ice | Light attenuation coefficient for ice | m-1 | double | scalar |
| ka_star | Specific light absorption coefficient |  | double | scalar |
| Tchange_max_num | Number of prescribed temperature-change records |  | int | scalar |
| Tchange | Prescribed temperature-change time-series (value/time pairs) | degC | double_array | timeseries |
| Schange_max_num | Number of prescribed salinity-change records |  | int | scalar |
| Schange | Prescribed salinity-change time-series |  | double_array | timeseries |
| pHchange_max_num | Number of prescribed pH-change records |  | int | scalar |
| PHchange | Prescribed pH-change time-series |  | double_array | timeseries |
| RTOP | Top of refuge tolerance |  | double | scalar |
| K_Lc | Critical light constant |  | double | scalar |
| RelTol | Relative numerical tolerance |  | double | scalar |
| Flux_tol | Flux tolerance threshold |  | double | scalar |
| min_pool | Minimum tracer pool concentration |  | double | scalar |
| min_dens | Minimum density threshold |  | double | scalar |
| min_channel_depth | Minimum channel depth | m | double | scalar |
| flag_do_var_express | Variable expression flag (evolution) |  | int | scalar |
| flag_do_evolution | Enable evolution module |  | int | scalar |
| flag_bound_change | Allow trait bound change flag |  | int | scalar |
| flag_inheritance | Trait inheritance flag |  | int | scalar |
| flag_evolvar_capped | Cap evolved variance flag |  | int | scalar |
| evol_stdev_range | Evolutionary standard deviation range |  | double | scalar |
| max_rate_evol | Maximum rate of evolutionary change |  | double | scalar |
| flag_mult_grow_curves | Multiple growth morph curves flag |  | int | scalar |
| ActiveTrait/\<GRP\> | Per-group active evolutionary trait flags (one row of trait toggles per group) |  | double_array | per_group |
| MB_wc | Microbial biomass water-column reference |  | double | scalar |
| eddy_scale | Eddy diffusivity scaling for PP |  | double | scalar |
| XPB_DL | Fraction of PB flux to labile detritus |  | double | scalar |
| XBB_DL | Fraction of BB flux to labile detritus |  | double | scalar |
| XPB_DR | Fraction of PB flux to refractory detritus |  | double | scalar |
| XBB_DR | Fraction of BB flux to refractory detritus |  | double | scalar |
| k_PB | Pelagic bacteria rate constant |  | double | scalar |
| k_BB | Benthic bacteria rate constant |  | double | scalar |
| flaghabdepend | Habitat-dependent processes flag |  | int | scalar |
| flag_move_habdepend | Habitat-dependent movement flag |  | int | scalar |
| flagenviro_displace | Environmental displacement flag |  | int | scalar |
| flagenviro_kill | Environmental kill flag |  | int | scalar |
| REEFchange_max_num | Number of reef-cover change records |  | int | scalar |
| FLATchange_max_num | Number of flat-cover change records |  | int | scalar |
| SOFTchange_max_num | Number of soft-cover change records |  | int | scalar |
| REEFchange | Reef-substrate cover change time-series |  | double_array | timeseries |
| FLATchange | Flat-substrate cover change time-series |  | double_array | timeseries |
| SOFTchange | Soft-substrate cover change time-series |  | double_array | timeseries |
| Group_Habitat_Preference/\<GRP\> | Per-group habitat preference array over habitat types |  | double_array | per_group |
| Group_Ice_Preference/\<GRP\> | Per-group ice habitat preference array |  | double_array | per_group |
| Group_IceReprod_Preference/\<GRP\> | Per-group ice reproduction preference array |  | double_array | per_group |
| roc_wgt | Rate-of-change weighting |  | double | scalar |
| k_roc_food | Rate-of-change food scaling constant |  | double | scalar |
| flagtempdepend_move | Temperature-dependent movement flag |  | int | scalar |
| flagtempdepend_reprod | Temperature-dependent reproduction flag |  | int | scalar |
| flagsaltdepend | Salinity-dependent processes flag |  | int | scalar |
| flagO2depend | Oxygen-dependent processes flag |  | int | scalar |
| flagconstrain_epiwander | Constrain epibenthic wandering flag |  | int | scalar |
| X_RS | Reserve-to-structural target ratio |  | double | scalar |
| Kthresh1 | Movement/feeding threshold constant 1 (read twice; two threshold slots) |  | double | scalar |
| KHTD | Habitat threshold constant (deep) |  | double | scalar |
| KHTI | Habitat threshold constant (intertidal) |  | double | scalar |
| SeasonalDistribution/\<GRP\>/\<STAGE\> | Per-group/per-stage seasonal horizontal distribution (juvenile/adult, per box) |  | double_array | per_box |
| p_BBfish | Proportion bacteria cleaned from fish-ingested detritus |  | double | scalar |
| p_BBben | Proportion bacteria cleaned from benthic-ingested detritus |  | double | scalar |
| p_PBwc | Proportion of pelagic bacteria available in water column |  | double | scalar |
| p_PBben | Proportion of pelagic bacteria available in benthos |  | double | scalar |
| k_refDL | Reference labile-detritus level for omnivore supplement feeding |  | double | scalar |
| k_refDR | Reference refractory-detritus level for supplement feeding |  | double | scalar |
| k_refsDL | Reference sediment labile-detritus level |  | double | scalar |
| flagfishrates | Use fish-specific clearance/growth rates flag |  | int | scalar |
| li_a_invert | Length-weight allometry coefficient a for invertebrates |  | double | scalar |
| li_b_invert | Length-weight allometry exponent b for invertebrates |  | double | scalar |
| pPREY\<PREDCOHORT\>\<PRED\>\<PREYCOHORT\> | Vertebrate predator-prey availability matrix (pSPVERTeat), availability of each prey group to a predator age class |  | double_array | per_prey |
| pPREY\<PRED\> | Invertebrate/biomass-pool predator-prey availability row (single cohort) |  | double_array | per_prey |
| DetritusSedimentFoodAvail/\<GRP\>\[/\<COHORT\>\] | Availability of detritus/sediment groups to a predator (per detritus group, per cohort for age-structured) |  | double_array | per_prey |
| AgeDietAvail/\<GRP\> | Fine ontogenetic (per-age) prey availability matrix |  | double_array | per_prey |
| SeagrassFoodAvail/\<GRP\> | Availability of seagrass/macrophyte parts to grazers |  | double_array | per_prey |
| Supplemental_Diets/\<GRP\> | Imported/supplemental feed distribution per box for cultured/supplemented groups |  | double_array | per_box |
| Catch_Opportunity/Catch_Availability/\<GRP\> | Availability of fishery catch to opportunistic catch-eaters (per prey group) |  | double_array | per_prey |
| Catch_Opportunity/Proportion_Exploitable/\<GRP\> | Proportion of each fishery’s catch exploitable by catch-eaters |  | double_array | other |
| C\_\<GRP\> | Per-cohort vertebrate clearance (search-volume) rate; prm key C\_\<GRP\> array over age classes | m3 (mg N)-1 d-1 | double_array | per_cohort |
| C\_\<GRP\>\_T15 | Invertebrate grazer clearance rate at 15C; scalar per group | m3 (mg N)-1 d-1 | double | per_group |
| mum\_\<GRP\> | Per-cohort vertebrate maximum growth (consumption) rate; prm key mum\_\<GRP\> array over age classes | mg N d-1 (per individual) | double_array | per_cohort |
| mum\_\<GRP\>\_T15 | Invertebrate/PP/bacteria maximum growth rate at 15C; scalar per group | d-1 | double | per_group |
| InvertebrateSN/\<GRP\> | Invertebrate structural-N (size) reference per group | mg N | double_array | per_group |
| Q10 | Global Q10 temperature scaling factor |  | double | scalar |
| temp_coefftB | Temperature response coefficient B |  | double | scalar |
| temp_coefftC | Temperature response coefficient C |  | double | scalar |
| temp_exp | Temperature response exponent |  | double | scalar |
| KST_fish | Standard metabolic temperature scalar - fish |  | double | scalar |
| KST_shark | Standard metabolic temperature scalar - shark |  | double | scalar |
| KST_bird | Standard metabolic temperature scalar - bird |  | double | scalar |
| KST_mammal | Standard metabolic temperature scalar - mammal |  | double | scalar |
| Ktmp_fish | Temperature respiration coefficient - fish |  | double | scalar |
| Ktmp_shark | Temperature respiration coefficient - shark |  | double | scalar |
| Ktmp_bird | Temperature respiration coefficient - bird |  | double | scalar |
| Ktmp_mammal | Temperature respiration coefficient - mammal |  | double | scalar |
| Kthreshm | Mortality threshold constant |  | double | scalar |
| FFDDR | Fraction of feeding-derived detritus going to refractory pool |  | double | scalar |
| FDL_fish | Fraction labile detritus from fish mortality |  | double | scalar |
| FDL_benth | Fraction labile detritus from benthic invert mortality |  | double | scalar |
| FDL_top | Fraction labile detritus from top predator mortality |  | double | scalar |
| FDL_wc | Fraction labile detritus from water-column group mortality |  | double | scalar |
| FDL_SG_roots | Fraction labile detritus from seagrass roots |  | double | scalar |
| FDL_SG_leaves | Fraction labile detritus from seagrass leaves |  | double | scalar |
| FPB_DR | Fraction pelagic-bacteria flux to refractory detritus |  | double | scalar |
| FBB_DR | Fraction benthic-bacteria flux to refractory detritus |  | double | scalar |
| FPB_DON | Fraction pelagic-bacteria flux to DON |  | double | scalar |
| FBB_DON | Fraction benthic-bacteria flux to DON |  | double | scalar |
| Fben_den | Fraction benthic denitrification |  | double | scalar |
| ImplicitSeabirdMortalityRate/\<GRP\> | Implicit (external) seabird mortality rate per group | d-1 | double_array | per_group |
| ImplicitFishMortalityRate/\<GRP\> | Implicit (external) fish mortality rate per group | d-1 | double_array | per_group |
| flagtrecruitdistrib | Time-varying recruit distribution flag |  | int | scalar |
| recover_trigger | Population recovery trigger level |  | double | scalar |
| recover_span | Recovery span duration |  | double | scalar |
| recover_subseq | Subsequent recovery parameter |  | double | scalar |
| lognorm_mu | Lognormal recruitment mean parameter |  | double | scalar |
| lognorm_sigma | Lognormal recruitment standard deviation parameter |  | double | scalar |
| rec_m | Recruitment mean (stochastic) parameter |  | double | scalar |
| rec_sigma | Recruitment standard deviation parameter |  | double | scalar |
| recruitRange | Recruitment search range |  | double | scalar |
| recruitRangeFlat | Flat recruitment range |  | double | scalar |
| ref_chl | Reference chlorophyll for recruitment effect |  | double | scalar |
| FSPB\_\<GRP\> | Per-cohort proportion of spawning biomass; prm key FSPB\_\<GRP\> array over age classes |  | double_array | per_cohort |
| KDENR\_\<GRP\> | Per-cohort density-dependent recruitment parameter (Reproduction/KDENR) |  | double_array | per_cohort |
| recSTOCK\_\<GRP\> | Per-stock recruitment allocation (Reproduction/recSTOCK) |  | double_array | other |
| popratioStock\_\<GRP\> | Per-stock population ratio at initialisation (Reproduction/popratioStock) |  | double_array | other |
| pStock\_\<GRP\> | Per-stock diet/spatial proportion (Diet/pStock) |  | double_array | other |
| VerticalRecruitLocation/\<GRP\> | Per-group vertical layer distribution for recruits |  | double_array | per_layer |
| RecruitDistribution/\<GRP\> | Per-group horizontal recruit distribution over boxes |  | double_array | per_box |
| AquacultDistribution/\<GRP\> | Per-group horizontal aquaculture stocking distribution over boxes |  | double_array | per_box |
| \<GRP\>\_Time_Spawn | Per-spawn-event spawning time-of-year per group (prm key \*\_Time_Spawn) | day-of-year | int_array | per_cohort |
| Time_Age\_\<GRP\> | Per-event time-to-age cohort entry per group (prm key Time_Age\_\<GRP\>) | day | int_array | per_cohort |
| StockStructure/\<GRP\> | Per-group per-box stock membership (integer stock id per box) |  | int_array | per_box |
| VerticalStockStructure/\<GRP\> | Per-group per-layer vertical stock membership |  | int_array | per_layer |
| invading_sp_model | Invading-species model flag |  | int | scalar |
| InvaderIndex | Functional-group index of the invader |  | int | scalar |
| minInvaderAge | Minimum age of invading individuals |  | int | scalar |
| maxInvaderAge | Maximum age of invading individuals |  | int | scalar |
| InvaderEntryBox | Box index where invader enters |  | int | scalar |
| InvadersEntering | Number of invaders entering |  | double | scalar |
| InvaderMinDepth | Minimum entry depth for invader | m | double | scalar |
| InvaderMaxDepth | Maximum entry depth for invader | m | double | scalar |
| InvaderStartDay | Day-of-year invasion starts | day-of-year | int | scalar |
| InvaderEndDay | Day-of-year invasion ends | day-of-year | int | scalar |
| InvaderScalar | Scaling of invader numbers |  | double | scalar |
| InvaderSpeed | Invader movement speed |  | double | scalar |
| InvaderEntryLayer | Vertical layer of invader entry |  | int | scalar |
| p_IBice | Proportion of biota associated with ice |  | double | scalar |
| flag_dissolved_pollutants | Track dissolved pollutants flag |  | int | scalar |
| flag_contamMortModel | Contaminant mortality model flag |  | int | scalar |
| flag_contamInteractModel | Contaminant interaction model flag |  | int | scalar |
| flag_contamGrowthModel | Contaminant growth-effect model flag |  | int | scalar |
| flag_contamReprodModel | Contaminant reproduction-effect model flag |  | int | scalar |
| flag_contamOnlyAmplify | Contaminant amplify-only flag |  | int | scalar |
| flag_contamMove | Contaminant movement flag |  | int | scalar |
| flag_contamMinTemp | Contaminant minimum-temperature flag |  | int | scalar |
| flag_contam_halflife_spbased | Species-based contaminant half-life flag |  | int | scalar |
| flag_contamMaternalTransfer | Maternal contaminant transfer flag |  | int | scalar |
| flag_contam_distrib | Contaminant distribution flag |  | int | scalar |
| biopools_dodge_contam | Biological pools bypass contaminant flag |  | int | scalar |
| min_pool_cont | Minimum contaminant pool concentration |  | double | scalar |
| contam_tau | Contaminant decay time constant |  | double | scalar |
| contam_sig_uptake_const | Contaminant sigmoidal uptake constant |  | double | scalar |
| flag_detritus_contam | Detritus contaminant tracking flag |  | int | scalar |
| k_migslow | Migration slowdown constant |  | double | scalar |
| Migration/MigrateIOBox/\<GRP\>\[/\<COHORT\>\]/Migrate\<N\> | Per-migration destination box proportions for migrating groups |  | double_array | per_box |
| Migration/KMIG_DEN/\<GRP\> | Initial density of pre-existing out-of-model migrators |  | double_array | per_cohort |
| Migration/KMIG_RN/\<GRP\> | Initial reserve N of pre-existing out-of-model migrators | mg N | double_array | per_cohort |
| Migration/KMIG_SN/\<GRP\> | Initial structural N of pre-existing out-of-model migrators | mg N | double_array | per_cohort |
| Migration/KMIG_INVERT\<N\>/\<GRP\> | Initial density of out-of-model invertebrate migrators per migration |  | double_array | per_cohort |
| flag\<GRP\> | Group functioning (on/off) flag |  | int | per_group |
| flagdem\<GRP\> | Preferred-location (demersal) trend flag |  | int | per_group |
| flagplankfish\<GRP\> | Planktivore flag |  | int | per_group |
| \<GRP\>thresh | Flux threshold for sediment/bacteria flux |  | double | per_group |
| \<GRP\>damp | Flux damping coefficient |  | double | per_group |
| SPECIES_FAMILY Reproduction_flags | Per-group reproduction flags and parameters. One entry each, prm key = base_GRP: flagbearlive (live-bearing), feed_while_spawn, flagmother (parental care), flagrecruit (recruitment function id), flagrecpeak, flagstocking, flagkeep_plusgroup, Recruit_Period, *Recruit_Time, *cohort_recruit_entry, *spawn_period, KSPA* (spawn area), FSP* (spawn fraction), Kcov_juv*/Bcov_juv\_/Acov_juv\_/Kcov_ad\_/Bcov_ad\_/Acov_ad\_ (cover coeffts), RugCover_scalar, *age_mat (age at maturity), recover_start, KWSR*, KWRR\_, recover_mult\_, BHbeta\_/BHalpha\_ (Beverton-Holt), Rbeta\_/Ralpha\_ (Ricker), PP\_ (constant recruits), *log_mult, *norm_sigma, *flag_recruit_stochastic, prod_alpha*, den_depend_beta1*/beta2*, temp_coefft\_, rate_coefft\_, wind_coefft\_, rec_var\_, *min/max_spawn_temp, *min/max_spawn_salt, prop_spawn_lost*, jack_a*/jack_b\_, rec_HabDepend, intersp_depend_recruit\_/sp\_/scale\_, aquacult_fry, KA\_/KB\_ (weight-length). | varies | double | per_group |
| overwinterStartTofY\_\<GRP\> | Overwinter start time-of-year (encystment block) | day-of-year | double | per_group |
| SPECIES_FAMILY Overwinter_Encystment | Per-group overwintering/encystment params: overwinterStartTofY\_, overwinterEndTofY\_, overwinterStartTemp\_, overwinterEndTemp\_, crit_mum\_, crit_nut\_, crit_temp\_, encyst_rate\_, hatch_rate\_, encyst_period\_, flagencyst\_. | varies | double | per_group |
| SPECIES_FAMILY Evolution | Per-group evolution params: max_prop_shift\_, inheritance\_, trait_variance\_, min_trait_variance\_. |  | double | per_group |
| SPECIES_FAMILY FeedingDetritusFractions | Per-group fractions of feeding-derived material to detritus: FDM\_\<GRP\> (mortality detritus), FDG\_\<GRP\> (egesta), FDGDL\_, FDGDR\_. |  | double | per_group |
| SPECIES_FAMILY FeedingDynamics | Per-group/predator feeding parameters: *catcheater, flagactiveDAY (diel activity), vla*\<GRP\>*T15 (assimilation), KL*\<GRP\>/KU\_\<GRP\>/KUP\_\<GRP\>/KLP\_\<GRP\> (feeding window lower/upper), Kmax_coefft\_\<GRP\>, KDEP\_\<GRP\> (sediment penetration depth), vlb\_, hta\_, htb\_ (handling time), pR\_ (reserve proportion fed), li_a\_/li_b\_/linf\_/Kbert\_/tzero\_ (length-at-age, VB), min_li_mat\_, predcase (functional response type), age_structured_prey\_, p_split\_, *extra_feed, vl*\<GRP\> (invert search volume), ht\_ (invert handling time), hvm\_, turbid_refuge\_, RSmax\_/RSmid\_/RSslope\_/RSprop\_/SNcost\_/RNcost\_/RSstarve\_ (reserve dynamics), E\_\<GRP\>/EPlant\_\<GRP\>/EDL\_\<GRP\>/EDR\_\<GRP\> (assimilation efficiencies on prey/plant/labile/refractory). | varies | double | per_group |
| SPECIES_FAMILY Q10_Temperature | Per-group temperature response: flagq10eff, flagq10receff, q10\_\<GRP\>, q10_method\_, q10_optimal_temp\_, q10_correction\_, temp_coefftA\_, flagtempsensitive, flagfecundsensitive. |  | double | per_group |
| SPECIES_FAMILY Salinity_pH_sensitivity | Per-group salinity/pH sensitivity: flagSaltSensitive, salt_correction\_, flagpHsensitive, pHsensitive_model\_, pH_constA\_/B\_/C\_, min_pH\_/max_pH\_, KN_pH\_, optimal_pH\_, pH_correction\_, contract_tol\_, flagcontract_tol\_, flagpredavaileffect, flagnutvaleffect, pHmortstart\_, pHmortA\_/B\_, pHmortmid\_. |  | double | per_group |
| SPECIES_FAMILY Pollution_impact | Per-group pollution light/noise sensitivity coefficients: light_coefft\_, noise_coefft\_. |  | double | per_group |
| SPECIES_FAMILY PrimaryProducer_uptake | Per-PP/seagrass parameters: KTUR\_ (bioturbation), KIRR\_ (infauna irradiance), KN\_ (DIN half-sat), KS\_ (Si half-sat), KF\_ (Fe half-sat), flag\*lim, KI\_\<GRP\>*T15 (light half-sat), L_KI*\<GRP\>*T15 (seagrass leaf light), Kext*/Ksub\_/KN_epi\_/KsubEpi\_/Ktrans\_ (seagrass), Beta_D\_, PBmax_D\_, P_uptake\_/P_scale_uptake\_/P_concp\_/P_min_internal\_/P_max_internal\_, C_uptake\_/C_scale_uptake\_/C_concp\_, PSA_min\_/C_min\_, Phyto_Resp_Rate\_, KP\_ (P half-sat), KLYS\_ (lysis rate), FSBDR\_. | varies | double | per_group |
| SPECIES_FAMILY Mortality | Per-group/per-cohort mortality rates at 15C: *mQ (quadratic), *mL (linear), *mLext (external linear), *mPext (external proportional); plus mS*\<GRP\>*T15 (macrophyte senescence), mStarve* (starvation), mT* (temperature mortality), mD* (depth-oxygen), mO* (oxygen), KO2\_ (lethal O2), KO2LIM\_ (limiting O2), turbidity mortality \_turbid_L/\_turbid_a/\_turbid_b. The \_mQ/\_mL/\_mLext/\_mPext and turbidity entries are read per-cohort via Read_Cohort_Species_Param_Values; others via Util_XML_Read_Species_Param. | d-1 | double | per_cohort |
| SPECIES_FAMILY Physical_limits_movement | Per-group physical limitation and movement: low\_/max\_/sat\_/thresh (basal/sed-FF feeding limits), \_ddepend_move (movement model), \_max/min_move_temp, \_max/min_move_salt, \_K_temp_const, *K_salt_const, Speed*, \_mindepth/\_maxdepth/\_maxtotdepth, \_min_O2, \_K_o2_const, \_homerangerad, \_overlap, k_trans, \_remin_contrib. | varies | double | per_group |
| SPECIES_FAMILY Coral_Sponge | Per-group coral/sponge params (bleaching, calcification, rugosity, smothering): \_bleach_periodA/B, \_mBleach, \_bleaching_rate, \_bleach_recovery_rate, \_bleach_tempshift, \_bleach_growshift, \_bleach_temp, \_min_bleach_temp, \_prop_zooxanth, \_DHW_thresh, \_threshdepth, \_depmum_scalar, \_min/max_bleach_salt, \_HostRemin, \_calcifRefBaseline, \_calcifTconst/Tcoefft/Topt/Lambda, \_FeedLightThresh, \_PropLightFeed, \_coral_max_accel_trans/A/B, \_CrecruitA/B/C, \_coral_overgrow, \_coral_compete, \_sponge_overgrow, \_sponge_compete, \_Ksmother_A/B, \_Vmax_deltaSi, \_Km_deltaSi, \_rug_erode, \_rug_bleacherode, \_rugFeedScalar, \_rug_factor, \_colony_ha, \_rug_erode_sponge, \_rugosity_inc/\_rugosity_dec, \_colony_diam. | varies | double | per_group |
| SPECIES_FAMILY Fishing_targetting | Per-group fishing/management flags read from bio prm: flagfish (targeting), flag_access_thru_wc\_, *age_harvest (aquaculture), tier (HCR tier), regionalSP, basketSP, basket_size, max_co_sp*, coType\_, tac_resetperiod, cpue_cdf_poor_r\_/p\_, cpue_cdf_top_r\_/p\_, samplesize, allometic li_a/li_b/li_bin/li_start/li_max, R_max, avg_inv_size, flag_assess, assess_bootstrap, assess_nat_mort, flag_prod_model, top_pcnt, bot_pcnt, assess_datastream, whichRAssess\_, ICE_KDEP\_. | varies | double | per_group |
| SPECIES_FAMILY RBC_assessment | Per-group reference-biomass-control / stock-assessment parameters (RBCSpeciesParamStructArray, atUtilXML.c:511-636): DiscType\_, MaxH\_, Growthage_L1\_/L2\_, MinCatch\_, AssessStart\_, NumRegions\_, Nsexes\_, Tier1/2/3Sig\_, isTriggerSpecies\_, trigger_threshold\_, UseRBCAveraging\_, Maturity_Inflect\_/Slope\_, T1_steep_phase\_, tiertype\_, Tier3\_\* (Fcalc/time/maxage/M/S25/S50/F/h/matlen/maxF), CCsel_years\_, Tier4\_\* (avtime/CPUEyrmin/max/m/alpha/Cmaxmult/Bo_correct), Tier5\_\* (length/S50/cv/flt/reg/p/sel/q), PostRule\_, CPUEmult\_, MaxChange\_, TriggerResponseScen\_, MG_offset\_, Regime_shift_assess\_, RecDevBack\_, Hsteep\_, Agesel_Pattern\_, AssessFreq\_, BallParkF\_/Yr\_, NumChangeLambda\_, num_enviro_obs\_, num_growth_morphs\_, Nsex_samp\_, MaxAge\_, Nyfuture\_, NumFisheries\_, Nlen\_, Lbin\_, thresh_mat\_, femsexratio\_, flagLAdirect\_/SLAdirect\_/WAdirect\_, SigmaR1\_/R2\_/R_future\_, PSigmaR1\_, Regime_year\_, RecDevMinYr\_/MaxYr\_, RecDevFlag\_, AutoCorRecDev\_, LFSSlim\_, AFSSlim\_, NumSurvey\_, Regime_year_assess\_, NblockPattern\_, SRBlock\_, assRecDevMinYear\_, MultispAssessType\_, mgt_indicator\_, init_mgt_category\_/sp\_, PGMSYBHalpha\_/beta\_. | varies | double | per_group |

### Groups

| Name | Description | Units | Type | Dimension |
|:---|:---|:---|:---|:---|
| Code | 2-3 uppercase letter group code identifier |  | string | per_group |
| Index | Row index of the group; read but discarded (ignored) |  | int | per_group |
| IsTurnedOn | Whether the functional group is active/turned on |  | double | per_group |
| Name | Short functional group name (used to build tracer names) |  | string | per_group |
| LongName | Full/long functional group name |  | string | per_group |
| NumCohorts | Number of cohorts (age classes) for the group |  | int | per_group |
| NumGeneTypes | Number of genetic/phenotype types per cohort |  | int | per_group |
| NumStages | Number of life stages (e.g. juvenile/adult) |  | int | per_group |
| NumSpawns | Number of spawning events per year |  | int | per_group |
| NumAgeClassSize | Number of years represented by each cohort (age class size) | years | int | per_group |
| NumStocks | Number of stocks per species |  | int | per_group |
| VerticallyMigrates | Whether the group moves vertically in day-to-day movement (mapped to XML “VerticallyMobile”) |  | int | per_group |
| HorizontallyMigrates | Whether the group moves horizontally in day-to-day movement (mapped to XML “Mobile”) |  | int | per_group |
| NumMigrations | Number of migration entries/periods for the group |  | int | per_group |
| MultiYrMigrations | Whether migrations span multiple years |  | int | per_group |
| ExternalReproduction | Whether the group reproduces externally (outside the model domain) |  | int | per_group |
| RecruitType | Recruitment relationship/option used for the group |  | int | per_group |
| IsFished | Whether the group is subject to fishing |  | int | per_group |
| IsImpacted | Whether the group is impacted by fishing/management |  | int | per_group |
| isTAC | Whether the group is managed under a Total Allowable Catch (mapped to XML “IsTAC”) |  | int | per_group |
| GroupType | Group type string (e.g. FISH, LG_PHY, LAB_DET) mapped to internal groupType enum |  | string | per_group |
| IsPredator | Whether the group preys on other groups |  | int | per_group |
| IsCover | Whether the group provides habitat cover (must be epibenthic) |  | int | per_group |
| IsSiliconDep | Whether the group depends on silicon (e.g. diatoms) |  | int | per_group |
| IsAssessed | Whether the group is stock-assessed (\>1 enables close-kin) |  | int | per_group |
| IsCatchGrazer | Whether the group grazes on catch/discards |  | double | per_group |
| OverWinters | Whether the group overwinters (distinct overwintering distribution) |  | int | per_group |
| isCultured | Whether the group is aquaculture-cultured |  | int | per_group |
| isHabDepend | Whether the group is habitat dependent |  | int | per_group |
| numMoveEntries | Number of seasonal horizontal-movement period entries |  | int | per_group |
| iBioEroder | Whether the group is a bioeroder (mapped to XML “isBioEroder”) |  | int | per_group |
| isSupplemented | Whether the group is supplemented (imported feed/stocking) |  | int | per_group |
| isExternal | Whether the group is an externally-driven population (optional column, only when external_populations flag is on) |  | int | per_group |
| isLandActive | Whether the group is active on land (optional column, only when terrestrial_on flag is on) |  | int | per_group |
| isLightEffected | Whether the group is affected by light pollution (optional column, only when flag_pollutant_impacts is on) |  | int | per_group |
| isNoiseEffected | Whether the group is affected by noise pollution (optional column, only when flag_pollutant_impacts is on) |  | int | per_group |

## Physics

### physics.prm

| Name | Description | Units | Type | Dimension |
|:---|:---|:---|:---|:---|
| include_atmosphere | Switch enabling the atmospheric exchange concentrations block |  | int | scalar |
| atmospheric_NH | Atmospheric ammonia concentration | mg N m-3 | double | scalar |
| atmospheric_NO | Atmospheric nitrate concentration | mg N m-3 | double | scalar |
| atmospheric_F | Atmospheric detritus/flux concentration | mg N m-3 | double | scalar |
| atmospheric_O2 | Atmospheric oxygen concentration | mg O m-3 | double | scalar |
| atmospheric_CO2 | Atmospheric carbon dioxide concentration | mg C m-3 | double | scalar |
| atmospheric_P | Atmospheric phosphorus concentration | mg P m-3 | double | scalar |
| atmospheric_Si | Atmospheric silica concentration | mg Si m-3 | double | scalar |
| mix_deep_O2 | Switch to include oxygen in deep-ocean remixing of bottom values |  | int | scalar |
| vdiffwt_wc | Vertical diffusion weighting coefficient in the water column |  | double | scalar |
| vdiffwt_sed | Vertical diffusion weighting coefficient in the sediment |  | double | scalar |
| wc_kz | Water-column vertical diffusion (eddy diffusivity) coefficient | m2 s-1 | double | scalar |
| wc_dz_tol | Tolerance for water-column layer dz before reset to nominal value | fraction | double | scalar |
| maxseddz | Maximum sediment layer thickness | m | double | scalar |
| minseddz | Minimum sediment layer thickness | m | double | scalar |
| max_erosion | Maximum sediment erosion rate | m s-1 | double | scalar |
| wgt_georugosity | Weighting of geological rugosity in aragonite/rugosity tracking |  | double | scalar |
| bi_dissol_kz | Bio-irrigation dissolved-tracer diffusion rate | m2 s-1 | double | scalar |
| bi_exchange | Bio-irrigation exchange rate | s-1 | double | scalar |
| bi_injection | Bio-irrigation injection rate | s-1 | double | scalar |
| bt_partic_kz | Bio-turbation particulate-tracer diffusion rate | m2 s-1 | double | scalar |
| bt_exchange | Bio-turbation exchange rate | s-1 | double | scalar |
| bt_expulsion | Bio-turbation expulsion rate | s-1 | double | scalar |
| biosedprofile | Functional form of depth dependence for bio-irrigation/turbation (first char used) |  | string | scalar |
| biooxprofile | Functional form of depth dependence for sediment oxygen distribution (first char used) |  | string | scalar |
| baseline_temp | Baseline temperature for the model | degrees C | double | scalar |
| temp_ampltiude | Amplitude of temperature variation (note key is misspelled in source) | degrees C | double | scalar |
| constrain_wc | Switch to constrain water depth to a minimum value of 1m |  | int | scalar |
| mix_injection | Vertical upwelling mixing rate | s-1 | double | scalar |
| mix_season_kz | Seasonal vertical upwelling mixing coefficient |  | double | scalar |
| mix_deep | Switch indicating whether deep ocean mixing occurs |  | int | scalar |
| mix_deep_depth | Depth threshold for deep ocean mixing | m | double | scalar |
| injection | Switch to use point source/sink injection |  | int | scalar |
| atmospherics | Switch to use atmospheric exchange model |  | int | scalar |
| settling | Switch to use settling model |  | int | scalar |
| bioirrigation | Switch to use bio-irrigation model |  | int | scalar |
| bioturbation | Switch to use bio-turbation model |  | int | scalar |
| horiz_diffusion | Switch to use horizontal diffusion model |  | int | scalar |
| vert_diffusion | Switch to use vertical diffusion model |  | int | scalar |
| vert_mix | Switch to use forced vertical mixing model |  | int | scalar |
| advect_diffusion | Switch to use transport (advection-diffusion) model |  | int | scalar |
| fill_zero_exchange | Switch to fill zero-exchange flows |  | int | scalar |
| use_fill_horizmix | Switch to use horizontal mixing when filling zero exchanges |  | int | scalar |
| flush_threshold | Flushing threshold triggering zero-exchange fill |  | double | scalar |
| resuspension | Switch to use resuspension model |  | int | scalar |
| decay_wc | Switch to use decay model in the water column |  | int | scalar |
| decay_sed | Switch to use decay model in the sediment |  | int | scalar |
| decay_sed_scale | Scalar for decay rate in the sediment |  | double | scalar |
| scale_transport | Switch to scale exchanges/transport |  | int | scalar |
| prcnt_exchange | Coefficient for constant scaling of exchanges | fraction | double | scalar |
| ka_exchange | Coefficient for area-corrected scaling of exchanges |  | double | scalar |
| cascade_flows | Switch allowing flows/exchanges to cascade down slopes |  | int | scalar |
| edge_type | Per-box boundary type flag (standard, absorptive or reflective); read into local bnd_type then stored as box edge_type |  | double_array | per_box |
| eddy_S1 | Seasonal eddy scaling factor for season 1 (per box) |  | double_array | per_box |
| eddy_S2 | Seasonal eddy scaling factor for season 2 (per box) |  | double_array | per_box |
| eddy_S3 | Seasonal eddy scaling factor for season 3 (per box) |  | double_array | per_box |
| eddy_S4 | Seasonal eddy scaling factor for season 4 (per box) |  | double_array | per_box |
| eddy_mixscale | Coefficient for scaling of vertical exchanges by eddies |  | double | scalar |
| nutrientchange | Number of gradual nutrient (point source/sink) changes to apply |  | int | scalar |
| pulsechange | Switch/number for pulsed point source/sink changes |  | int | scalar |
| pss\<s\>\_numchanges | Number of point source/sink change schedules for point source s |  | int | per_group |
| pss\<s\>\_change\<i\> | Per-timestep flags marking which point sources are scaled in change i of source s |  | int_array | timeseries |
| pss\<s\>\_mult\<i\> | Per-timestep multipliers applied in change i of source s |  | double_array | timeseries |
| pss\<s\>\_period\<i\> | Per-timestep period over which change i of source s is applied |  | int_array | timeseries |
| pss\<s\>\_start\<i\> | Per-timestep start time for change i of source s |  | int_array | timeseries |
| maxicedz | Maximum ice layer thickness | m | int | scalar |
| minicedz | Minimum ice layer thickness | m | int | scalar |
| num_ice_classes | Number of ice classes/types |  | int | scalar |
| slush | Tracer/id index for slush ice |  | int | scalar |
| kind_ice_model | Selector for which ice model formulation to use |  | int | scalar |

### forcing_prm

| Name | Description | Units | Type | Dimension |
|:---|:---|:---|:---|:---|
| use_pollutantfiles | Flag to enable noise/light pollution forcing tracer files |  | int | scalar |
| use_phFiles | Flag to enable pH forcing files |  | int | scalar |
| use_tempfiles | Flag to enable temperature forcing files |  | int | scalar |
| use_saltfiles | Flag to enable salinity forcing files |  | int | scalar |
| use_VertMixFiles | Flag to enable vertical mixing scalar forcing files |  | int | scalar |
| n\<shortName\>files | Number of physical-property forcing files for a given property (temp/salt/pH/Wind/vertMixScalar/noise_pollution/light_pollution) |  | int | scalar |
| \<shortName\>\_rewind | Rewind flag for a physical-property forcing series |  | int | scalar |
| \<longName\>\<i\>.name | File name (i-th) of a physical-property forcing series (Temperature/Salinity/pH/Wind/vertMixScalar/Noise_Pollution/Light_Pollution) |  | string | other |
| use_force_tracers | Flag to enable generic forcing-tracer (netCDF) input |  | int | scalar |
| nforceTracers | Number of forcing tracers |  | int | scalar |
| tracerNames | List of forcing-tracer variable names |  | string_array | other |
| use_weighted_assim | Flag to use per-tracer assimilation weighting coefficients |  | int | scalar |
| \<tracerName\>\_nFiles | Number of forcing files for a given forcing tracer |  | int | scalar |
| \<tracerName\>\_File\<i\>.name | File name (i-th) for a given forcing tracer |  | string | other |
| \<tracerName\>\_File\<i\>.use_resets | Whether file i of a forcing tracer applies reset values |  | int | scalar |
| \<tracerName\>\_rewind | Rewind flag for a forcing tracer |  | int | scalar |
| \<tracerName\>\_wgt_coefft | Assimilation weighting coefficient for a forcing tracer |  | double | scalar |
| \<tracerName\>\_ResetTol | Reset tolerance for a forcing tracer |  | double | scalar |
| use_move_entries | Flag to enable forced-movement distribution forcing |  | int | scalar |
| nforceMoveGroups | Number of functional-group stages with forced movement distributions |  | int | scalar |
| MoveGroupCodes | List of moving group/stage codes (e.g. \<code\>*stage*\<n\>) |  | string_array | other |
| \<moveGroupCode\>\_File.name | NetCDF distribution file for a moving group/stage |  | string | other |
| \<moveGroupCode\>\_tstart | Start time for applying forced movement of a group/stage |  | double | scalar |
| Solar_radiation | Solar radiation forcing input filename (.ts or .nc); empty means Atlantis computes light |  | string | other |
| \<shortName\>\_rewind | Rewind flag for the solar-radiation (.nc) forcing series; shortName is “swr” |  | int | scalar |
| Solar_radiation_rewind | Alternate rewind flag for the solar-radiation (.nc) forcing series |  | int | scalar |
| nhdfiles | Number of hydrodynamic input (netCDF) files |  | int | scalar |
| ts_on_hydro_time | Whether time series use the hydrodynamic time reference instead of model time |  | int | scalar |
| inputs_tout | Output frequency for inputs.ts / export.ts files | seconds | double | scalar |
| hd\<i\>.name | File name (i-th) of a hydrodynamic input file |  | string | other |
| nIcets | Number of ice time series (ts-file ice input); tsname is “Ice” |  | int | scalar |
| typeIcets | Type of ice time series |  | int | scalar |
| Icets\<i\>.data | Ice state time-series data filename for series i |  | string | other |
| Icets\<i\>.depth_data | Ice depth time-series data filename for series i |  | string | other |
| nInceFiles | Number of ice input netCDF files |  | int | scalar |
| Ice\<i\>.name | File name (i-th) of an ice input netCDF file |  | string | other |
| Precipitation | Precipitation time-series filename | mm day-1 | string | other |
| Evaporation | Evaporation time-series filename | mm day-1 | string | other |
| Tracer_area_inputs | Area tracer-input time-series filename |  | string | other |
| thermal_index | Thermal-index lake-fish recruitment forcing time-series filename | deg C | string | other |
| thermal_index_rewind | Rewind flag for the thermal_index time series |  | int | scalar |
| rate_index | Rate-index lake-fish recruitment forcing time-series filename | deg C | string | other |
| rate_index_rewind | Rewind flag for the rate_index time series |  | int | scalar |
| Recruitment_time_series | Recruitment forcing time-series filename |  | string | other |
| Recruitment_enviro_forcing | Recruitment environmental forcing time-series filename |  | string | other |
| KWSR_forcing | KWSR environmental forcing time-series filename |  | string | other |
| LinearMort | Linear-mortality scaling forcing time-series filename |  | string | other |
| SizeChange | Size (sn/rn) change scaling forcing time-series filename |  | string | other |
| GrowthRateChange | Growth-rate change forcing time-series filename |  | string | other |
| FSPBChange | FSPB change forcing time-series filename |  | string | other |
| pCO2_forcing | Atmospheric pCO2 forcing time-series filename |  | string | other |
| use_external_scaling | Flag to enable external biology scalar (netCDF) forcing |  | int | scalar |
| externalBiologyForcingFile | External biology scalar forcing netCDF filename |  | string | other |
| externalBiologyForcingFile_rewind | Rewind flag for the external biology scalar forcing file |  | int | scalar |
| scale_all_mortality | Whether external scaling applies to all mortality terms |  | int | scalar |
| mortality_addition | Whether external mortality scaling is additive vs multiplicative |  | int | scalar |
| use_larvalfiles | Flag to enable larval-dispersal connectivity matrix forcing |  | int | scalar |
| larval_rewind | Rewind flag for the larval connectivity forcing file |  | int | scalar |
| Larval0.name | Larval connectivity matrix netCDF filename |  | string | other |

## Harvest

### fisheries.csv

| Name | Description | Units | Type | File | Dimension |
|:---|:---|:---|:---|:---|:---|
| Code | Fishery code identifier |  | string | fisheries_csv | per_fishery |
| Index | Fishery index number |  | int | fisheries_csv | per_fishery |
| Name | Descriptive fishery name |  | string | fisheries_csv | per_fishery |
| IsRec | Whether the fishery is recreational (1) or commercial (0) |  | int | fisheries_csv | per_fishery |
| NumSubFleets | Number of subfleets in the fishery (also sets K_max_num_subfleet) |  | double | fisheries_csv | per_fishery |

### harvest.prm

| Name | Description | Units | Type | File | Dimension |
|:---|:---|:---|:---|:---|:---|
| flag\<f\>day | Fishery active flag / day-night preference (2=no pref,1=day,0=night) |  | int | harvest_prm | per_fishery |
| \<f\>\_tStart | Day fishery starts operating | day | double | harvest_prm | per_fishery |
| \<f\>\_tEnd | Day fishery stops operating | day | double | harvest_prm | per_fishery |
| \<f\>\_start_manage | Day management of fishery starts | day | double | harvest_prm | per_fishery |
| \<f\>\_end_manage | Day management of fishery ends | day | double | harvest_prm | per_fishery |
| flagfish\<GRP\> | Per-group fishing/targetting on-off flag |  | int | harvest_prm | per_group |
| flaghabitat\_\<GRP\> | Group habitat-association flag (impacted groups) |  | int | harvest_prm | per_group |
| \<f\>\_flagdempelfishery | Flag: demersal vs pelagic fishery |  | int | harvest_prm | per_fishery |
| \<f\>\_effortmodel | Effort-model option flag for fishery |  | int | harvest_prm | per_fishery |
| dynanyway | Force dynamic catch evaluation even when not strictly needed |  | int | harvest_prm | scalar |
| \<f\>\_explore | Flag exploratory fishing has been done |  | int | harvest_prm | per_fishery |
| \<f\>\_effortdrop | Flag effort drop allowed |  | int | harvest_prm | per_fishery |
| \<f\>\_selcurve | Selectivity curve type for fishery |  | int | harvest_prm | per_fishery |
| flagdiscard\_\<GRP\> | Group discarding flag |  | int | harvest_prm | per_group |
| flagescapement\_\<GRP\> | Group escapement (gear-escape) flag |  | int | harvest_prm | per_group |
| spawn_closure\_\<GRP\> | Group spawning-closure flag |  | int | harvest_prm | per_group |
| flag_access_thru_wc\_\<GRP\> | Group accessible to gear through water column flag |  | int | harvest_prm | per_group |
| flagimposecatch\_\<GRP\> | Group uses imposed (forced) catch time series |  | int | harvest_prm | per_group |
| flagF\_\<GRP\> | Group uses imposed fishing-mortality (F) time series |  | int | harvest_prm | per_group |
| flagchangediscrd | Global flag - discarding practices change with time |  | int | harvest_prm | scalar |
| flagchangesel | Global flag - selectivity changes with time |  | int | harvest_prm | scalar |
| flagchangeF | Global flag - F-mortality forcing changes with time |  | int | harvest_prm | scalar |
| flagchangeq | Global flag - catchability changes with time |  | int | harvest_prm | scalar |
| flagchangep | Global flag - spatial coverage changes with time |  | int | harvest_prm | scalar |
| flagchangeswept | Global flag - gear swept-area changes with time |  | int | harvest_prm | scalar |
| \<f\>\_changeSEL | Per-fishery selectivity-change flag |  | int | harvest_prm | per_fishery |
| \<f\>\_changeP | Per-fishery spatial-coverage change flag |  | int | harvest_prm | per_fishery |
| \<f\>\_changeSWEPT | Per-fishery swept-area change flag |  | int | harvest_prm | per_fishery |
| flagQchange\_\<GRP\> | Group catchability-change flag |  | int | harvest_prm | per_group |
| flagFchange\_\<GRP\> | Group F-mortality-change flag |  | int | harvest_prm | per_group |
| flagchangeDISCRD\_\<GRP\> | Group discarding-change flag |  | int | harvest_prm | per_group |
| k_mismatch | Reduction in gear effectiveness due to water-column mismatch |  | double | harvest_prm | scalar |
| FisheryTargetSpecies\<f\> | Per-fishery binary vector of target functional groups |  | int_array | harvest_prm | per_fishery |
| CatchAgeDistributions\_\<GRP\> | Catch age-class distribution per impacted age-structured group | proportion | double_array | harvest_prm | per_group |
| highgrade_thresh | Catch-proportion threshold defining preferred (high-graded) cohort | proportion | double | harvest_prm | scalar |
| q\_\<GRP\> | Per-group catchability across fisheries |  | double_array | harvest_prm | per_group |
| qStock\_\<GRP\>\_\<coh\> | Stock-distribution of catchability per group/cohort/stock |  | double_array | harvest_prm | per_group |
| Speed_boat | Speed of average commercial fishing vessel (converted to m/s) | m/hr (input; stored /3600 as m/s) | double | harvest_prm | scalar |
| Speed_recboat | Speed of average recreational vessel (converted to m/s) | m/hr (input; stored /3600 as m/s) | double | harvest_prm | scalar |
| KDEP_fishery | Sediment penetration depth of fishing gear | m | double | harvest_prm | scalar |
| FisheryHabitats\<f\> | Per-fishery habitat (cover-type) association vector |  | double_array | harvest_prm | per_fishery |
| \<f\>\_maxdepth | Maximum sea-floor depth fishery operates at | m | double | harvest_prm | per_fishery |
| \<f\>\_mindepth | Minimum sea-floor depth fishery operates at | m | double | harvest_prm | per_fishery |
| k_pattern | Habitat patchiness pattern parameter for trawl mortality (must be \> -1) |  | double | harvest_prm | scalar |
| k_patches | Number of habitat patches for trawl-mortality patchiness |  | double | harvest_prm | scalar |
| BoxHabitatProportion\<f\> | Per-fishery proportion of each box covered by associated habitat | proportion | double_array | harvest_prm | per_box |
| imposecatchstart\_\<GRP\> | Group day imposed catch/F begins | day | int | harvest_prm | per_group |
| imposecatchend\_\<GRP\> | Group day imposed catch/F ends | day | int | harvest_prm | per_group |
| reportscale\_\<GRP\> | Catch-reporting scaling factor per group |  | double | harvest_prm | per_group |
| mFC\_\<GRP\> | Forced fishing mortality (F) per group across fisheries | 1/day (rate) | double_array | harvest_prm | per_group |
| \<GRP\>\_mFC_startage | First age class subject to forced fishing mortality |  | int_array | harvest_prm | per_group |
| \<GRP\>\_mFC_endage | Last age class subject to forced fishing mortality |  | int_array | harvest_prm | per_group |
| sel\_\<GRP\> | Constant selectivity of group (biomass groups) per fishery | proportion | double_array | harvest_prm | per_group |
| sel\_\<GRP\>\<coh\> | Constant selectivity per age class of age-structured group per fishery | proportion | double_array | harvest_prm | per_group |
| \<f\>sel_b | Logistic selectivity curve slope parameter B |  | double | harvest_prm | per_fishery |
| \<f\>sel_lsm | Logistic selectivity curve inflection point (length at 50%) | cm | double | harvest_prm | per_fishery |
| \<f\>sel_normsigma | Normal selectivity curve spread (sigma) |  | double | harvest_prm | per_fishery |
| \<f\>sel_normlsm | Normal selectivity curve modal length | cm | double | harvest_prm | per_fishery |
| \<f\>sel_lognormsigma | Lognormal selectivity curve spread (sigma) |  | double | harvest_prm | per_fishery |
| \<f\>sel_lognormlsm | Lognormal selectivity curve modal length | cm | double | harvest_prm | per_fishery |
| \<f\>sel_gammasigma | Gamma selectivity curve spread (sigma) |  | double | harvest_prm | per_fishery |
| \<f\>sel_gammalsm | Gamma selectivity curve modal length | cm | double | harvest_prm | per_fishery |
| \<f\>sel_bisigma | Bimodal selectivity curve first spread (sigma) |  | double | harvest_prm | per_fishery |
| \<f\>sel_bisigma2 | Bimodal selectivity curve second spread (sigma) |  | double | harvest_prm | per_fishery |
| \<f\>sel_ampli | Bimodal selectivity curve amplitude |  | double | harvest_prm | per_fishery |
| \<f\>sel_bilsm1 | Bimodal selectivity curve left modal length | cm | double | harvest_prm | per_fishery |
| \<f\>sel_bilsm2 | Bimodal selectivity curve right modal length | cm | double | harvest_prm | per_fishery |
| p_escape\_\<GRP\> | Proportion of group escaping gear | proportion | double | harvest_prm | per_group |
| Ka_escape\_\<GRP\> | Escapement curve coefficient Ka for group |  | double | harvest_prm | per_group |
| Kb_escape\_\<GRP\> | Escapement curve exponent Kb for group |  | double | harvest_prm | per_group |
| prop_within | Proportion of quota above which high grading begins | proportion | double | harvest_prm | scalar |
| salethresh | Proportion of max market value below which market-based discarding begins | proportion | double | harvest_prm | scalar |
| \<f\>\_maxsaleprice | Maximum sale price for fishery (market-based discarding) |  | double | harvest_prm | per_fishery |
| DiscardAgeDistributions\_\<GRP\> | Discard age-class distribution per impacted age-structured group | proportion | double_array | harvest_prm | per_group |
| ProportionDiscarding\_\<GRP\> | Proportion of co-catch discarded per impacted group (over groups) | proportion | double_array | harvest_prm | per_group |
| FFCDR\_\<GRP\> | Fixed proportion of fished cohort discarded per group (case selector) | proportion | double | harvest_prm | per_group |
| FC_case\<GRP\> | Age-dependant discarding case flag per group (selects A vs B curve) |  | int | harvest_prm | per_group |
| FFCDR\_\<GRP\>chrt | Per-age-class fixed discard proportion, case A (FC_case==0) | proportion | double_array | harvest_prm | per_group |
| FFCDR\_\<GRP\>chrtB | Per-age-class fixed discard proportion, case B (FC_case==1) | proportion | double_array | harvest_prm | per_group |
| FCthreshli\_\<GRP\> | Size (length) threshold below which group discarded | cm | double_array | harvest_prm | per_group |
| incidmort\_\<GRP\> | Incidental (discard) mortality proportion per group | proportion | double | harvest_prm | per_group |
| k_retain\_\<GRP\> | Proportion retained (size-based discarding) per group | proportion | double_array | harvest_prm | per_group |
| k_waste\_\<GRP\> | Proportion discarded as waste (size-based discarding) per group | proportion | double_array | harvest_prm | per_group |
| \<f\>\_sweptarea | Gear swept area per fishery | m2 | double | harvest_prm | per_fishery |
| \<f\>\_sel_changes | Number of selectivity changes scheduled for fishery |  | int | harvest_prm | per_fishery |
| Start\<f\> | Start day(s) of each selectivity change (Selectivity_Change) | day | double_array | harvest_prm | per_fishery |
| NewCurve\<f\> | New selectivity curve type at each selectivity change |  | double_array | harvest_prm | per_fishery |
| ConstantValueAddition\<f\> | Additive constant to selectivity LSM at each change |  | double_array | harvest_prm | per_fishery |
| SigmaValueAddition\<f\> | Additive constant to selectivity sigma at each change |  | double_array | harvest_prm | per_fishery |
| \<f\>\_p_changes | Number of spatial-coverage changes for fishery |  | int | harvest_prm | per_fishery |
| Pchange\<f\> | Coverage-change values (day + new P) per fishery |  | double_array | harvest_prm | per_fishery |
| \<f\>\_swept_changes | Number of swept-area changes for fishery |  | int | harvest_prm | per_fishery |
| SWEPTchange\<f\> | Swept-area-change values (day + new swept area) per fishery |  | double_array | harvest_prm | per_fishery |
| \<GRP\>\_discard_changes | Number of discarding changes per group |  | int | harvest_prm | per_group |
| Start\<GRP\> | Start day of each discard change (Discard_Changes) | day | int_array | harvest_prm | per_group |
| ChangeThreshMult\<GRP\> | Multiplier applied to discard size threshold at each change |  | double_array | harvest_prm | per_group |
| RetainMult\<GRP\> | Multiplier applied to retained proportion at each change |  | double_array | harvest_prm | per_group |
| DiscardMult\<GRP\> | Multiplier applied to discard proportion at each change |  | double_array | harvest_prm | per_group |
| WasteMult\<GRP\> | Multiplier applied to waste proportion at each change |  | double_array | harvest_prm | per_group |
| \<GRP\>\_q_changes | Number of catchability changes per group |  | int | harvest_prm | per_group |
| Qchange\<GRP\> | Catchability-change values (day + new q) per fished group/fishery |  | double_array | harvest_prm | per_group |
| \<GRP\>\_mFC_changes | Number of fishing-mortality changes per group |  | int | harvest_prm | per_group |
| mFCchange\<GRP\> | Fishing-mortality-change values (day + new mFC) per fished group/fishery |  | double_array | harvest_prm | per_group |
| \<GRP\>\_age_harvest | Age at which aquaculture group is harvested |  | int | harvest_prm | per_group |

## Run parameters (run.prm)

| Name | Description | Units | Type | File | Dimension |
|:---|:---|:---|:---|:---|:---|
| ecotest | Ecology test/diagnostic verbosity flag |  | int | biology_prm | scalar |
| availflag | Switch controlling how prey availability is interpreted |  | int | biology_prm | scalar |
| flagrandom | Enable stochastic/random processes |  | int | biology_prm | scalar |
| readin_popratio | Read population ratio (stock) data flag |  | int | biology_prm | scalar |
| flagresp | Respiration submodel flag |  | int | biology_prm | scalar |
| flagavgmig | Average migration flag |  | int | biology_prm | scalar |
| flagbactstim | Bacterial stimulation flag |  | int | biology_prm | scalar |
| flagtrackpops | Track populations flag |  | int | biology_prm | scalar |
| flagseason | Seasonal forcing flag |  | int | biology_prm | scalar |
| flaglight | Light limitation model flag |  | int | biology_prm | scalar |
| flaglightopt | Light optimisation option |  | int | biology_prm | scalar |
| lim_sun_hours | Limit primary production to daylight hours flag |  | int | biology_prm | scalar |
| flagmodeltemp | Temperature dependence model flag |  | int | biology_prm | scalar |
| flagq10 | Global Q10 temperature scaling flag |  | int | biology_prm | scalar |
| O2case | Oxygen limitation case selector |  | int | biology_prm | scalar |
| flagnut | Nutrient limitation flag |  | int | biology_prm | scalar |
| flagmicro | Microbial loop flag |  | int | biology_prm | scalar |
| flagtempchange | Apply prescribed temperature change flag |  | int | biology_prm | scalar |
| flagsaltchange | Apply prescribed salinity change flag |  | int | biology_prm | scalar |
| flagpHchange | Apply prescribed pH change flag |  | int | biology_prm | scalar |
| flagstarve | Starvation mortality flag |  | int | biology_prm | scalar |
| flagdegrade | Detritus degradation flag |  | int | biology_prm | scalar |
| flagroc | Rate-of-change effects flag |  | int | biology_prm | scalar |
| flaghomog_sp | Homogeneous spatial distribution flag |  | int | biology_prm | scalar |
| flagagestruct | Age structure global flag |  | int | biology_prm | scalar |
| flagsenesce | Senescence mortality flag |  | int | biology_prm | scalar |
| flagtsforcerecruit | Time-series forced recruitment flag |  | int | biology_prm | scalar |
| flag_modify_KWSR | Modify weight-at-spawn ratio flag |  | int | biology_prm | scalar |
| flag_extpop_growth_option | External population growth option |  | int | biology_prm | scalar |
| juv_transition_thresh | Juvenile-to-adult size transition threshold |  | double | biology_prm | scalar |
| mat_transition_thresh | Maturity transition threshold |  | double | biology_prm | scalar |
| norm_larval_distrib | Normalise larval distribution flag |  | int | biology_prm | scalar |
| larvae_connect_only | Larvae connectivity-only flag |  | int | biology_prm | scalar |
| enviro_independ_larvae | Environment-independent larvae flag |  | int | biology_prm | scalar |
| flag_recruit_effect | Recruitment environmental effect flag |  | int | biology_prm | scalar |
| flag_macro_model | Macrophyte/seagrass model flag |  | int | biology_prm | scalar |
| flag_benthos_sediment_link | Benthos-sediment coupling flag |  | int | biology_prm | scalar |
| flag_competing_epiff | Competing epibenthic filter feeders flag |  | int | biology_prm | scalar |
| max_available_habitat | Maximum available habitat fraction |  | double | biology_prm | scalar |
| flag_invert_biohab | Invertebrate biogenic habitat flag |  | int | biology_prm | scalar |
| flag_olddiet | Use legacy diet handling flag |  | int | biology_prm | scalar |
| flag_fine_ontogenetic_diets | Fine-grained per-age diet matrices flag |  | int | biology_prm | scalar |
| UseHardFeedingWindow | Use hard (step) feeding window flag |  | int | biology_prm | scalar |
| UseBiLogisticFeedingWindow | Use bi-logistic feeding window flag |  | int | biology_prm | scalar |
| flag_satiation | Predator satiation flag |  | int | biology_prm | scalar |
| flag_shrinkfat | Allow shrinking/fat loss flag |  | int | biology_prm | scalar |
| flag_predratiodepend | Ratio-dependent predation flag |  | int | biology_prm | scalar |
| flag_dynamicXRS | Dynamic reserve/structural ratio flag |  | int | biology_prm | scalar |
| flag_repcostSpawn | Reproduction cost at spawning flag |  | int | biology_prm | scalar |
| flag_lengthSN | Length from structural N flag |  | int | biology_prm | scalar |
| XRS_cap | Cap on reserve-to-structural ratio |  | double | biology_prm | scalar |
| flag_rel_cover | Relative cover model flag |  | int | biology_prm | scalar |
| flag_report_water_detritus | Report water-column detritus flag |  | int | biology_prm | scalar |
| flag_refuge_model | Prey refuge model flag |  | int | biology_prm | scalar |
| flag_rugosity_model | Rugosity model flag |  | int | biology_prm | scalar |
| flag_georugosity | Geological (background) rugosity flag |  | int | biology_prm | scalar |
| RugCover_Coefft | Rugosity-cover relationship coefficient |  | double | biology_prm | scalar |
| RugCover_Const | Rugosity-cover relationship constant |  | double | biology_prm | scalar |
| RugCover_Cap | Rugosity-cover relationship cap |  | double | biology_prm | scalar |
| min_rugosity | Minimum rugosity |  | double | biology_prm | scalar |
| max_rugosity | Maximum rugosity |  | double | biology_prm | scalar |
| rugosity_const | Rugosity baseline constant |  | double | biology_prm | scalar |
| rugosity_bozec_a | Bozec rugosity model coefficient a |  | double | biology_prm | scalar |
| rugosity_bozec_b | Bozec rugosity model coefficient b |  | double | biology_prm | scalar |
| rugosity_bozec_c | Bozec rugosity model coefficient c |  | double | biology_prm | scalar |
| rugosity_bozec_d | Bozec rugosity model coefficient d |  | double | biology_prm | scalar |
| flagmodelpH | pH dynamics model flag |  | int | biology_prm | scalar |
| pH_sensitivity_model | pH sensitivity model selector |  | int | biology_prm | scalar |
| flagPHmortcase | pH mortality case selector |  | int | biology_prm | scalar |
| pH_surface_depth | Surface pH layer depth boundary | m | double | biology_prm | scalar |
| pH_mid_depth | Mid pH layer depth boundary | m | double | biology_prm | scalar |
| pH_surface_coefft_T | Surface pH regression coefficient on temperature |  | double | biology_prm | scalar |
| pH_surface_coefft_S | Surface pH regression coefficient on salinity |  | double | biology_prm | scalar |
| pH_surface_coefft_O | Surface pH regression coefficient on oxygen |  | double | biology_prm | scalar |
| pH_surface_const | Surface pH regression constant |  | double | biology_prm | scalar |
| pH_mid_coefft_T | Mid-layer pH regression coefficient on temperature |  | double | biology_prm | scalar |
| pH_mid_coefft_S | Mid-layer pH regression coefficient on salinity |  | double | biology_prm | scalar |
| pH_mid_coefft_O | Mid-layer pH regression coefficient on oxygen |  | double | biology_prm | scalar |
| pH_mid_const | Mid-layer pH regression constant |  | double | biology_prm | scalar |
| pH_deep_coefft_T | Deep-layer pH regression coefficient on temperature |  | double | biology_prm | scalar |
| pH_deep_coefft_S | Deep-layer pH regression coefficient on salinity |  | double | biology_prm | scalar |
| pH_deep_coefft_O | Deep-layer pH regression coefficient on oxygen |  | double | biology_prm | scalar |
| pH_deep_const | Deep-layer pH regression constant |  | double | biology_prm | scalar |
| flagmodelArag | Aragonite saturation model flag |  | int | biology_prm | scalar |
| K_max_num_DHW | Max number of degree heating weeks records |  | int | biology_prm | scalar |
| Karag_A | Aragonite regression coefficient A |  | double | biology_prm | scalar |
| Karag_B | Aragonite regression coefficient B |  | double | biology_prm | scalar |
| Karag_C | Aragonite regression coefficient C |  | double | biology_prm | scalar |
| Karag_pH | Aragonite regression coefficient on pH |  | double | biology_prm | scalar |
| Kca_const | Calcium constant for calcification |  | double | biology_prm | scalar |
| K_Ks | Calcification saturation half-constant |  | double | biology_prm | scalar |
| Ksmother_coefft | Smothering coefficient |  | double | biology_prm | scalar |
| Ksmother_const | Smothering constant |  | double | biology_prm | scalar |
| Pads_r_t0 | Phosphate adsorption rate at reference temp |  | double | biology_prm | scalar |
| Pads_K | Phosphate adsorption half-saturation |  | double | biology_prm | scalar |
| Pads_KO | Phosphate adsorption oxygen dependence |  | double | biology_prm | scalar |
| r_immob_PIP_t0 | Particulate inorganic P immobilisation rate at reference temp |  | double | biology_prm | scalar |
| Enviro_turb | Environmental turbidity switch |  | int | biology_prm | scalar |
| K_TUR | Turbidity half-saturation |  | double | biology_prm | scalar |
| K_TUR_DEP | Turbidity depth dependence |  | double | biology_prm | scalar |
| K_MAX_TUR | Maximum turbidity |  | double | biology_prm | scalar |
| K_IRR | Irradiance half-saturation |  | double | biology_prm | scalar |
| K_MAX_IRR | Maximum irradiance |  | double | biology_prm | scalar |
| K_MIN_IRR | Minimum irradiance |  | double | biology_prm | scalar |
| r_DC_T15 | Labile detritus carbon breakdown rate at 15C | d-1 | double | biology_prm | scalar |
| r_DL_T15 | Labile detritus breakdown rate at 15C | d-1 | double | biology_prm | scalar |
| r_DR_T15 | Refractory detritus breakdown rate at 15C | d-1 | double | biology_prm | scalar |
| r_DON_T15 | Dissolved organic N breakdown rate at 15C | d-1 | double | biology_prm | scalar |
| r_DSi_T15 | Dissolved silica regeneration rate at 15C | d-1 | double | biology_prm | scalar |
| FDR_DC | Fraction of refractory detritus to DC |  | double | biology_prm | scalar |
| FDR_DL | Fraction of refractory detritus to DL |  | double | biology_prm | scalar |
| FDON_D | Fraction of detritus to DON |  | double | biology_prm | scalar |
| R_0_T15 | Base remineralisation rate at 15C | d-1 | double | biology_prm | scalar |
| R_D_T15 | Detritus remineralisation rate at 15C | d-1 | double | biology_prm | scalar |
| Dmax | Maximum depth for remineralisation | m | double | biology_prm | scalar |
| K_nit_T15 | Nitrification rate at 15C | d-1 | double | biology_prm | scalar |
| K_conc | Nitrification concentration half-saturation |  | double | biology_prm | scalar |
| p_NH_anad | Proportion NH from anaerobic decomposition |  | double | biology_prm | scalar |
| X_ON | Oxygen-to-nitrogen Redfield ratio |  | double | biology_prm | scalar |
| X_CN | Carbon-to-nitrogen Redfield ratio |  | double | biology_prm | scalar |
| X_CHLN | Chlorophyll-to-nitrogen ratio |  | double | biology_prm | scalar |
| X_SiN | Silica-to-nitrogen ratio |  | double | biology_prm | scalar |
| X_FeN | Iron-to-nitrogen ratio |  | double | biology_prm | scalar |
| k_wetdry | Wet/dry weight conversion factor |  | double | biology_prm | scalar |
| k_w_cdepth | Light attenuation coefficient at critical depth | m-1 | double | biology_prm | scalar |
| k_w_depth | Light attenuation coefficient with depth | m-1 | double | biology_prm | scalar |
| k_w_deep | Deep-water light attenuation coefficient | m-1 | double | biology_prm | scalar |
| k_w_shallow | Shallow-water light attenuation coefficient | m-1 | double | biology_prm | scalar |
| k_PN | Light attenuation per unit particulate N |  | double | biology_prm | scalar |
| k_DON | Light attenuation per unit DON |  | double | biology_prm | scalar |
| k_DL | Light attenuation per unit labile detritus |  | double | biology_prm | scalar |
| k_IS | Light attenuation per unit inorganic suspended matter |  | double | biology_prm | scalar |
| k_SED | Light attenuation per unit sediment |  | double | biology_prm | scalar |
| KIOP_min | Minimum I-optimal half-saturation |  | double | biology_prm | scalar |
| KIOP_shift | I-optimal shift parameter |  | double | biology_prm | scalar |
| KI_avail | Irradiance availability scalar |  | double | biology_prm | scalar |
| K_addepth | Additional depth offset for light calc | m | double | biology_prm | scalar |
| swr_scalar | Shortwave radiation scaling factor |  | double | biology_prm | scalar |
| swr_const | Shortwave radiation constant |  | double | biology_prm | scalar |
| swr_cos_coefft | Shortwave radiation seasonal cosine coefficient |  | double | biology_prm | scalar |
| swr_cos_offset | Shortwave radiation seasonal cosine offset |  | double | biology_prm | scalar |
| albedo_ice | Ice albedo |  | double | biology_prm | scalar |
| k_bs | Light attenuation under bare snow |  | double | biology_prm | scalar |
| k_bi | Light attenuation under bare ice |  | double | biology_prm | scalar |
| k_rs | Light attenuation under refrozen snow |  | double | biology_prm | scalar |
| k_ri | Light attenuation under refrozen ice |  | double | biology_prm | scalar |
| R_bi | Reflectance of bare ice |  | double | biology_prm | scalar |
| k_ice | Light attenuation coefficient for ice | m-1 | double | biology_prm | scalar |
| ka_star | Specific light absorption coefficient |  | double | biology_prm | scalar |
| Tchange_max_num | Number of prescribed temperature-change records |  | int | biology_prm | scalar |
| Tchange | Prescribed temperature-change time-series (value/time pairs) | degC | double_array | biology_prm | timeseries |
| Schange_max_num | Number of prescribed salinity-change records |  | int | biology_prm | scalar |
| Schange | Prescribed salinity-change time-series |  | double_array | biology_prm | timeseries |
| pHchange_max_num | Number of prescribed pH-change records |  | int | biology_prm | scalar |
| PHchange | Prescribed pH-change time-series |  | double_array | biology_prm | timeseries |
| RTOP | Top of refuge tolerance |  | double | biology_prm | scalar |
| K_Lc | Critical light constant |  | double | biology_prm | scalar |
| RelTol | Relative numerical tolerance |  | double | biology_prm | scalar |
| Flux_tol | Flux tolerance threshold |  | double | biology_prm | scalar |
| min_pool | Minimum tracer pool concentration |  | double | biology_prm | scalar |
| min_dens | Minimum density threshold |  | double | biology_prm | scalar |
| min_channel_depth | Minimum channel depth | m | double | biology_prm | scalar |
| flag_do_var_express | Variable expression flag (evolution) |  | int | biology_prm | scalar |
| flag_do_evolution | Enable evolution module |  | int | biology_prm | scalar |
| flag_bound_change | Allow trait bound change flag |  | int | biology_prm | scalar |
| flag_inheritance | Trait inheritance flag |  | int | biology_prm | scalar |
| flag_evolvar_capped | Cap evolved variance flag |  | int | biology_prm | scalar |
| evol_stdev_range | Evolutionary standard deviation range |  | double | biology_prm | scalar |
| max_rate_evol | Maximum rate of evolutionary change |  | double | biology_prm | scalar |
| flag_mult_grow_curves | Multiple growth morph curves flag |  | int | biology_prm | scalar |
| ActiveTrait/\<GRP\> | Per-group active evolutionary trait flags (one row of trait toggles per group) |  | double_array | biology_prm | per_group |
| MB_wc | Microbial biomass water-column reference |  | double | biology_prm | scalar |
| eddy_scale | Eddy diffusivity scaling for PP |  | double | biology_prm | scalar |
| XPB_DL | Fraction of PB flux to labile detritus |  | double | biology_prm | scalar |
| XBB_DL | Fraction of BB flux to labile detritus |  | double | biology_prm | scalar |
| XPB_DR | Fraction of PB flux to refractory detritus |  | double | biology_prm | scalar |
| XBB_DR | Fraction of BB flux to refractory detritus |  | double | biology_prm | scalar |
| k_PB | Pelagic bacteria rate constant |  | double | biology_prm | scalar |
| k_BB | Benthic bacteria rate constant |  | double | biology_prm | scalar |
| flaghabdepend | Habitat-dependent processes flag |  | int | biology_prm | scalar |
| flag_move_habdepend | Habitat-dependent movement flag |  | int | biology_prm | scalar |
| flagenviro_displace | Environmental displacement flag |  | int | biology_prm | scalar |
| flagenviro_kill | Environmental kill flag |  | int | biology_prm | scalar |
| REEFchange_max_num | Number of reef-cover change records |  | int | biology_prm | scalar |
| FLATchange_max_num | Number of flat-cover change records |  | int | biology_prm | scalar |
| SOFTchange_max_num | Number of soft-cover change records |  | int | biology_prm | scalar |
| REEFchange | Reef-substrate cover change time-series |  | double_array | biology_prm | timeseries |
| FLATchange | Flat-substrate cover change time-series |  | double_array | biology_prm | timeseries |
| SOFTchange | Soft-substrate cover change time-series |  | double_array | biology_prm | timeseries |
| Group_Habitat_Preference/\<GRP\> | Per-group habitat preference array over habitat types |  | double_array | biology_prm | per_group |
| Group_Ice_Preference/\<GRP\> | Per-group ice habitat preference array |  | double_array | biology_prm | per_group |
| Group_IceReprod_Preference/\<GRP\> | Per-group ice reproduction preference array |  | double_array | biology_prm | per_group |
| roc_wgt | Rate-of-change weighting |  | double | biology_prm | scalar |
| k_roc_food | Rate-of-change food scaling constant |  | double | biology_prm | scalar |
| flagtempdepend_move | Temperature-dependent movement flag |  | int | biology_prm | scalar |
| flagtempdepend_reprod | Temperature-dependent reproduction flag |  | int | biology_prm | scalar |
| flagsaltdepend | Salinity-dependent processes flag |  | int | biology_prm | scalar |
| flagO2depend | Oxygen-dependent processes flag |  | int | biology_prm | scalar |
| flagconstrain_epiwander | Constrain epibenthic wandering flag |  | int | biology_prm | scalar |
| X_RS | Reserve-to-structural target ratio |  | double | biology_prm | scalar |
| Kthresh1 | Movement/feeding threshold constant 1 (read twice; two threshold slots) |  | double | biology_prm | scalar |
| KHTD | Habitat threshold constant (deep) |  | double | biology_prm | scalar |
| KHTI | Habitat threshold constant (intertidal) |  | double | biology_prm | scalar |
| SeasonalDistribution/\<GRP\>/\<STAGE\> | Per-group/per-stage seasonal horizontal distribution (juvenile/adult, per box) |  | double_array | biology_prm | per_box |
| p_BBfish | Proportion bacteria cleaned from fish-ingested detritus |  | double | biology_prm | scalar |
| p_BBben | Proportion bacteria cleaned from benthic-ingested detritus |  | double | biology_prm | scalar |
| p_PBwc | Proportion of pelagic bacteria available in water column |  | double | biology_prm | scalar |
| p_PBben | Proportion of pelagic bacteria available in benthos |  | double | biology_prm | scalar |
| k_refDL | Reference labile-detritus level for omnivore supplement feeding |  | double | biology_prm | scalar |
| k_refDR | Reference refractory-detritus level for supplement feeding |  | double | biology_prm | scalar |
| k_refsDL | Reference sediment labile-detritus level |  | double | biology_prm | scalar |
| flagfishrates | Use fish-specific clearance/growth rates flag |  | int | biology_prm | scalar |
| li_a_invert | Length-weight allometry coefficient a for invertebrates |  | double | biology_prm | scalar |
| li_b_invert | Length-weight allometry exponent b for invertebrates |  | double | biology_prm | scalar |
| pPREY\<PREDCOHORT\>\<PRED\>\<PREYCOHORT\> | Vertebrate predator-prey availability matrix (pSPVERTeat), availability of each prey group to a predator age class |  | double_array | biology_prm | per_prey |
| pPREY\<PRED\> | Invertebrate/biomass-pool predator-prey availability row (single cohort) |  | double_array | biology_prm | per_prey |
| DetritusSedimentFoodAvail/\<GRP\>\[/\<COHORT\>\] | Availability of detritus/sediment groups to a predator (per detritus group, per cohort for age-structured) |  | double_array | biology_prm | per_prey |
| AgeDietAvail/\<GRP\> | Fine ontogenetic (per-age) prey availability matrix |  | double_array | biology_prm | per_prey |
| SeagrassFoodAvail/\<GRP\> | Availability of seagrass/macrophyte parts to grazers |  | double_array | biology_prm | per_prey |
| Supplemental_Diets/\<GRP\> | Imported/supplemental feed distribution per box for cultured/supplemented groups |  | double_array | biology_prm | per_box |
| Catch_Opportunity/Catch_Availability/\<GRP\> | Availability of fishery catch to opportunistic catch-eaters (per prey group) |  | double_array | biology_prm | per_prey |
| Catch_Opportunity/Proportion_Exploitable/\<GRP\> | Proportion of each fishery’s catch exploitable by catch-eaters |  | double_array | biology_prm | other |
| C\_\<GRP\> | Per-cohort vertebrate clearance (search-volume) rate; prm key C\_\<GRP\> array over age classes | m3 (mg N)-1 d-1 | double_array | biology_prm | per_cohort |
| C\_\<GRP\>\_T15 | Invertebrate grazer clearance rate at 15C; scalar per group | m3 (mg N)-1 d-1 | double | biology_prm | per_group |
| mum\_\<GRP\> | Per-cohort vertebrate maximum growth (consumption) rate; prm key mum\_\<GRP\> array over age classes | mg N d-1 (per individual) | double_array | biology_prm | per_cohort |
| mum\_\<GRP\>\_T15 | Invertebrate/PP/bacteria maximum growth rate at 15C; scalar per group | d-1 | double | biology_prm | per_group |
| InvertebrateSN/\<GRP\> | Invertebrate structural-N (size) reference per group | mg N | double_array | biology_prm | per_group |
| Q10 | Global Q10 temperature scaling factor |  | double | biology_prm | scalar |
| temp_coefftB | Temperature response coefficient B |  | double | biology_prm | scalar |
| temp_coefftC | Temperature response coefficient C |  | double | biology_prm | scalar |
| temp_exp | Temperature response exponent |  | double | biology_prm | scalar |
| KST_fish | Standard metabolic temperature scalar - fish |  | double | biology_prm | scalar |
| KST_shark | Standard metabolic temperature scalar - shark |  | double | biology_prm | scalar |
| KST_bird | Standard metabolic temperature scalar - bird |  | double | biology_prm | scalar |
| KST_mammal | Standard metabolic temperature scalar - mammal |  | double | biology_prm | scalar |
| Ktmp_fish | Temperature respiration coefficient - fish |  | double | biology_prm | scalar |
| Ktmp_shark | Temperature respiration coefficient - shark |  | double | biology_prm | scalar |
| Ktmp_bird | Temperature respiration coefficient - bird |  | double | biology_prm | scalar |
| Ktmp_mammal | Temperature respiration coefficient - mammal |  | double | biology_prm | scalar |
| Kthreshm | Mortality threshold constant |  | double | biology_prm | scalar |
| FFDDR | Fraction of feeding-derived detritus going to refractory pool |  | double | biology_prm | scalar |
| FDL_fish | Fraction labile detritus from fish mortality |  | double | biology_prm | scalar |
| FDL_benth | Fraction labile detritus from benthic invert mortality |  | double | biology_prm | scalar |
| FDL_top | Fraction labile detritus from top predator mortality |  | double | biology_prm | scalar |
| FDL_wc | Fraction labile detritus from water-column group mortality |  | double | biology_prm | scalar |
| FDL_SG_roots | Fraction labile detritus from seagrass roots |  | double | biology_prm | scalar |
| FDL_SG_leaves | Fraction labile detritus from seagrass leaves |  | double | biology_prm | scalar |
| FPB_DR | Fraction pelagic-bacteria flux to refractory detritus |  | double | biology_prm | scalar |
| FBB_DR | Fraction benthic-bacteria flux to refractory detritus |  | double | biology_prm | scalar |
| FPB_DON | Fraction pelagic-bacteria flux to DON |  | double | biology_prm | scalar |
| FBB_DON | Fraction benthic-bacteria flux to DON |  | double | biology_prm | scalar |
| Fben_den | Fraction benthic denitrification |  | double | biology_prm | scalar |
| ImplicitSeabirdMortalityRate/\<GRP\> | Implicit (external) seabird mortality rate per group | d-1 | double_array | biology_prm | per_group |
| ImplicitFishMortalityRate/\<GRP\> | Implicit (external) fish mortality rate per group | d-1 | double_array | biology_prm | per_group |
| flagtrecruitdistrib | Time-varying recruit distribution flag |  | int | biology_prm | scalar |
| recover_trigger | Population recovery trigger level |  | double | biology_prm | scalar |
| recover_span | Recovery span duration |  | double | biology_prm | scalar |
| recover_subseq | Subsequent recovery parameter |  | double | biology_prm | scalar |
| lognorm_mu | Lognormal recruitment mean parameter |  | double | biology_prm | scalar |
| lognorm_sigma | Lognormal recruitment standard deviation parameter |  | double | biology_prm | scalar |
| rec_m | Recruitment mean (stochastic) parameter |  | double | biology_prm | scalar |
| rec_sigma | Recruitment standard deviation parameter |  | double | biology_prm | scalar |
| recruitRange | Recruitment search range |  | double | biology_prm | scalar |
| recruitRangeFlat | Flat recruitment range |  | double | biology_prm | scalar |
| ref_chl | Reference chlorophyll for recruitment effect |  | double | biology_prm | scalar |
| FSPB\_\<GRP\> | Per-cohort proportion of spawning biomass; prm key FSPB\_\<GRP\> array over age classes |  | double_array | biology_prm | per_cohort |
| KDENR\_\<GRP\> | Per-cohort density-dependent recruitment parameter (Reproduction/KDENR) |  | double_array | biology_prm | per_cohort |
| recSTOCK\_\<GRP\> | Per-stock recruitment allocation (Reproduction/recSTOCK) |  | double_array | biology_prm | other |
| popratioStock\_\<GRP\> | Per-stock population ratio at initialisation (Reproduction/popratioStock) |  | double_array | biology_prm | other |
| pStock\_\<GRP\> | Per-stock diet/spatial proportion (Diet/pStock) |  | double_array | biology_prm | other |
| VerticalRecruitLocation/\<GRP\> | Per-group vertical layer distribution for recruits |  | double_array | biology_prm | per_layer |
| RecruitDistribution/\<GRP\> | Per-group horizontal recruit distribution over boxes |  | double_array | biology_prm | per_box |
| AquacultDistribution/\<GRP\> | Per-group horizontal aquaculture stocking distribution over boxes |  | double_array | biology_prm | per_box |
| \<GRP\>\_Time_Spawn | Per-spawn-event spawning time-of-year per group (prm key \*\_Time_Spawn) | day-of-year | int_array | biology_prm | per_cohort |
| Time_Age\_\<GRP\> | Per-event time-to-age cohort entry per group (prm key Time_Age\_\<GRP\>) | day | int_array | biology_prm | per_cohort |
| StockStructure/\<GRP\> | Per-group per-box stock membership (integer stock id per box) |  | int_array | biology_prm | per_box |
| VerticalStockStructure/\<GRP\> | Per-group per-layer vertical stock membership |  | int_array | biology_prm | per_layer |
| invading_sp_model | Invading-species model flag |  | int | biology_prm | scalar |
| InvaderIndex | Functional-group index of the invader |  | int | biology_prm | scalar |
| minInvaderAge | Minimum age of invading individuals |  | int | biology_prm | scalar |
| maxInvaderAge | Maximum age of invading individuals |  | int | biology_prm | scalar |
| InvaderEntryBox | Box index where invader enters |  | int | biology_prm | scalar |
| InvadersEntering | Number of invaders entering |  | double | biology_prm | scalar |
| InvaderMinDepth | Minimum entry depth for invader | m | double | biology_prm | scalar |
| InvaderMaxDepth | Maximum entry depth for invader | m | double | biology_prm | scalar |
| InvaderStartDay | Day-of-year invasion starts | day-of-year | int | biology_prm | scalar |
| InvaderEndDay | Day-of-year invasion ends | day-of-year | int | biology_prm | scalar |
| InvaderScalar | Scaling of invader numbers |  | double | biology_prm | scalar |
| InvaderSpeed | Invader movement speed |  | double | biology_prm | scalar |
| InvaderEntryLayer | Vertical layer of invader entry |  | int | biology_prm | scalar |
| p_IBice | Proportion of biota associated with ice |  | double | biology_prm | scalar |
| flag_dissolved_pollutants | Track dissolved pollutants flag |  | int | biology_prm | scalar |
| flag_contamMortModel | Contaminant mortality model flag |  | int | biology_prm | scalar |
| flag_contamInteractModel | Contaminant interaction model flag |  | int | biology_prm | scalar |
| flag_contamGrowthModel | Contaminant growth-effect model flag |  | int | biology_prm | scalar |
| flag_contamReprodModel | Contaminant reproduction-effect model flag |  | int | biology_prm | scalar |
| flag_contamOnlyAmplify | Contaminant amplify-only flag |  | int | biology_prm | scalar |
| flag_contamMove | Contaminant movement flag |  | int | biology_prm | scalar |
| flag_contamMinTemp | Contaminant minimum-temperature flag |  | int | biology_prm | scalar |
| flag_contam_halflife_spbased | Species-based contaminant half-life flag |  | int | biology_prm | scalar |
| flag_contamMaternalTransfer | Maternal contaminant transfer flag |  | int | biology_prm | scalar |
| flag_contam_distrib | Contaminant distribution flag |  | int | biology_prm | scalar |
| biopools_dodge_contam | Biological pools bypass contaminant flag |  | int | biology_prm | scalar |
| min_pool_cont | Minimum contaminant pool concentration |  | double | biology_prm | scalar |
| contam_tau | Contaminant decay time constant |  | double | biology_prm | scalar |
| contam_sig_uptake_const | Contaminant sigmoidal uptake constant |  | double | biology_prm | scalar |
| flag_detritus_contam | Detritus contaminant tracking flag |  | int | biology_prm | scalar |
| k_migslow | Migration slowdown constant |  | double | biology_prm | scalar |
| Migration/MigrateIOBox/\<GRP\>\[/\<COHORT\>\]/Migrate\<N\> | Per-migration destination box proportions for migrating groups |  | double_array | biology_prm | per_box |
| Migration/KMIG_DEN/\<GRP\> | Initial density of pre-existing out-of-model migrators |  | double_array | biology_prm | per_cohort |
| Migration/KMIG_RN/\<GRP\> | Initial reserve N of pre-existing out-of-model migrators | mg N | double_array | biology_prm | per_cohort |
| Migration/KMIG_SN/\<GRP\> | Initial structural N of pre-existing out-of-model migrators | mg N | double_array | biology_prm | per_cohort |
| Migration/KMIG_INVERT\<N\>/\<GRP\> | Initial density of out-of-model invertebrate migrators per migration |  | double_array | biology_prm | per_cohort |
| flag\<GRP\> | Group functioning (on/off) flag |  | int | biology_prm | per_group |
| flagdem\<GRP\> | Preferred-location (demersal) trend flag |  | int | biology_prm | per_group |
| flagplankfish\<GRP\> | Planktivore flag |  | int | biology_prm | per_group |
| \<GRP\>thresh | Flux threshold for sediment/bacteria flux |  | double | biology_prm | per_group |
| \<GRP\>damp | Flux damping coefficient |  | double | biology_prm | per_group |
| SPECIES_FAMILY Reproduction_flags | Per-group reproduction flags and parameters. One entry each, prm key = base_GRP: flagbearlive (live-bearing), feed_while_spawn, flagmother (parental care), flagrecruit (recruitment function id), flagrecpeak, flagstocking, flagkeep_plusgroup, Recruit_Period, *Recruit_Time, *cohort_recruit_entry, *spawn_period, KSPA* (spawn area), FSP* (spawn fraction), Kcov_juv*/Bcov_juv\_/Acov_juv\_/Kcov_ad\_/Bcov_ad\_/Acov_ad\_ (cover coeffts), RugCover_scalar, *age_mat (age at maturity), recover_start, KWSR*, KWRR\_, recover_mult\_, BHbeta\_/BHalpha\_ (Beverton-Holt), Rbeta\_/Ralpha\_ (Ricker), PP\_ (constant recruits), *log_mult, *norm_sigma, *flag_recruit_stochastic, prod_alpha*, den_depend_beta1*/beta2*, temp_coefft\_, rate_coefft\_, wind_coefft\_, rec_var\_, *min/max_spawn_temp, *min/max_spawn_salt, prop_spawn_lost*, jack_a*/jack_b\_, rec_HabDepend, intersp_depend_recruit\_/sp\_/scale\_, aquacult_fry, KA\_/KB\_ (weight-length). | varies | double | biology_prm | per_group |
| overwinterStartTofY\_\<GRP\> | Overwinter start time-of-year (encystment block) | day-of-year | double | biology_prm | per_group |
| SPECIES_FAMILY Overwinter_Encystment | Per-group overwintering/encystment params: overwinterStartTofY\_, overwinterEndTofY\_, overwinterStartTemp\_, overwinterEndTemp\_, crit_mum\_, crit_nut\_, crit_temp\_, encyst_rate\_, hatch_rate\_, encyst_period\_, flagencyst\_. | varies | double | biology_prm | per_group |
| SPECIES_FAMILY Evolution | Per-group evolution params: max_prop_shift\_, inheritance\_, trait_variance\_, min_trait_variance\_. |  | double | biology_prm | per_group |
| SPECIES_FAMILY FeedingDetritusFractions | Per-group fractions of feeding-derived material to detritus: FDM\_\<GRP\> (mortality detritus), FDG\_\<GRP\> (egesta), FDGDL\_, FDGDR\_. |  | double | biology_prm | per_group |
| SPECIES_FAMILY FeedingDynamics | Per-group/predator feeding parameters: *catcheater, flagactiveDAY (diel activity), vla*\<GRP\>*T15 (assimilation), KL*\<GRP\>/KU\_\<GRP\>/KUP\_\<GRP\>/KLP\_\<GRP\> (feeding window lower/upper), Kmax_coefft\_\<GRP\>, KDEP\_\<GRP\> (sediment penetration depth), vlb\_, hta\_, htb\_ (handling time), pR\_ (reserve proportion fed), li_a\_/li_b\_/linf\_/Kbert\_/tzero\_ (length-at-age, VB), min_li_mat\_, predcase (functional response type), age_structured_prey\_, p_split\_, *extra_feed, vl*\<GRP\> (invert search volume), ht\_ (invert handling time), hvm\_, turbid_refuge\_, RSmax\_/RSmid\_/RSslope\_/RSprop\_/SNcost\_/RNcost\_/RSstarve\_ (reserve dynamics), E\_\<GRP\>/EPlant\_\<GRP\>/EDL\_\<GRP\>/EDR\_\<GRP\> (assimilation efficiencies on prey/plant/labile/refractory). | varies | double | biology_prm | per_group |
| SPECIES_FAMILY Q10_Temperature | Per-group temperature response: flagq10eff, flagq10receff, q10\_\<GRP\>, q10_method\_, q10_optimal_temp\_, q10_correction\_, temp_coefftA\_, flagtempsensitive, flagfecundsensitive. |  | double | biology_prm | per_group |
| SPECIES_FAMILY Salinity_pH_sensitivity | Per-group salinity/pH sensitivity: flagSaltSensitive, salt_correction\_, flagpHsensitive, pHsensitive_model\_, pH_constA\_/B\_/C\_, min_pH\_/max_pH\_, KN_pH\_, optimal_pH\_, pH_correction\_, contract_tol\_, flagcontract_tol\_, flagpredavaileffect, flagnutvaleffect, pHmortstart\_, pHmortA\_/B\_, pHmortmid\_. |  | double | biology_prm | per_group |
| SPECIES_FAMILY Pollution_impact | Per-group pollution light/noise sensitivity coefficients: light_coefft\_, noise_coefft\_. |  | double | biology_prm | per_group |
| SPECIES_FAMILY PrimaryProducer_uptake | Per-PP/seagrass parameters: KTUR\_ (bioturbation), KIRR\_ (infauna irradiance), KN\_ (DIN half-sat), KS\_ (Si half-sat), KF\_ (Fe half-sat), flag\*lim, KI\_\<GRP\>*T15 (light half-sat), L_KI*\<GRP\>*T15 (seagrass leaf light), Kext*/Ksub\_/KN_epi\_/KsubEpi\_/Ktrans\_ (seagrass), Beta_D\_, PBmax_D\_, P_uptake\_/P_scale_uptake\_/P_concp\_/P_min_internal\_/P_max_internal\_, C_uptake\_/C_scale_uptake\_/C_concp\_, PSA_min\_/C_min\_, Phyto_Resp_Rate\_, KP\_ (P half-sat), KLYS\_ (lysis rate), FSBDR\_. | varies | double | biology_prm | per_group |
| SPECIES_FAMILY Mortality | Per-group/per-cohort mortality rates at 15C: *mQ (quadratic), *mL (linear), *mLext (external linear), *mPext (external proportional); plus mS*\<GRP\>*T15 (macrophyte senescence), mStarve* (starvation), mT* (temperature mortality), mD* (depth-oxygen), mO* (oxygen), KO2\_ (lethal O2), KO2LIM\_ (limiting O2), turbidity mortality \_turbid_L/\_turbid_a/\_turbid_b. The \_mQ/\_mL/\_mLext/\_mPext and turbidity entries are read per-cohort via Read_Cohort_Species_Param_Values; others via Util_XML_Read_Species_Param. | d-1 | double | biology_prm | per_cohort |
| SPECIES_FAMILY Physical_limits_movement | Per-group physical limitation and movement: low\_/max\_/sat\_/thresh (basal/sed-FF feeding limits), \_ddepend_move (movement model), \_max/min_move_temp, \_max/min_move_salt, \_K_temp_const, *K_salt_const, Speed*, \_mindepth/\_maxdepth/\_maxtotdepth, \_min_O2, \_K_o2_const, \_homerangerad, \_overlap, k_trans, \_remin_contrib. | varies | double | biology_prm | per_group |
| SPECIES_FAMILY Coral_Sponge | Per-group coral/sponge params (bleaching, calcification, rugosity, smothering): \_bleach_periodA/B, \_mBleach, \_bleaching_rate, \_bleach_recovery_rate, \_bleach_tempshift, \_bleach_growshift, \_bleach_temp, \_min_bleach_temp, \_prop_zooxanth, \_DHW_thresh, \_threshdepth, \_depmum_scalar, \_min/max_bleach_salt, \_HostRemin, \_calcifRefBaseline, \_calcifTconst/Tcoefft/Topt/Lambda, \_FeedLightThresh, \_PropLightFeed, \_coral_max_accel_trans/A/B, \_CrecruitA/B/C, \_coral_overgrow, \_coral_compete, \_sponge_overgrow, \_sponge_compete, \_Ksmother_A/B, \_Vmax_deltaSi, \_Km_deltaSi, \_rug_erode, \_rug_bleacherode, \_rugFeedScalar, \_rug_factor, \_colony_ha, \_rug_erode_sponge, \_rugosity_inc/\_rugosity_dec, \_colony_diam. | varies | double | biology_prm | per_group |
| SPECIES_FAMILY Fishing_targetting | Per-group fishing/management flags read from bio prm: flagfish (targeting), flag_access_thru_wc\_, *age_harvest (aquaculture), tier (HCR tier), regionalSP, basketSP, basket_size, max_co_sp*, coType\_, tac_resetperiod, cpue_cdf_poor_r\_/p\_, cpue_cdf_top_r\_/p\_, samplesize, allometic li_a/li_b/li_bin/li_start/li_max, R_max, avg_inv_size, flag_assess, assess_bootstrap, assess_nat_mort, flag_prod_model, top_pcnt, bot_pcnt, assess_datastream, whichRAssess\_, ICE_KDEP\_. | varies | double | biology_prm | per_group |
| SPECIES_FAMILY RBC_assessment | Per-group reference-biomass-control / stock-assessment parameters (RBCSpeciesParamStructArray, atUtilXML.c:511-636): DiscType\_, MaxH\_, Growthage_L1\_/L2\_, MinCatch\_, AssessStart\_, NumRegions\_, Nsexes\_, Tier1/2/3Sig\_, isTriggerSpecies\_, trigger_threshold\_, UseRBCAveraging\_, Maturity_Inflect\_/Slope\_, T1_steep_phase\_, tiertype\_, Tier3\_\* (Fcalc/time/maxage/M/S25/S50/F/h/matlen/maxF), CCsel_years\_, Tier4\_\* (avtime/CPUEyrmin/max/m/alpha/Cmaxmult/Bo_correct), Tier5\_\* (length/S50/cv/flt/reg/p/sel/q), PostRule\_, CPUEmult\_, MaxChange\_, TriggerResponseScen\_, MG_offset\_, Regime_shift_assess\_, RecDevBack\_, Hsteep\_, Agesel_Pattern\_, AssessFreq\_, BallParkF\_/Yr\_, NumChangeLambda\_, num_enviro_obs\_, num_growth_morphs\_, Nsex_samp\_, MaxAge\_, Nyfuture\_, NumFisheries\_, Nlen\_, Lbin\_, thresh_mat\_, femsexratio\_, flagLAdirect\_/SLAdirect\_/WAdirect\_, SigmaR1\_/R2\_/R_future\_, PSigmaR1\_, Regime_year\_, RecDevMinYr\_/MaxYr\_, RecDevFlag\_, AutoCorRecDev\_, LFSSlim\_, AFSSlim\_, NumSurvey\_, Regime_year_assess\_, NblockPattern\_, SRBlock\_, assRecDevMinYear\_, MultispAssessType\_, mgt_indicator\_, init_mgt_category\_/sp\_, PGMSYBHalpha\_/beta\_. | varies | double | biology_prm | per_group |

## Abbreviations

``` r

atl$abbreviation
#> $GRP
#> [1] "species (functional) group code, e.g. FPS; range 0..K_num_tot_sp-1"
#> 
#> $f
#> [1] "fishery name/code (per-fishery harvest parameters, bm->FISHERYprms[f])"
#> 
#> $id
#> [1] "species-parameter index into FunctGroupArray[guild].speciesParams[<id>] (slot in the speciesParamStructArray[] master table)"
#> 
#> $base
#> [1] "parameter base-name prefix in per-group keys of the form <base>_<GRP> (e.g. mum, C); uppercase <BASE> used in comment blocks"
#> 
#> $i
#> [1] "loop index: file index in a forcing-file series (e.g. hd<i>.name, <tracerName>_File<i>.name) or change-schedule index in pss keys (pss<s>_change<i>)"
#> 
#> $s
#> [1] "point source/sink index, 0..npss-1 (e.g. pss<s>_numchanges)"
#> 
#> $tracerName
#> [1] "name of a generic forcing tracer (netCDF forcing input, bm->forceTracerInput[])"
#> 
#> $PRED
#> [1] "predator group code in diet-availability keys pPREY<PREDCOHORT><PRED><PREYCOHORT>"
#> 
#> $N
#> [1] "migration event index (Migrate<N>: 1..num_migrate; KMIG_INVERT<N>: 0..num_migrate-1)"
#> 
#> $shortName
#> [1] "short name of a physical-property forcing series (e.g. temp, salt, pH, Wind, vertMixScalar) used in keys like n<shortName>files"
#> 
#> $COHORT
#> [1] "age class (cohort) of an age-structured group, e.g. in MigrateIOBox/<GRP>[/<COHORT>]/Migrate<N>"
#> 
#> $suffix
#> [1] "parameter suffix in per-group keys of the form <GRP>_<suffix>; uppercase <SUFFIX> used in comment blocks"
#> 
#> $moveGroupCode
#> [1] "moving group/stage code listed in MoveGroupCodes (forced-movement entries, form <code>_stage_<n>)"
#> 
#> $coh
#> [1] "age-class (cohort) index in harvest keys, e.g. qStock_<GRP>_<coh>, sel_<GRP><coh>"
#> 
#> $PREYCOHORT
#> [1] "prey life-stage digit in pPREY keys (1 = juvenile, 2 = adult)"
#> 
#> $PREDCOHORT
#> [1] "predator life-stage digit in pPREY keys (1 = juvenile, 2 = adult)"
#> 
#> $n
#> [1] "stage number in a moving group/stage code <code>_stage_<n>"
#> 
#> $longName
#> [1] "long name of a physical-property forcing series (e.g. Temperature, Salinity) used in <longName><i>.name"
#> 
#> $code
#> [1] "group code part of a moving group/stage code <code>_stage_<n>"
#> 
#> $STAGE
#> [1] "life stage, juvenile or adult (e.g. SeasonalDistribution/<GRP>/<STAGE>)"
```

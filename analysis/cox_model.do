/*----------------------------------------------------------------------------
Do file name: 			cox_models
Project: 				Project 12: Post covid CVD events
Date:					08/09/2022
Author:					Venexia Walker and Rachel Denholm
                        Adapted from post-covid-vaccinated cox_model.do
Description:			Reformating of CSV file and running cox models
Datasets used:			csv outcome files
Datasets created:		*_cox_model.txt
Other output:			logfiles
-----------------------------------------------------------------------------*/

local cpf "`1'"

* Set file paths

global projectdir `c(pwd)'
di "$projectdir"

* Set Ado file path

adopath + "$projectdir/analysis/extra_ados"

* Import and describe data

import delim using "./output/`cpf'.csv", clear

des

* Filter data

keep patient_id age_at_cohort_start expo_date region_name follow_up_start event_date ethnicity follow_up_end cox_weights cov_cat* cov_num* cov_bin* sex

* Rename variables
rename age_at_cohort_start age
rename expo_date exposure_date
rename region_name region
rename event_date outcome_date

* Generate pre vaccination cohort dummy variable
local prevax_cohort = regexm("`cpf'", "_pre")

* Replace NA with missing value that Stata recognises

ds , has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = "" if `var' == "NA"
}

* Reformat variables

foreach var of varlist exposure_date outcome_date follow_up_start follow_up_end {
	split `var', gen(tmp_date) parse(-)
	gen year = real(tmp_date1)
	gen month = real(tmp_date2)
	gen day = real(tmp_date3)
	gen `var'_tmp = mdy(month, day, year)
	format %td `var'_tmp
	drop `var' tmp_date* year month day
	rename `var'_tmp `var'
}

* Shorten covariate names
capture confirm variable cov_bin_other_arterial_embolism 
if !_rc {
	rename cov_bin_other_arterial_embolism cov_bin_other_art_embol
}

capture confirm variable cov_bin_chronic_obstructive_pulm
if !_rc {
	rename cov_bin_chronic_obstructive_pulm cov_bin_copd 
}

capture confirm variable cov_bin_chronic_kidney_disease
if !_rc {
	rename cov_bin_chronic_kidney_disease cov_bin_ckd 
}

foreach var of varlist cov_bin* sex {
	encode `var', gen(`var'_tmp)
	drop `var'
	rename `var'_tmp `var'
}

* Recode region

gen region_tmp = .
replace region_tmp = 1 if region=="East"
replace region_tmp = 2 if region=="East Midlands"
replace region_tmp = 3 if region=="London"
replace region_tmp = 4 if region=="North East"
replace region_tmp = 5 if region=="North West"
replace region_tmp = 6 if region=="South East"
replace region_tmp = 7 if region=="South West"
replace region_tmp = 8 if region=="West Midlands"
replace region_tmp = 9 if region=="Yorkshire and The Humber"
label define region_tmp 1 "East" 2 "East Midlands" 3 "London" 4 "North East" 5 "North West" 6 "South East" 7 "South West" 8 "West Midlands" 9 "Yorkshire and The Humber"
label values region_tmp region_tmp
drop region
rename region_tmp region

* Recode ethnicity

gen ethnicity_tmp = .
replace ethnicity_tmp = 1 if ethnicity=="White"
replace ethnicity_tmp = 2 if ethnicity=="Mixed"
replace ethnicity_tmp = 3 if ethnicity=="South Asian"
replace ethnicity_tmp = 4 if ethnicity=="Black"
replace ethnicity_tmp = 5 if ethnicity=="Other"
replace ethnicity_tmp = 6 if ethnicity=="Missing"
lab def ethnicity_tmp 1 "White, inc. miss" 2 "Mixed" 3 "South Asian" 4 "Black" 5 "Other" 6 "Missing"
lab val ethnicity_tmp ethnicity_tmp
drop ethnicity
rename ethnicity_tmp cov_cat_ethnicity

* Recode deprivation

gen cov_cat_deprivation_tmp = .
replace cov_cat_deprivation_tmp = 1 if cov_cat_deprivation=="1-2 (most deprived)"
replace cov_cat_deprivation_tmp = 2 if cov_cat_deprivation=="3-4"
replace cov_cat_deprivation_tmp = 3 if cov_cat_deprivation=="5-6"
replace cov_cat_deprivation_tmp = 4 if cov_cat_deprivation=="7-8"
replace cov_cat_deprivation_tmp = 5 if cov_cat_deprivation=="9-10 (least deprived)"
lab def cov_cat_deprivation_tmp 1 "1-2 (most deprived)" 2 "3-4" 3 "5-6" 4 "7-8" 5 "9-10 (least deprived)"
lab val cov_cat_deprivation_tmp cov_cat_deprivation_tmp
drop cov_cat_deprivation
rename cov_cat_deprivation_tmp cov_cat_deprivation

* Recode smoking status

gen cov_cat_smoking_status_tmp = .
replace cov_cat_smoking_status_tmp = 1 if cov_cat_smoking_status=="Never smoker"
replace cov_cat_smoking_status_tmp = 2 if cov_cat_smoking_status=="Ever smoker"
replace cov_cat_smoking_status_tmp = 3 if cov_cat_smoking_status=="Current smoker"
replace cov_cat_smoking_status_tmp = 4 if cov_cat_smoking_status=="Missing"
lab def cov_cat_smoking_status_tmp 1 "Never smoker" 2 "Ever smoker" 3 "Current smoker" 4 "Missing"
lab val cov_cat_smoking_status_tmp cov_cat_smoking_status_tmp
drop cov_cat_smoking_status
rename cov_cat_smoking_status_tmp cov_cat_smoking_status 

*Recode BMI capture

gen cov_cat_bmi_groups_tmp = .
replace cov_cat_bmi_groups_tmp = 1 if cov_cat_bmi_groups=="Healthy_weight"  
replace cov_cat_bmi_groups_tmp = 2 if cov_cat_bmi_groups=="Underweight"  
replace cov_cat_bmi_groups_tmp = 3 if cov_cat_bmi_groups=="Overweight"  
replace cov_cat_bmi_groups_tmp = 4 if cov_cat_bmi_groups=="Obese"  
replace cov_cat_bmi_groups_tmp = 5 if cov_cat_bmi_groups=="Missing"  
lab def cov_cat_bmi_groups_tmp 1 "Healthy_weight" 2 "Underweight" 3 "Overweight" 4 "Obese" 5 "Missing" 
lab var cov_cat_bmi_groups_tmp cov_cat_bmi_groups_tmp
drop cov_cat_bmi_groups
rename cov_cat_bmi_groups_tmp cov_cat_bmi_groups

* Recode HDL ratio

gen cov_num_tc_hdl_ratio_tmp = cov_num_tc_hdl_ratio
replace cov_num_tc_hdl_ratio_tmp = "." if cov_num_tc_hdl_ratio=="NA"
destring cov_num_tc_hdl_ratio_tmp, replace
drop cov_num_tc_hdl_ratio
rename cov_num_tc_hdl_ratio_tmp cov_num_tc_hdl_ratio

* Summarize missingness following recoding

misstable summarize
	
* Make failure variable

gen outcome_status = 0
replace outcome_status = 1 if outcome_date!=.

* Update follow-up end

replace follow_up_end = follow_up_end + 1
format follow_up_end %td

* Make age spline

centile age, centile(10 50 90)
mkspline age_spline = age, cubic knots(`r(c_1)' `r(c_2)' `r(c_3)')

* Apply stset // including IPW here as if unsampled dataset will be 1

if `prevax_cohort'==1 {
	stset follow_up_end [pweight=cox_weights], failure(outcome_status) id(patient_id) enter(follow_up_start) origin(time mdy(01,01,2020))
	stsplit time, after(exposure_date) at(0 28 197 535)
	replace time = 535 if time==-1
} 
else {
	stset follow_up_end [pweight=cox_weights], failure(outcome_status) id(patient_id) enter(follow_up_start) origin(time mdy(01,06,2021))
	stsplit time, after(exposure_date) at(0 28 197)
	replace time = 197 if time==-1
}

* Calculate study follow up

gen follow_up = _t - _t0
egen follow_up_total = total(follow_up)  

* Make days variables

gen days0_28 = 0
replace days0_28 = 1 if time==0
tab days0_28

gen days28_197 = 0
replace days28_197 = 1 if time==28
tab days28_197

if `prevax_cohort'==1 {
	gen days197_535 = 0 
	replace days197_535 = 1 if time==197
	tab days197_535
}

* Run models and save output [Note: cannot use efron method with weights]

tab time outcome_status 

di "Total follow-up in days: " follow_up_total
bysort time: summarize(follow_up), detail

stcox days* i.sex age_spline1 age_spline2, strata(region) vce(r)
est store min, title(Age_Sex)
stcox days* i.sex age_spline1 age_spline2 i.cov_cat_ethnicity i.cov_cat_deprivation i.cov_cat_smoking_status i.cov_cat_bmi_groups cov_num_consulation_rate cov_num_tc_hdl_ratio cov_bin_*, strata(region) vce(r)
est store max, title(Maximal)

estout * using "output/`cpf'_cox_model.txt", cells("b se t ci_l ci_u p") stats(risk N_fail N_sub N N_clust) replace 

* Calculate median follow-up

keep if outcome_status==1
keep patient_id days* follow_up
gen term = ""

if `prevax_cohort'==1 {
	drop if days0_28==0 & days28_197==0 & days197_535==0	
	replace term = "days0_28" if days0_28==1 & days28_197==0 & days197_535==0
	replace term = "days28_197" if days0_28==0 & days28_197==1 & days197_535==0
	replace term = "days197_535" if days0_28==0 & days28_197==0 & days197_535==1 

} 
else {
	drop if days0_28==0 & days28_197==0
	replace term = "days0_28" if days0_28==1 & days28_197==0
	replace term = "days28_197" if days0_28==0 & days28_197==1
	replace term = "days197_535" if days0_28==0 & days28_197==0
	replace follow_up = follow_up + 197 if term == "days197_535" 
}

replace follow_up = follow_up + 28 if term == "days128_197" 
bysort term: egen medianfup = median(follow_up)

keep term medianfup
duplicates drop

export delimited using "output/`cpf'_stata_median_fup", replace

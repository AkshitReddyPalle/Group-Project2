import excel using "MaternalMortality-addtl-data.xlsx", clear sheet(Impute_2019) first
destring population, replace force
drop if missing(County)
replace County=trim(usubinstr(County,"*","",.))
replace County=trim(usubinstr(County,"‡","",.))
replace County=trim(usubinstr(County,"†","",.))
replace County=trim(usubinstr(County," ","",.))
replace County=trim(County)
gen cnty_fips=usubstr(ustrright(County,7),2,5)
gen state_fips=ustrleft(cnty_fips,2)
save "cnty_2019.dta", replace

import excel using "MaternalMortality-addtl-data.xlsx", clear sheet(State_2019) first
rename maternal_multi maternal_multi_st
replace state=trim(usubinstr(state,"*","",.))
gen state_fips=ustrleft(ustrright(state,3),2)
drop if missing(state)
save "state_2019.dta", replace

use "cnty_2019", clear 
merge m:1 state_fips using "state_2019.dta"
*Stage 1
bysort state_fips: egen reported_total1=total(maternal_multi)
gen gap1=maternal_multi_st-reported_total1
*Stage 2 
gen dist2=cond(all_deaths_under!=. & maternal_multi==., 1, maternal_multi)
bysort state_fips: egen reported_total2=total(dist2)
gen gap2=maternal_multi_st-reported_total2
*Stage 3
bysort state_fips:egen dist3_factor=total(cond(all_deaths_under!=. & maternal_multi==. & maternal_under!=0 & maternal_multi==., maternal_under,.)) if all_deaths_under!=. & maternal_multi==. & maternal_under!=0 & maternal_multi==.
gen dist3=cond(dist3_factor!=., dist2+(gap2/dist3_factor*maternal_under),dist2)
bysort state_fips: egen reported_total3=total(dist3)
*Stage 4
gen maternal_mortality_rate=dist3/population*100000
sum maternal_mortality_rate
keep County cnty_fips maternal_mortality_rate
gen year=2019
save "imputed_2019.dta", replace



import excel using "MaternalMortality-addtl-data.xlsx", clear sheet(Impute_2020) first
destring population, replace force
drop if missing(County)
replace County=trim(usubinstr(County,"*","",.))
replace County=trim(usubinstr(County,"‡","",.))
replace County=trim(usubinstr(County,"†","",.))
replace County=trim(usubinstr(County," ","",.))
replace County=trim(County)
gen cnty_fips=usubstr(ustrright(County,7),2,5)
gen state_fips=ustrleft(cnty_fips,2)
save "cnty_2020.dta", replace

import excel using "MaternalMortality-addtl-data.xlsx", clear sheet(State_2020) first
rename maternal_multi maternal_multi_st
replace state=trim(usubinstr(state,"*","",.))
gen state_fips=ustrleft(ustrright(state,3),2)
drop if missing(state)
save "state_2020.dta", replace

use "cnty_2020", clear 
merge m:1 state_fips using "state_2020.dta"
*Stage 1
bysort state_fips: egen reported_total1=total(maternal_multi)
gen gap1=maternal_multi_st-reported_total1
*Stage 2 
gen dist2=cond(all_deaths_under!=. & maternal_multi==., 1, maternal_multi)
bysort state_fips: egen reported_total2=total(dist2)
gen gap2=maternal_multi_st-reported_total2
*Stage 3
bysort state_fips:egen dist3_factor=total(cond(all_deaths_under!=. & maternal_multi==. & maternal_under!=0 & maternal_multi==., maternal_under,.)) if all_deaths_under!=. & maternal_multi==. & maternal_under!=0 & maternal_multi==.
gen dist3=cond(dist3_factor!=., dist2+(gap2/dist3_factor*maternal_under),dist2)
bysort state_fips: egen reported_total3=total(dist3)
*Stage 4
gen maternal_mortality_rate=dist3/population*100000
sum maternal_mortality_rate
keep County cnty_fips maternal_mortality_rate
gen year=2020
save "imputed_2020.dta", replace


use "imputed_2019.dta", clear
append using "imputed_2020"
export delimited "maternal_mortality_rate_imputed.csv", clear
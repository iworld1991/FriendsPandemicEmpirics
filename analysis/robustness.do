*------------------------------ Robustness results

/*************
- Table A.1. using growth rate as dependent variable 
- Table A.2. double cluster standard errors
- Table A.4-A.5: robustness with SCI weighted idio shocks
- Table A.6-A.7: robustness with SCI weighted idio and orthogonalized shocks
- Table A.9. sensitivity tests of different sample periods 
- Figure A.1. monthly consumption by category in 2020
- Figure A.5 France and Italy's covid cases 
- Figure A.6 comparison of the PCI and SCI
****************/

global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"

set scheme s1color


global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"

set scheme s1color
set more off, permanently 
capture log close 


*----------------------Additional regression results 


use "$friends/data/spending/spendbycountyD.dta",clear
** note: only avaiable in 2020. so the data merge below will keep data only for 2020

merge 1:1 user_county year month day using "$friends/data/facebook/covid_shocks_counties_SCI.dta", ///
      keep(match)
rename _merge fb_shocks_merge 

merge 1:1 user_county year month day using "$friends/data/facebook/covid_counties_SCI.dta", ///
      keep(match)
rename _merge fb_merge 

merge 1:1 user_county year month day using "$friends/data/facebook/covid_counties_SCI_far.dta", ///
       keep(match) 
rename _merge fb_shocks_far_merge 

gen county = user_county 
 
merge 1:1 county year month day using "${friends}data/physical/covid_counties_PCI.dta", ///
      keep(match)
rename _merge pci_merge 


merge m:1 county using "$friends/data/facebook/country_SCI_selected.dta", ///
      keep(master match)
rename _merge fb_ctry_merge 


merge m:1 month day using "$friends/data/other/covid_world_cases.dta", ///
          keep(master match) 
rename _merge world_case_merge
drop date 

merge m:1 month day using "$friends/data/other/covid_world_deaths.dta", ///
          keep(master match) 
rename _merge world_death_merge
drop date 

merge m:1 county using "$friends/data/social explorer/acs2014_2018.dta", ///
      keep(master match)
rename _merge acs_merge 

merge m:1 county year month day county using "$friends/data/other/covid_jhu.dta", ///
      keep(master match)
rename _merge jhu_case_merge 


merge 1:1 county year month day using "$friends/data/other//mobility_county_D.dta", ///
      keep(master match)
rename _merge mobility_merge 


merge m:1 county using "$friends/data/social explorer/county_heterog_indicators.dta", ///
                 keep(master match)
rename _merge indicator_merge 

gen countyfips = county 
merge 1:1 countyfips month day using "$friends/data/spending/spend2bycountyD.dta", ///
                 keep(master match)
rename _merge affinity_merge 
drop countyfips
rename spend_all ltotal_spend2_chg
label var ltotal_spend2_chg "log change in total spending from jan 2020 (affinity)"  /* smaller sample: i.e. 1481 counties"*/


gen st =floor(fips/1000)
label var st "state fips"

merge m:1 st month day using "$friends/data/other/state_policies.dta", ///
          keep(master match) 
rename _merge spol_merge 
drop date 


table year 

*------------------------------ date and panel structure

gen date = mdy(month,day,year)
format date %td 
order fips date year month day 
xtset fips date 

*------------------------------ new variables 

gen state = floor(fips/1000)
label var state "state fips"

foreach var in total_spend{
gen l`var' = log(`var')
}


foreach var in cases deaths lag7_cases lag14_cases lag7_deaths ///
      lag14_deaths casesSCI_loo deathsSCI_loo casesnormSCI_all deathsnormSCI_all ///
	   casesnormSCI_loo deathsnormSCI_loo ///
	    casesnormSCInost_loo deathsnormSCInost_loo ///
		casesSCI_loo_far deathsSCI_loo_far casesnormSCI_all_far deathsnormSCI_all_far ///
	   casesnormSCI_loo_far deathsnormSCI_loo_far ///
	    casesnormSCInost_loo_far deathsnormSCInost_loo_far{
			gen l`var' = log(`var'+1)
}

foreach var in ltotal_spend{
gen `var'_gr = `var' -l7.`var'
label var `var'_gr "log spending growth since last week"
}

*------------------------------ some filters to avoid outliers 
drop if num_cards <= 10

* exclude extreme values for total spending 
egen total_spend_ub = pctile(total_spend), p(98)
egen total_spend_lb = pctile(total_spend), p(2)
replace total_spend=. if total_spend<= total_spend_lb | total_spend >= total_spend_ub


**---------------- time filter 

table year 
keep if year==2020

gen md = month*100+day

keep if md< 400

*---------------------Table A.1 using growth rate as dependent variable 


tsset fips date

global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

reghdfe ltotal_spend2_chg lcasesnormSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths $stateX, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp3
reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "Yes",replace
est sto temp4

reghdfe ltotal_spend2_chg ldeathsnormSCI_loo, a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp5
reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths $stateX, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "Yes",replace
est sto temp8


la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"

local tokeep "lcasesnormSCI_loo ldeathsnormSCI_loo lcases ldeaths"

esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 using "$friends/table/baseline_friends_spend_outofstate_growthrate_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") nonum  brackets se mgroups("log(Consumption Expenditures) growth", pattern(1 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Day FE" "State Policies" "State/Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*---------------------Table A.2. regression robustness with cluster standard errors by both county date 

gen lcasesnormSCI_loo_saho=saho*lcasesnormSCI_loo
gen lcasesnormSCI_loo_sahooff=saho_off*lcasesnormSCI_loo
gen ldeathsnormSCI_loo_saho=saho*ldeathsnormSCI_loo
gen lcasesnormSCInost_loo_saho=saho*lcasesnormSCInost_loo

global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 


reghdfe ltotal_spend lcasesnormSCI_loo [aw=totpop], a(fips date) vce(cluster fips date)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend lcasesnormSCI_loo lcasesnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend lcasesnormSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend ldeathsnormSCI_loo, a(fips date) vce(cluster fips date)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths, a(fips date) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend ldeathsnormSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend ldeathsnormSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips date)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp10


la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormSCInost_loo "log(SCI-weighted Cases, Other States)"
la var ldeathsnormSCInost_loo "log(SCI-weighted Deaths, Other States)"
la var lcasesnormSCI_loo_saho "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho "\quad $\times$ SAHO"
la var saho "Has SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"

local tokeep "saho lcasesnormSCI_loo lcasesnormSCI_loo_saho ldeathsnormSCI_loo ldeathsnormSCI_loo_saho lcasesnormSCInost_loo ldeathsnormSCInost_loo lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 using "$friends/table/baseline_friends_spend_outofstate_norm_double_cluster.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*--------------------Table.A4-A5 regression analysis with idio shocks . whole group 


gen lcasesnormSCI_loo_saho=saho*lcasesshock_normSCI_loo
gen lcasesnormSCI_loo_sahooff=saho_off*lcasesshock_normSCI_loo
gen ldeathsnormSCI_loo_saho=saho*ldeathsshock_normSCI_loo
gen lcasesnormSCInost_loo_saho=saho*ldeathsshock_normSCInost_loo


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 

xtscc ltotal_spend lcasesshock_normSCI_loo , fe 


reghdfe ltotal_spend lcasesshock_normSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend lcasesshock_normSCI_loo lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend lcasesshock_normSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend lcasesshock_normSCI_loo lcasesnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend lcasesshock_normSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend ldeathsshock_normSCI_loo, a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend ldeathsshock_normSCI_loo lcases ldeaths, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend ldeathsshock_normSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend ldeathsshock_normSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend ldeathsshock_normSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp10


la var lcasesshock_normSCI_loo "SCI-weighted Shocks to Cases"
la var ldeathsshock_normSCI_loo "SCI-weighted Shocks to Deaths"

la var lcasesshock_normSCInost_loo "SCI-weighted Shocks to Cases, Other States"
la var ldeathsshock_normSCInost_loo "SCI-weighted Shocks to Deaths, Other States"

la var lcasesnormSCI_loo_saho "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho "\quad $\times$ SAHO"
la var saho "Has SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"


local tokeep "saho lcasesshock_normSCI_loo lcasesnormSCI_loo_saho ldeathsshock_normSCI_loo ldeathsnormSCI_loo_saho lcasesnormSCInost_loo ldeathsshock_normSCInost_loo lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 using "${friends}/table/robustness_shocks_friends_spend_outofstate_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*--------------------Table A.6-A.7: regression analysis with orthogonalized and idiosyncratic shocks . whole group 


gen lcasesnormSCI_loo_saho=saho*dl1casesshock_normSCI_loo
gen lcasesnormSCI_loo_sahooff=saho_off*dl1casesshock_normSCI_loo
gen ldeathsnormSCI_loo_saho=saho*dl1deathsshock_normSCI_loo
gen lcasesnormSCInost_loo_saho=saho*dl1deathsshock_normSCInost_loo


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 

xtscc ltotal_spend lcasesshock_normSCI_loo , fe 


reghdfe ltotal_spend dl1casesshock_normSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend dl1casesshock_normSCI_loo lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend dl1casesshock_normSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend dl1casesshock_normSCI_loo lcasesnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend dl1casesshock_normSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend dl1deathsshock_normSCI_loo, a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend dl1deathsshock_normSCI_loo lcases ldeaths, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend dl1deathsshock_normSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend dl1deathsshock_normSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend dl1deathsshock_normSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp10


la var dl1casesshock_normSCI_loo "SCI-weighted Shocks to Cases"
la var dl1deathsshock_normSCI_loo "SCI-weighted Shocks to Deaths"

la var dl1casesshock_normSCInost_loo "SCI-weighted Shocks to Cases, Other States"
la var dl1deathsshock_normSCInost_loo "SCI-weighted Shocks to Deaths, Other States"

la var lcasesnormSCI_loo_saho "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho "\quad $\times$ SAHO"
la var saho "Has SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"



local tokeep "saho dl1casesshock_normSCI_loo lcasesnormSCI_loo_saho dl1casesshock_normSCInost_loo lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 using "${friends}/table/robustness_cases_iid_shocks.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)

local tokeep "saho dl1deathsshock_normSCI_loo ldeathsnormSCI_loo_saho dl1deathsshock_normSCInost_loo lcases ldeaths"
esttab temp6 temp7 temp8 temp9 temp10 using "${friends}/table/robustness_deaths_iid_shocks.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


***---------------------------Additional results with longer sample of Affinity Data

use "$friends/data/spending/spend2_bycounty_D_long.dta",clear
* longer data sample 

gen date = mdy(month, day, year)
format date %td 
rename countyfips county 

rename spend_all ltotal_spend2_chg
label var ltotal_spend2_chg "log change in total spending from jan 2020 (affinity)"  /* smaller sample: i.e. 1481 counties"*/

gen user_county = county 

merge 1:1 user_county year month day using "$friends/data/facebook/covid_shocks_counties_SCI.dta", ///
      keep(match)
rename _merge fb_shocks_merge 


merge 1:1 user_county year month day using "$friends/data/facebook/spend_shocks_counties_SCI.dta", ///
      keep(match)
rename _merge spend_shocks_merge 

merge 1:1 user_county year month day using "$friends/data/facebook/covid_counties_SCI.dta", ///
      keep(match)
rename _merge fb_merge 


merge m:1 county year month day county using "$friends/data/other/covid_jhu.dta", ///
      keep(master match)
rename _merge jhu_case_merge 


merge m:1 county using "$friends/data/social explorer/acs2014_2018.dta", ///
      keep(master match)
rename _merge acs_merge 

xtset county date 

*------------------------------ new variables 

gen state = floor(county/1000)
label var state "state fips"


foreach var in cases deaths lag7_cases lag14_cases lag7_deaths ///
      lag14_deaths casesSCI_loo deathsSCI_loo casesnormSCI_all deathsnormSCI_all ///
	   casesnormSCI_loo deathsnormSCI_loo ///
	   casesnormSCInost_loo deathsnormSCInost_loo{
gen l`var' = log(`var'+1)
}



foreach var in ltotal_spend{
gen `var'_gr = `var' -l7.`var'
label var `var'_gr "log spending growth since last week"
}


*------------------------------Table A.3 Robustness: consumption shocks not covid shocks


reghdfe ltotal_spend2_chg spendshock_normSCI_loo lcases ldeaths if year==2020 & month<=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1

reghdfe ltotal_spend2_chg spendshock_normSCInost_loo lcases ldeaths if year==2020 & month<=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2

reghdfe ltotal_spend2_chg spendshock_normSCI_loo lcases ldeaths if year==2020 & month>=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp3

reghdfe ltotal_spend2_chg spendshock_normSCInost_loo lcases ldeaths if year==2020 & month>=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp4

reghdfe ltotal_spend2_chg spendshock_normSCI_loo lcases ldeaths if year==2021, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp5

reghdfe ltotal_spend2_chg spendshock_normSCInost_loo lcases ldeaths if year==2021, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6

reghdfe ltotal_spend2_chg spendshock_normSCI_loo lcases ldeaths if year==2022, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7

reghdfe ltotal_spend2_chg spendshock_normSCInost_loo lcases ldeaths  if year==2022, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp8

la var spendshock_normSCI_loo "SCI-weighted Shocks to Spending"
la var spendshock_normSCInost_loo "SCI-weighted Shocks to Spending, Other States"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"

local tokeep "spendshock_normSCI_loo spendshock_normSCInost_loo lcases ldeaths"

esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 using "${friends}/table/robustness_consumption_shocks_friends_spend_outofstate_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("2020H1" "2020H1" "2020H2" "2020H2" "2021" "2021" "2022" "2022") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*------------------------------Table A.9. Robustness: different time sample 


reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths [aw=totpop] if year==2020 & month>=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp1

reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths [aw=totpop] if year==2020 & month>=6, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp2

reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths [aw=totpop] if year==2021, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp3

reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths [aw=totpop] if year==2021, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp4

reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths  [aw=totpop]if year==2022, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp5

reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths  [aw=totpop] if year==2022, a(county date) vce(cluster county)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto temp6

la var lcasesshock_normSCI_loo "SCI-weighted Shocks to Cases"
la var ldeathsshock_normSCI_loo "SCI-weighted Shocks to Deaths"

la var lcasesshock_normSCInost_loo "SCI-weighted Shocks to Cases, Other States"
la var ldeathsshock_normSCInost_loo "SCI-weighted Shocks to Deaths, Other States"

la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"

la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormSCInost_loo "log(SCI-weighted Cases, Other States)"
la var ldeathsnormSCInost_loo "log(SCI-weighted Deaths, Other States)"


local tokeep "lcasesnormSCI_loo ldeathsnormSCI_loo lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 using "${friends}/table/robustness_long_sample_outofstate_norm_affinity.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("2020H2" "2020H2" "2021" "2021" "2022" "2022") nonum  brackets se mgroups("log(Consumption Expenditures) Growth", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast, label("R-squared" "Sample Size" "County FE" "Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)



*----------------------- Figure A.5 comparison of different foreign countries' time-patterns of Covid cases

use "$friends/data/other/covid_world_cases.dta",clear
 
twoway (line cases_italy date, clcolor(dknavy) clwidth(thin) clpattern(solid) ) (line cases_france date, clcolor(red*1.2) clwidth(thin) clpattern(dash) ) , xtitle("Date") legend(order(1 "Italy" 2 "France")) ytitle("Number of COVID-19 Cases")
graph export "$friends/graph/timeseries_ita_fra_covid.pdf", as(pdf) replace


*------------------------------Figure A.6 comparison of the PCI and SCI

use "$friends/data/facebook/covid_counties_SCI_monthly.dta",clear
ren user_county county
merge 1:m county year month using "$friends/data/physical/covid_counties_PCI_monthly.dta"
keep if _merge==3
drop _merge
gen lcasesnormSCI_loo=log(casesnormSCI_loo)
gen lcasesnormPCI_loo=log(casesnormPCI_loo)

**sample period corresponding to original chart in the draft

keep if year==2020 & month<=6

corr casesnormSCI_loo casesnormPCI_loo
local temp1: di %3.2f r(rho)
heatplot casesnormSCI_loo casesnormPCI_loo,ytitle("Normalized SCI-weighted Cases") xtitle("Normalized PCI-weighted Cases") note(Correlation = `temp1')
graph export "$friends/graph/heatplot_cases_SCI_PCI.pdf", as(pdf) replace

corr deathsnormSCI_loo deathsnormPCI_loo
local temp1: di %3.2f r(rho)
heatplot deathsnormSCI_loo deathsnormPCI_loo,ytitle("Normalized SCI-weighted Deaths") xtitle("Normalized PCI-weighted Deaths") note(Correlation = `temp1')
graph export "$friends/graph/heatplot_deaths_SCI_PCI.pdf", as(pdf) replace


corr casesnormSCI_loo casesnormPCI_loo
local temp1: di %3.2f r(rho)
binscatter casesnormSCI_loo casesnormPCI_loo,ytitle("Normalized SCI-weighted Cases") xtitle("Normalized PCI-weighted Cases") note(Correlation = `temp1')
graph export "$friends/graph/compare_cases_SCI_PCI.pdf", as(pdf) replace

corr deathsnormSCI_loo deathsnormPCI_loo
local temp1: di %3.2f r(rho)
binscatter deathsnormSCI_loo deathsnormPCI_loo,ytitle("Normalized SCI-weighted Deaths") xtitle("Normalized PCI-weighted Deaths") note(Correlation = `temp1')
graph export "$friends/graph/compare_deaths_SCI_PCI.pdf", as(pdf) replace



*-----------------------------------------Figure A.1. bar plot by category 

use "$friends/data/spending/spend_group_D.dta",clear

** decode and encode again

decode catcode1, gen(category)
replace category = "alcohol and tobacoo" if category=="alcohol and tabacoo"
drop catcode1 
encode category, gen(catcode)



** change units 

replace total_spend = total_spend/1000000
label var total_spend "total spending in million dollars"
replace num_transactions = num_transactions/1000
label var total_spend "total number of transactions in thousand"

** gen log 
gen lspend = log(total_spend) 
label var lspend "log spending"


** month and day filter 
gen md = month*100+day



** different time 
preserve 

keep if md>=200 & md<700 & year==2020


** plot the average 
graph hbar (mean) total_spend, ///
       over(month,relabel(1 "Feb" 2 "March" 3 "April" 4 "May" 5 "June")) ///
       over(catcode,sort(1)) ///
	   asyvar ///
	   bar(1, color(blue*0.6)) bar(2, color(red*0.7)) ///
	   legend(col(3)) ///
	   ytitle("average daily spending in million dollars")
	   
graph export "${friends}graph/category/bar_bycategory.png",as(png) replace 


restore

** collapse to month

collapse (sum) total_spend num_transactions, by(catcode year month) 

gen date_string = string(year)+ "M"+string(month) 

gen date = monthly(date_string,"YM")
format date %tm
drop date_string 


** set it to panel 
xtset catcode date

** reshape to a wide format 

preserve
drop num_transactions
reshape wide total_spend, i(date) j(catcode) 
save "${friends}data/spending/spend_groupM.dta",replace
restore

* this is for validating consumption measures. 

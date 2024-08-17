*------------------------------ Main results in the paper


/*************
- merge it with SCI, census and other dataset
analysis  
- Figure A.3-A.4 
- Table 1. baseline regression results  
- Table 2. heterogeneity analysis 
- Table 3. robustness with phsyical distance weighted measures controlled 
- Table 4. 
- Table 5. 
- Table 6. internationl analysis 
 - Table A.10. additional countries 
- Table A.8 robustness using alternative consumption measure 

****************/

global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"

set scheme s1color

clear
set more off, permanently 
capture log close 

*------------------------------ merge with SCI and other data 

use "$friends/data/spending/spendbycountyD.dta",clear
** this data is only for 2020. So following merge will only keep 2020 data. 

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

merge 1:1 county year month day using "$friends/data/physical/covid_counties_PCI.dta", ///
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

*------------------------------ date and panel structure

gen date = mdy(month,day,year)
format date %td 
order fips date year month day 
xtset fips date 

*------------------------------ per capita consumption

gen spend_pc = total_spend/totpop
label var spend_pc "spend per capita"

gen trans_pc = num_transactions/totpop
label var trans_pc "nb of transactions by per capita"

*------------------------------ new variables 

gen state = floor(fips/1000)
label var state "state fips"

foreach var in total_spend spend_pc trans_pc pcincome hhincome totpop{
gen l`var' = log(`var')
}

foreach var in in cases deaths lag7_cases lag14_cases lag7_deaths ///
      lag14_deaths casesSCI_loo deathsSCI_loo casesnormSCI_all deathsnormSCI_all ///
	   casesnormSCI_loo deathsnormSCI_loo ///
	    casesnormSCInost_loo deathsnormSCInost_loo ///
		casesSCI_loo_far deathsSCI_loo_far casesnormSCI_all_far deathsnormSCI_all_far ///
	   casesnormSCI_loo_far deathsnormSCI_loo_far ///
	    casesnormSCInost_loo_far deathsnormSCInost_loo_far casesnormPCI_loo deathsnormPCI_loo{
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

keep if year==2020
gen md = month*100+day

************************************************
* note that this changes depending on the table 
keep if md>=315 & md<=700
**********************************************



*------------------------Figure A.3-A.4 Map files 

gen county = fips 

** cases

maptile casespc if year==2020 & month==4 & day==15, ///
            geo(county2014) twopt(title("Nb of cases per thousand (Apr 1st 2020)")) ///
			cutvalues(0.15 0.35 0.75) fcolor(Greens) /// 
			savegraph("${friends}/graph/map_casespc.png") ///
			replace 

maptile casespcSCIadj if year==2020 & month==4 & day==15, ///
            geo(county2014) twopt(title("Nb of cases per thousand on Facebook (Apr 1st 2020)")) ///
			cutvalues(5 15 20 30) fcolor(Blues) /// 
			savegraph("${friends}/graph/map_casespcSCIadj.png") ///
			replace 
		
			
maptile casespcnormSCIadj if year==2020 & month==4 & day==15, ///
            geo(county2014) twopt(title("Nb of cases per thousand on Facebook (Apr 1st 2020)")) ///
			cutvalues(0.5 2 5 50 100) fcolor(Blues) /// 
			savegraph("${friends}/graph/map_casesnormSCIadj.png") ///
			replace 

** deaths

maptile deathspc if year==2020 & month==4 & day==15, ///
            geo(county2014) twopt(title("Nb of deaths per thousand (Apr 1st 2020)")) ///
			cutvalues(0.01 0.05 0.1 0.2) fcolor(Greys2) /// 
			savegraph("${friends}/graph/map_deathspc.png") ///
			replace 
			
maptile deathspcSCIadj if year==2020 & month==4 & day==15, ///
            geo(county2014) twopt(title("Nb of deaths per thousand on Facebook (Apr 1st 2020)")) ///
			cutvalues(0.2 0.6 1 3) fcolor(Purples) /// 
			savegraph("${friends}/graph/map_deathspcSCIadj.png") ///
			replace 


*----------------------------Table 1. friends and behaviors: regression analysis. whole group 


gen lcasesnormSCI_loo_saho=saho*lcasesnormSCI_loo
gen lcasesnormSCI_loo_sahooff=saho_off*lcasesnormSCI_loo
gen ldeathsnormSCI_loo_saho=saho*ldeathsnormSCI_loo
gen lcasesnormSCInost_loo_saho=saho*lcasesnormSCInost_loo
*llag7_cases llag7_deaths llag14_cases llag14_deaths


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 

xtscc ltotal_spend lcasesnormSCI_loo , fe 


reghdfe ltotal_spend lcasesnormSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend lcasesnormSCI_loo lcasesnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend lcasesnormSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend ldeathsnormSCI_loo, a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend ldeathsnormSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend ldeathsnormSCInost_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
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
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 using "${friends}/table/baseline_friends_spend_outofstate_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*-------------------------------Table 3. Robustness using physical distance 


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

reghdfe ltotal_spend lcasesnormSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend lcasesnormSCI_loo lcasesnormPCI_loo [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend lcasesnormSCI_loo lcasesnormPCI_loo $stateX [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp3
reghdfe ltotal_spend lcasesnormSCI_loo lcasesnormPCI_loo llag14_cases llag14_deaths $stateX [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp4
reghdfe ltotal_spend ldeathsnormSCI_loo [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp5
reghdfe ltotal_spend ldeathsnormSCI_loo ldeathsnormPCI_loo [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend ldeathsnormSCI_loo ldeathsnormPCI_loo $stateX [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend ldeathsnormSCI_loo ldeathsnormPCI_loo llag14_cases llag14_deaths $stateX [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "No",replace
est sto temp8


la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormPCI_loo "log(PCI-weighted Cases)"
la var ldeathsnormPCI_loo "log(PCI-weighted Deaths)"
la var llag14_cases "log(County Cases), 14 day Lag"
la var llag14_deaths "log(County Deaths), 14 day Lag"
local tokeep "lcasesnormSCI_loo ldeathsnormSCI_loo lcasesnormPCI_loo ldeathsnormPCI_loo llag14_cases llag14_deaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 using "${friends}/table/baseline_robust_PCI.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*-----------------------------Table 2 friends and behaviors: regression analysis. sub group 

** normalized 

eststo clear 

reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highpcinc==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp1
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highpcinc==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp2
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highage_under35==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths  if highage_under35==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths  if highage_over65==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths  if highage_over65==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp6
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths  if highpop==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp7
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths  if highpop==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highIT==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highIT==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp10
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highTELE==1,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp11
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths if highTELE==0,a(fips date) vce(cl fips)
estadd local hascty "Yes",replace
estadd local hast "Yes",replace
estadd local hasstY "Yes",replace
est sto temp12

la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormSCI_loo_saho "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho "\quad $\times$ SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"
local tokeep "lcasesnormSCI_loo lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 temp11 temp12 using "${friends}/table/subgroup_friends_spend_heterog_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low" "High" "Low") nonum  brackets se mgroups("Per Capita Income" "Share Under Age 35" "Share Over Age 65" "Population" "Digital Intensity" "Teleworking Intensity", pattern(1 0 1 0 1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hascty hast, label("R-squared" "Sample Size" "County FE" "Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("RHS Variable Partition = ") eqlabel(none)    



*--------------------Table 4. friends and behaviors: regression analysis with only remote SCI counties


gen lcasesnormSCI_loo_saho_far=saho*lcasesnormSCI_loo_far
gen lcasesnormSCI_loo_sahooff_far=saho_off*lcasesnormSCI_loo_far
gen ldeathsnormSCI_loo_saho_far=saho*ldeathsnormSCI_loo_far
gen lcasesnormSCInost_loo_saho_far=saho*ldeathsnormSCInost_loo_far


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 


reghdfe ltotal_spend lcasesnormSCI_loo_far [aw=totpop], a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp1
reghdfe ltotal_spend lcasesnormSCI_loo_far lcases ldeaths [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp2
reghdfe ltotal_spend lcasesnormSCI_loo_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend lcasesnormSCI_loo_far lcasesnormSCI_loo_saho_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp4
reghdfe ltotal_spend lcasesnormSCInost_loo_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp5
reghdfe ltotal_spend ldeathsnormSCI_loo_far, a(fips date) vce(cluster fips)
ereturn list
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp6
reghdfe ltotal_spend ldeathsnormSCI_loo_far lcases ldeaths, a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "No",replace
estadd local hasstY "No",replace
est sto temp7
reghdfe ltotal_spend ldeathsnormSCI_loo_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8
reghdfe ltotal_spend ldeathsnormSCI_loo_far ldeathsnormSCI_loo_saho_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp9
reghdfe ltotal_spend ldeathsnormSCInost_loo_far lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp10


la var lcasesnormSCI_loo_far "SCI-weighted Cases Far"
la var ldeathsnormSCI_loo_far "SCI-weighted Deaths Far"

la var lcasesnormSCInost_loo_far "SCI-weighted Cases Far, Other States "
la var ldeathsnormSCInost_loo_far "SCI-weighted Deaths Far, Other States"

la var lcasesnormSCI_loo_saho_far "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho_far "\quad $\times$ SAHO"
la var saho "Has SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"


local tokeep "saho lcasesnormSCI_loo_far lcasesnormSCI_loo_saho_far ldeathsnormSCI_loo_far ldeathsnormSCI_loo_saho_far lcasesnormSCInost_loo_far ldeathsnormSCInost_loo_far lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 temp9 temp10 using "${friends}/table/robustness_shocks_friends_spend_far_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)


*--------------------Table 5. robustness: controlling for mobility. whole group 

gen lcasesnormSCI_loo_saho=saho*lcasesnormSCI_loo
gen lcasesnormSCI_loo_sahooff=saho_off*lcasesnormSCI_loo
gen ldeathsnormSCI_loo_saho=saho*ldeathsnormSCI_loo
gen lcasesnormSCInost_loo_saho=saho*lcasesnormSCInost_loo

global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 

xtscc ltotal_spend lcasesnormSCI_loo , fe 

   
reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths gps_transit_stations $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp1

reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths gps_workplaces  $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp2

reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths gps_residential $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp3


reghdfe ltotal_spend lcasesnormSCI_loo lcases ldeaths gps_away_from_home $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp4

reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths gps_transit_stations $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp5

reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths gps_workplaces $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp6


reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths gps_residential $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp7

reghdfe ltotal_spend ldeathsnormSCI_loo lcases ldeaths gps_away_from_home [aw=totpop], a(fips date) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace

est sto temp8


la var gps_residential "time at home"
la var gps_workplaces "time at workplace"
la var gps_away_from_home "time away from home"
la var gps_transit_stations "time at transit"


la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormSCInost_loo "log(SCI-weighted Cases, Other States)"
la var ldeathsnormSCInost_loo "log(SCI-weighted Deaths, Other States)"

la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"

local tokeep "lcasesnormSCI_loo ldeathsnormSCI_loo lcases ldeaths gps_residential gps_workplaces gps_away_from_home gps_transit_stations"

esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 using "${friends}/table/robutness_mobility_norm.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)

*------------------------------Table 6. cross-country evidence

rename deaths_spaine deaths_spain 

rename cases_italy cases_ITA
rename deaths_italy deaths_ITA
rename cases_spain cases_SPA
rename deaths_spain deaths_SPA
rename cases_france cases_FRA
rename deaths_france deaths_FRA
rename cases_southkorea cases_SK
rename deaths_southkorea deaths_SK 
rename cases_japan cases_JAP
rename deaths_japan deaths_JAP
rename cases_singapore cases_SINGA
rename deaths_singapore deaths_SINGA
rename sci_italy sci_ITA
rename sci_spain sci_SPA
rename sci_southkorea sci_SK
rename sci_france sci_FRA
rename sci_japan sci_JAP
rename sci_singapore sci_SINGA

local countryvars cases_ITA cases_SPA cases_SK cases_FRA cases_JAP cases_SINGA ///
                  deaths_ITA deaths_SPA deaths_SK deaths_FRA deaths_JAP deaths_SINGA

foreach var in `countryvars'{
gen l`var' = log(`var'+1)
label var l`var' "log `var'"
}

** regression with interaction terms 

gen lcasesSCI_cty = . 
la var lcasesSCI_cty "log(SCI-weighted cases of the country)"
gen ldeathsSCI_cty = .
la var ldeathsSCI_cty "log(SCI-weighted deaths of the country)"

gen SCI_cty_exposure = .
la var SCI_cty_exposure "SCI exposure to a foreign country"

eststo clear

foreach cty in ITA SPA FRA SK{
replace SCI_cty_exposure = sci_`cty'/totpop
summarize SCI_cty_exposure 
replace lcasesSCI_cty = lcases_`cty'*SCI_cty_exposure
replace ldeathsSCI_cty = ldeaths_`cty'*SCI_cty_exposure
*replace lcasesSCI_cty = log(cases_`cty'*sci_`cty')
*replace ldeathsSCI_cty = log(deaths_`cty'*sci_`cty')

** cases 
reghdfe ltotal_spend lcases ldeaths lcasesSCI_cty, a(date fips) vce(cl fips) 
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto country_`cty'1, title(`cty')

** deaths 
reghdfe ltotal_spend lcases ldeaths ldeathsSCI_cty, a(date fips) vce(cl fips) 
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto country_`cty'2, title(`cty')
}

local tokeep "lcasesSCI_cty ldeathsSCI_cty lcases ldeaths"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"
la var lcasesSCI_cty "log(SCI-weighted Cases)"
la var ldeathsSCI_cty "log(SCI-weighted Deaths)"

esttab country_* using "${friends}/table/cross_country_friends_spend_after2020march.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("ITA" "ITA" "SPA" "SPA" "FRA" "FRA" "SK" "SK") nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast, label("R-squared" "Sample Size" "County FE" "Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)    


esttab country_* using "$friends/table/cross_country_friends_spend_after2020march.csv", ///
             b(3) replace star(* 0.10 ** 0.05 *** 0.01)  ///
			 mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
			 nonum  brackets se ///
			 mlabels(,titles) ///
			 mgroups("log(Consumption Expenditures)", ///
			 pattern(1 0 0 0 0 0 0 0) ///
			 prefix(\multicolumn{@span}{c}{) suffix(}) ///
			 span erepeat(\cmidrule(lr){@span})) ///
			 label ///
			 keep(`tokeep') ///
			 order(`tokeep') ///
			 stats(r2 N  hasct hast, ///
			 label("R-squared" "Sample Size" "County FE" "Day FE") ///
			 fmt(2 0)) ///
			 parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)
*/

*--------------------Table A.10. cross-country evidence  additional countries 

eststo clear

foreach cty in JAP SINGA{
replace SCI_cty_exposure = sci_`cty'/totpop
summarize SCI_cty_exposure 
replace lcasesSCI_cty = lcases_`cty'*SCI_cty_exposure
replace ldeathsSCI_cty = ldeaths_`cty'*SCI_cty_exposure

** cases 
reghdfe ltotal_spend lcases ldeaths lcasesSCI_cty, a(date fips) vce(cl fips) 
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto country_`cty'1, title(`cty')

** deaths 
reghdfe ltotal_spend lcases ldeaths ldeathsSCI_cty, a(date fips) vce(cl fips) 
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
est sto country_`cty'2, title(`cty')
}

local tokeep "lcasesSCI_cty ldeathsSCI_cty lcases ldeaths"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"
la var lcasesSCI_cty "log(SCI-weighted Cases)"
la var ldeathsSCI_cty "log(SCI-weighted Deaths)"

esttab country_JAP* country_SINGA* using "${friends}/table/cross_country_friends_spend_after2020march_other_countries.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("JAP" "JAP" "SINGA" "SINGA" ) nonum  brackets se mgroups("log(Consumption Expenditures)", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast, label("R-squared" "Sample Size" "County FE" "Time FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none) 


*------------------------------Table A.8 robustness using alternative spending data from affinity (including credit card)


global stateX st_emerg saho saho_off bus_close_all bus_open_any reclose_any

tsset fips date

** adjusted SCI index with normalization 

xtscc ltotal_spend lcasesnormSCI_loo , fe 

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
reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp3
reghdfe ltotal_spend2_chg lcasesnormSCI_loo lcasesnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
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
reghdfe ltotal_spend2_chg ldeathsnormSCI_loo lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp7
reghdfe ltotal_spend2_chg ldeathsnormSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths $stateX, a(fips date st#month) vce(cluster fips)
estadd local hasct "Yes",replace
estadd local hast "Yes",replace
estadd local hasstpol "Yes",replace
estadd local hasstY "Yes",replace
est sto temp8


la var lcasesnormSCI_loo "log(SCI-weighted Cases)"
la var ldeathsnormSCI_loo "log(SCI-weighted Deaths)"
la var lcasesnormSCInost_loo "log(SCI-weighted Cases, Other States)"
la var ldeathsnormSCInost_loo "log(SCI-weighted Deaths, Other States)"
la var lcasesnormSCI_loo_saho "\quad $\times$ SAHO"
la var ldeathsnormSCI_loo_saho "\quad $\times$ SAHO"
la var saho "Has SAHO"
la var lcases "log(County Cases)"
la var ldeaths "log(County Deaths)"
local tokeep "saho lcasesnormSCI_loo lcasesnormSCI_loo_saho ldeathsnormSCI_loo ldeathsnormSCI_loo_saho lcases ldeaths"
esttab temp1 temp2 temp3 temp4 temp5 temp6 temp7 temp8 using "${friends}/table/baseline_friends_spend_outofstate_norm_affinity.tex", b(3) replace star(* 0.10 ** 0.05 *** 0.01)  mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" ) nonum  brackets se mgroups("log(Consumption Expenditures) Growth", pattern(1 0 0 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) label keep(`tokeep') order(`tokeep') stats(r2 N hasct hast hasstpol hasstY, label("R-squared" "Sample Size" "County FE" "Time FE" "State Policies" "State x Month FE") fmt(2 0)) parentheses nolz nogaps fragment nolines prehead("Dep. var. = ") eqlabel(none)
local tokeep "saho lcasesnormSCI_loo lcasesnormSCI_loo_saho lcasesnormSCInost_loo lcases ldeaths"


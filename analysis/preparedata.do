*------------------------------ Prepare data and processing it 

/*************

- clean Facebook SCI index 
  - for both county-to-county and country-to-CounTRY
- clean Covid daily and monthly case/death data from JHU 
  - by both counTY and counTRY  
- create SCI weighted cases/deaths 
   - daily and then monthly 
   - and one with only counties +500 miles away 
- create PCI weighted cases/deaths 
- clean data on stay at home orders
- clean acs data for county heterogeneity variables 
  - clean ipums census data for the share of IT 
- clean laus county data 
- clean Google mobility data 
- prepare idiosyncratic/orthogonalized covid shocks 
- prepare idiosyncratic/orthogonalized consumption shocks 

****************/

*global friends C:\Users\chris\Dropbox\1Publication and Research\2020 - Consumption and social networks
global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"


*------------------------------ clean facebook SCI

*could (But do not for model reasons) exclude own county ties and create measure excluding own state
insheet using "$friends/data/facebook/county_county_data.tsv",clear
tostring user_county fr_county,replace 
gen user_st=substr(user_county,1,2) if length(user_county)==5
replace user_st=substr(user_county,1,1) if length(user_county)==4
gen fr_st=substr(fr_county,1,2) if length(fr_county)==5
replace fr_st=substr(fr_county,1,1) if length(fr_county)==4
destring user_st fr_st user_county fr_county,replace

gen samestate=0
replace samestate=1 if user_st==fr_st
//gen scaled_sci_otherst=scaled_sci if samestate!=1

bysort user_county: egen totSCI_all=sum(scaled_sci)
gen normSCI_all=scaled_sci/totSCI_all
//bysort user_county: egen totSCI_otherst=sum(scaled_sci_otherst)
//gen normSCI_otherst=scaled_sci_otherst/totSCI_otherst

*remove friendship ties in the same county
gen scaled_sci_loo=scaled_sci
replace scaled_sci_loo=. if user_county==fr_county

*create new normalized
bysort user_county: egen totSCI_loo=sum(scaled_sci_loo)
gen normSCI_loo=scaled_sci_loo/totSCI_loo
gen normSCInost_loo=normSCI_loo if samestate==0

keep user_county fr_county normSCI_all normSCI_loo scaled_sci_loo normSCInost_loo
save "$friends/data/facebook/county_county_data.dta",replace


*example summary stats: https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013697
sum scaled_sci if user_county==04013 & fr_county==53033 // maricopa county TO king county (tacoma/seattle WA)
sum scaled_sci if user_county==06075 & fr_county==53033 // san francisco TO king county (tacoma/seattle WA)

*-----------------------------county-to-counTRY

*country iso code: https://www.nationsonline.org/oneworld/country_code_list.htm
***international: county to country
insheet using "$friends/data/facebook/County_Country.csv",clear
ren own_county county
keep county friend_country sci_cntry rel_prob_friend_cntry
save "$friends/data/facebook/County_Country.dta",replace

use "$friends/data/facebook/County_Country.dta",clear
gen sci_italy=sci_cntry if friend_country=="IT"
gen sci_southkorea=sci_cntry if friend_country=="KR"
gen sci_japan=sci_cntry if friend_country=="JP"
gen sci_singapore=sci_cntry if friend_country=="SG"
gen sci_spain=sci_cntry if friend_country=="ES"
gen sci_france=sci_cntry if friend_country=="FR"
collapse (mean) sci_italy-sci_france,by(county)
xtile sciITAgrp=sci_italy,nq(10)
xtile sciSKgrp=sci_southkorea,nq(10)
xtile sciJAPgrp=sci_japan,nq(10)
xtile sciSINGAgrp=sci_singapore,nq(10)
xtile sciSPAgrp=sci_spain,nq(10)
xtile sciFRAgrp=sci_france,nq(10)
saveold "$friends/data/facebook/country_SCI_selected.dta",replace version(13)


*example summary stats: https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013697
use "$friends/data/facebook/country_SCI_selected.dta",clear
sum sci_italy sci_southkorea sci_france sci_spain if county==04013 // maricopa county
sum sci_italy sci_southkorea sci_france sci_spain if county==06075 // san francisco
*/


*----------------------------Covid case/death data for county and for countries 

*https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
** first run the python script python/covid_reshape.py to reshape the raw data 

***using the JHU tracker
use "$friends/data/other/covid_counties_jhu.dta",clear
gen length=length(date)
gen month=substr(date,1,1) if substr(date,2,1)=="/"
replace month=substr(date,1,2) if substr(date,3,1)=="/"
gen day=""
replace day=substr(date,-4,1) if substr(date,-5,1)=="/" & substr(date,-3,1)=="/"
replace day=substr(date,-5,2) if substr(date,-6,1)=="/" & substr(date,-3,1)=="/"
gen year=substr(date,-2,2)
replace year="2020" if year=="20"
replace year="2021" if year=="21"
replace year="2022" if year=="22"
replace year="2023" if year=="23"
destring year month day,replace
ren FIPS county
drop UID date_id Population date
merge m:1 county using "$friends/data/social_explorer/acs2014_2018.dta"
keep if _merge==3
drop _merge
gen casespc=cases/totpop
gen deathspc=deaths/totpop
drop hhincome-poverty_65pl
egen tid=group(year month day)
tsset county tid
gen lag7_cases=L7.cases
gen lag14_cases=L14.cases
gen lag7_deaths=L7.deaths
gen lag14_deaths=L14.deaths
drop tid
saveold "$friends/data/other/covid_jhu.dta",replace version(13)

*save monthly
use "$friends/data/other/covid_jhu.dta",clear
gen date = mdy(month, day, year)
format date %d
bysort county year month (date): gen last_day = _N == _n
keep if last_day == 1
drop day date
save "$friends/data/other/covid_jhu_monthly.dta",replace


*get US Time series: https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
import excel using "$friends/data/other/covid_world.xlsx",clear firstrow sheet("cases_data")
gen month=month(date)
gen day=day(date)
saveold "$friends/data/other/covid_world_cases.dta",replace version(13)

import excel using "$friends/data/other/covid_world.xlsx",clear firstrow sheet("deaths_data")
gen month=month(date)
gen day=day(date)
saveold "$friends/data/other/covid_world_deaths.dta",replace version(13)



*-------------------------------------- create SCI measures for cases and deaths 
**************************************************************

use "$friends/data/other/covid_jhu", clear 
gen date = mdy(month, day, year)
format date %d
levelsof date, local(ts)

*for each county, keep a particular tid and merge in SCI data 
quietly foreach t of local ts{
	use "$friends/data/other/covid_jhu.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	keep if date==`t'
	ren county fr_county
	merge 1:m fr_county using "$friends/data/facebook/county_county_data.dta"
	keep if _merge==3
	drop _merge
	gen casesSCI_loo=cases*scaled_sci_loo/100
	gen deathsSCI_loo=deaths*scaled_sci_loo/100
	gen casesnormSCI_all=cases*normSCI_all
	gen deathsnormSCI_all=deaths*normSCI_all
	gen casesnormSCI_loo=cases*normSCI_loo
	gen deathsnormSCI_loo=deaths*normSCI_loo
	gen casesnormSCInost_loo=cases*normSCInost_loo
	gen deathsnormSCInost_loo=deaths*normSCInost_loo
	collapse (mean) casesSCI_loo deathsSCI_loo (sum) casesnormSCI_all-deathsnormSCInost_loo,by(user_county day month year)
	cd "$friends/data/facebook"
	save tempfile`t'.dta,replace
}

cd "$friends/data/facebook"

use tempfile21936.dta,replace

quietly foreach t in  `ts'{
	if `t'!=21936{
		append using tempfile`t'.dta
		erase tempfile`t'.dta
	}
}
erase tempfile21936.dta
saveold "$friends/data/facebook/covid_counties_SCI.dta",replace version(13)

*----- create the same data but monthly
 
quietly forval t=1/39{
	use "$friends/data/other/covid_jhu.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	bysort county year month (date): gen last_day = _N == _n
	keep if last_day == 1
	egen tid=group(year month day)
	keep if tid==`t'
	ren county fr_county
	merge 1:m fr_county using "$friends/data/facebook/county_county_data.dta"
	keep if _merge==3
	drop _merge
	gen casesSCI_loo=cases*scaled_sci_loo/100
	gen deathsSCI_loo=deaths*scaled_sci_loo/100
	gen casesnormSCI_all=cases*normSCI_all
	gen deathsnormSCI_all=deaths*normSCI_all
	gen casesnormSCI_loo=cases*normSCI_loo
	gen deathsnormSCI_loo=deaths*normSCI_loo
	gen casesnormSCInost_loo=cases*normSCInost_loo
	gen deathsnormSCInost_loo=deaths*normSCInost_loo
	collapse (mean) casesSCI_loo deathsSCI_loo (sum) casesnormSCI_all-deathsnormSCInost_loo,by(user_county year month)
	cd "$friends/data/facebook"
	save tempfile`t'.dta,replace
}

cd "$friends/data/facebook"
use tempfile1.dta,replace
quietly forval t=2/39{
	append using tempfile`t'.dta
	erase tempfile`t'.dta
}
erase tempfile1.dta
saveold "$friends/data/facebook/covid_counties_SCI_monthly.dta",replace version(13)

*-------------------------------------- create SCI cases and deaths measures for only counties 500 +miles away 

*exclude nearby (within 500 miles) counties: https://www.nber.org/research/data/county-distance-database
insheet using "$friends/data/sf12010countydistance500miles.csv",clear
renvars county1 county2 \ user_county fr_county
drop mi
merge 1:m user_county fr_county using "$friends\data\facebook\county_county_data.dta"
keep if _merge==2
drop _merge
save "$friends/data/facebook/county_county_data_far.dta",replace

** daily 

use "$friends/data/other/covid_jhu", clear 
gen date = mdy(month, day, year)
format date %d
levelsof date, local(ts)

*for each county, keep a particular tid and merge in SCI data 
quietly foreach t of local ts{
	use "$friends/data/other/covid_jhu.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	keep if date==`t'
	ren county fr_county
	merge 1:m fr_county using "$friends/data/facebook/county_county_data_far.dta"
	keep if _merge==3
	drop _merge
	gen casesSCI_loo_far=cases*scaled_sci_loo/100
	gen deathsSCI_loo_far=deaths*scaled_sci_loo/100
	gen casesnormSCI_all_far=cases*normSCI_all
	gen deathsnormSCI_all_far=deaths*normSCI_all
	gen casesnormSCI_loo_far=cases*normSCI_loo
	gen deathsnormSCI_loo_far=deaths*normSCI_loo
	gen casesnormSCInost_loo_far=cases*normSCInost_loo
	gen deathsnormSCInost_loo_far=deaths*normSCInost_loo
	collapse (mean) casesSCI_loo_far deathsSCI_loo_far (sum) casesnormSCI_all_far-deathsnormSCInost_loo_far,by(user_county day month year)
	cd "$friends/data/facebook"
	save tempfile`t'.dta,replace
}

cd "$friends/data/facebook"

use tempfile21936.dta,replace

quietly foreach t in  `ts'{
	if `t'!=21936{
		append using tempfile`t'.dta
		erase tempfile`t'.dta
	}
}
erase tempfile21936.dta
saveold "$friends/data/facebook/covid_counties_SCI_far.dta",replace version(13)

*-------------------------------clean physical distance measures and create PCI weighted cases/deaths 

*https://data.nber.org/data/county-distance-database.html

use "$friends/data/physical/sf12010countydistancemiles.dta",clear
destring county1 county2,replace
ren mi_to_county distance

bysort county1: egen totPCI_all=sum(distance)
gen normPCI_all=distance/totPCI_all
*create new normalized
gen distance_loo=distance
replace distance_loo=. if county1==county2
bysort county1: egen totPCI_loo=sum(distance_loo)
gen normPCI_loo=distance/totPCI_loo
keep county1 county2 normPCI_all normPCI_loo
save "$friends/data/physical/sf12010countydistancemiles_clean.dta",replace

*----- first montly 

*for each county, keep a particular tid and merge in SCI data
quietly forval t=1/39{
	use "$friends/data/other/covid_jhu.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	bysort county year month (date): gen last_day = _N == _n
	keep if last_day == 1
	egen tid=group(year month)
	keep if tid==`t'
	ren county county2
	merge 1:m county2 using "$friends/data/physical/sf12010countydistancemiles_clean.dta"
	keep if _merge==3
	drop _merge
	gen casesnormPCI_loo=cases*normPCI_loo
	gen deathsnormPCI_loo=deaths*normPCI_loo
	collapse (sum) casesnormPCI_loo deathsnormPCI_loo,by(county1 month year)
	cd "$friends/data/physical"
	save tempfile`t'.dta,replace
}

cd "$friends/data/physical"
use tempfile1.dta,replace
quietly forval t=2/39{
	append using tempfile`t'.dta
	erase tempfile`t'.dta
}
*erase tempfile1.dta
ren county1 county
keep county year month casesnormPCI_loo deathsnormPCI_loo
saveold "$friends/data/physical/covid_counties_PCI_monthly.dta",replace version(13)

*----- also daily measures for only 2020 

use "$friends/data/other/covid_jhu", clear 
gen date = mdy(month, day, year)
keep if year==2020 & month<=6
format date %d
levelsof date, local(ts)

*for each county, keep a particular tid and merge in SCI data 
quietly foreach t of local ts{
use "$friends/data/other/covid_jhu.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	keep if date==`t'
	ren county county2
	merge 1:m county2 using "$friends/data/physical/sf12010countydistancemiles_clean.dta"
	keep if _merge==3
	drop _merge
	gen casesnormPCI_loo=cases*normPCI_loo
	gen deathsnormPCI_loo=deaths*normPCI_loo
	collapse (sum) casesnormPCI_loo deathsnormPCI_loo,by(county1 month year)
	cd "$friends/data/physical"
	save tempfile`t'.dta,replace
}

cd "$friends/data/physical"
use tempfile21936.dta,replace

quietly foreach t in  `ts'{
	if `t'!=21936{
		append using tempfile`t'.dta
		erase tempfile`t'.dta
	}
}
erase tempfile21936.dta
ren county1 county
keep county year month day casesnormPCI_loo deathsnormPCI_loo
saveold "$friends/data/physical/covid_counties_PCI.dta",replace version(13)


*----------------------------------------------- clean stay at home orders

import excel using "$friends/data/other/state_saho.xlsx",clear firstrow sheet("Sheet1")
ren fips st
drop name state
quietly destring,replace
local torep "cc_closed state_emer pschl_closure stay_home noness_bus_closure"
quietly foreach var in `torep'{
	replace `var'=0 if `var'==.
}
saveold "$friends/data/other/state_saho.dta",replace version(13)


*------------------------------ clean social explorer

*https://www.socialexplorer.com/tables/ACS2018_5yr/R12528551
quietly infile using "$friends/data/social_explorer/acs2014_2018dic.dct", using("$friends/data/social_explorer/acs2014_2018data.txt") clear
ren FIPS county
destring county,replace
ren A00001_001 totpop
gen popdens=totpop/A00003_001
gen male=A02001_002/A02001_001
gen age_under18=(A01001_002+A01001_003+A01001_004+A01001_005)/A01001_001
gen age_18_24=A01001_006/A01001_001
gen age_25_34=A01001_007/A01001_001
gen age_35_64=(A01001_008+A01001_009+A01001_010)/A01001_001
gen age_65pl=(A01001_011+A01001_012+A01001_013)/A01001_001
gen race_white=A03001_002/A03001_001
gen race_black=A03001_003/A03001_001
gen married=A11001_003/A11001_001
gen educ_lesshs=A12001_002/A12001_001
gen educ_hs=A12001_003/A12001_001
gen educ_somecoll=A12001_004/A12001_001
gen educ_coll=A12001_005/A12001_001
gen educ_collpl=(A12001_006+A12001_007+A12001_008)/A12001_001
gen poverty_under18=A13003A_002/A13003A_001
gen poverty_18_64=A13003B_002/A13003B_001
gen poverty_65pl=A13003C_002/A13003C_001
ren A14006_001 hhincome
ren A14024_001 pcincome
ren A14028_001 gini
keep county totpop popdens male age* race* married educ* poverty* hhincome pcincome gini
saveold "$friends/data/social_explorer/acs2014_2018.dta",replace version(13)

***create binary indicators for high/low heterogeneity analysis
use "$friends/data/social_explorer/acs2014_2018.dta",clear
quietly sum hhincome,d
gen highmedinc=cond(hhincome>`r(p50)',1,0)
quietly sum pcincome,d
gen highpcinc=cond(pcincome>`r(p50)',1,0)
la var highmedinc "High Median HH Income"
la var highpcinc "High Per Capita Income"
gen age_under35=age_under18+age_18_24+age_25_34
quietly sum age_under35,d
gen highage_under35=cond(age_under35>`r(p50)',1,0)
quietly sum age_65pl,d
gen highage_over65=cond(age_65pl>`r(p50)',1,0)
la var highage_over65 "High Share Above Age 65"
la var highage_under35 "High Share Below Age 35"
quietly sum totpop,d
gen highpop=cond(totpop>`r(p50)',1,0)
la var highpop "High Population"
merge 1:1 county using "$friends/data/other/ipums_census_ITshare.dta"
keep if _merge==3 | _merge==1
drop _merge
keep county high*
saveold "$friends/data/social_explorer/county_heterog_indicators.dta",replace version(13)


*-------------------- laus data for county unemployment rate stats

*2020 LAUS: https://www.socialexplorer.com/tables/US_unemployment_2020/R12654293
insheet using "$friends/data/social_explorer/laus2020data.txt",clear
ren geo_fips county
ren org_us_unemployment_018_20jul_ra urate7
ren org_us_unemployment_017_20jun_ra urate6
ren org_us_unemployment_016_20may_ra urate5
ren org_us_unemployment_015_20apr_ra urate4
ren org_us_unemployment_003_20mar_ra urate3
ren org_us_unemployment_002_20feb_ra urate2
ren org_us_unemployment_001_20jan_ra urate1
keep county urate*
reshape long urate,i(county) j(month)
saveold "$friends/data/social_explorer/laus2020.dta",replace version(13)


*--------------------------create mobility data 

import delimited "$friends/data/other/Google Mobility - County - Daily.csv",clear
gen monthly_date = mdy(month,day,year)
format monthly_date %td
gen county=countyfips
drop countyfips
save "$friends/data/other/mobility_county_D.dta", replace


*------------------------------ Create idiosyncratic and orthogonalized covid 

use "$friends/data/other/covid_jhu.dta",clear
gen tid = mdy(month, day, year)
gen lcases=asinh(cases)
gen ldeaths = asinh(deaths)

tsset county tid

** idio shocks to cases levels

capture drop FE*
reghdfe lcases,a(FEtid=tid) resid 
predict lcases_shock,resid
label var lcases_shock "idiosyncratic shocks to log cases"
sum FEtid,d

** idio shocks to case growth  
gen dl1cases=lcases-L.lcases
*generate terms for model
capture drop FE*

reghdfe dl1cases,a(FEtid=tid) resid
predict dl1cases_shock,resid
label var dl1cases_shock "idiosyncratic shocks to log change in cases"
sum FEtid,d

** ido shocks to deaths levels

capture drop FE*
reghdfe ldeaths,a(FEtid=tid) resid
predict ldeaths_shock,resid
label var ldeaths_shock "idiosyncratic shocks to log deaths"
sum FEtid,d


** ido shocks to deaths growth
gen dl1deaths=ldeaths-L.ldeaths
capture drop FE*
reghdfe dl1deaths,a(FEtid=tid) resid
predict dl1deaths_shock,resid
label var dl1deaths_shock "idiosyncratic shocks to log change in deaths"
sum FEtid,d

summarize lcases_shock dl1cases_shock ldeaths_shock dl1deaths_shock

keep county month day year lcases_shock dl1cases_shock ldeaths_shock dl1deaths_shock
saveold "$friends/data/other/covid_jhu_shocks.dta",replace version(13)

** create SCI measures for shocks 

use "$friends/data/other/covid_jhu_shocks", clear 
gen date = mdy(month, day, year)
format date %d
levelsof date, local(ts)

*for each county, keep a particular tid and merge in SCI data 
quietly foreach t of local ts{
	use "$friends/data/other/covid_jhu_shocks.dta",clear
	gen date = mdy(month, day, year)
	format date %d
	keep if date==`t'
	ren county fr_county
	merge 1:m fr_county using "$friends/data/facebook/county_county_data.dta"
	keep if _merge==3
	drop _merge
	* level shocks 
	gen lcasesshock_SCI_loo=lcases_shock*scaled_sci_loo/100
	gen ldeathsshock_SCI_loo=ldeaths_shock*scaled_sci_loo/100
	
	gen lcasesshock_normSCI_all=lcases_shock*normSCI_all
	gen ldeathsshock_normSCI_all=ldeaths_shock*normSCI_all
	
	gen lcasesshock_normSCI_loo=lcases_shock*normSCI_loo
	gen ldeathsshock_normSCI_loo=ldeaths_shock*normSCI_loo
	
	gen lcasesshock_normSCInost_loo=lcases_shock*normSCInost_loo
	gen ldeathsshock_normSCInost_loo=ldeaths_shock*normSCInost_loo
	
	* growth shocks
	gen dl1casesshock_SCI_loo=dl1cases_shock*scaled_sci_loo/100
	gen dl1deathsshock_SCI_loo=dl1deaths_shock*scaled_sci_loo/100
	
	gen dl1casesshock_normSCI_all=dl1cases_shock*normSCI_all
	gen dl1deathsshock_normSCI_all=dl1deaths_shock*normSCI_all
	
	gen dl1casesshock_normSCI_loo=dl1cases_shock*normSCI_loo
	gen dl1deathsshock_normSCI_loo=dl1deaths_shock*normSCI_loo
	
	gen dl1casesshock_normSCInost_loo=dl1cases_shock*normSCInost_loo
	gen dl1deathsshock_normSCInost_loo=dl1deaths_shock*normSCInost_loo
	
	
	collapse (mean) lcasesshock_SCI_loo ldeathsshock_SCI_loo (sum) lcasesshock_normSCI_all-ldeathsshock_normSCInost_loo ///
	 (mean) dl1casesshock_SCI_loo dl1deathsshock_SCI_loo (sum) dl1casesshock_normSCI_all-dl1deathsshock_normSCInost_loo, by(user_county day month year)
	cd "$friends/data/facebook"
	save tempfile`t'.dta,replace
}

use "$friends/data/other/covid_jhu_shocks", clear 
gen date = mdy(month, day, year)
format date %d
levelsof date, local(ts)
display "`ts'"

cd "$friends/data/facebook"


use tempfile21936.dta,replace
quietly foreach t in  `ts'{
	if `t'!=21936{
		append using tempfile`t'.dta
		erase tempfile`t'.dta
	}
}
erase tempfile21936.dta
saveold "$friends/data/facebook/covid_shocks_counties_SCI.dta",replace version(13)


*------------------------------ Create idiosyncratic and orthogonalized consumption shocks  
 
use "$friends/data/spending/spend2_bycounty_D_long.dta",clear

gen tid = mdy(month, day, year)
format tid %td 
rename countyfips county 

rename spend_all ltotal_spend2_chg
tsset county tid

** idio shocks to consumption 

capture drop FE*
reghdfe ltotal_spend2_chg,a(FEtid=tid) resid 
predict ltotal_spend2_shk,resid
label var ltotal_spend2_shk "idiosyncratic shocks to consumption growth"
sum FEtid,d

summarize ltotal_spend2_shk

keep county month day year ltotal_spend2_shk
saveold "$friends/data/other/spend2_bycounty_D_shocks.dta",replace version(13)


** create SCI measures for consumption shocks 
**************************************************************

use "$friends/data/other/spend2_bycounty_D_shocks", clear 
gen date = mdy(month, day, year)
format date %td
levelsof date, local(ts)

*for each county, keep a particular tid and merge in SCI data 
quietly foreach t of local ts{
	use "$friends/data/other/spend2_bycounty_D_shocks.dta",clear
	gen date = mdy(month, day, year)
	format date %td
	keep if date==`t'
	ren county fr_county
	merge 1:m fr_county using "$friends/data/facebook/county_county_data.dta"
	keep if _merge==3
	drop _merge
	* level shocks 
	gen spendshock_SCI_loo=ltotal_spend2_shk*scaled_sci_loo/100
	
	gen spendshock_normSCI_all=ltotal_spend2_shk*normSCI_all
	
	gen spendshock_normSCI_loo=ltotal_spend2_shk*normSCI_loo
	
	gen spendshock_normSCInost_loo=ltotal_spend2_shk*normSCInost_loo
	
	
	collapse (mean) spendshock_SCI_loo (sum) spendshock_normSCI_all-spendshock_normSCInost_loo ///
	, by(user_county day month year)
	cd "$friends/data/facebook"
	save tempfile`t'.dta,replace
}


use "$friends/data/other/spend2_bycounty_D_shocks", clear 
gen date = mdy(month, day, year)
format date %td
levelsof date, local(ts)
display "`ts'"

cd "$friends/data/facebook"


use tempfile21936.dta,replace

quietly foreach t in  `ts'{
	if `t'!=21936{
		append using tempfile`t'.dta
		erase tempfile`t'.dta
	}
}
erase tempfile21936.dta
saveold "$friends/data/facebook/spend_shocks_counties_SCI.dta",replace version(13)
*/




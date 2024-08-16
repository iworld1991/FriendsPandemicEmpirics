*------------------------------ Prepare data and processing it 

/*************

- covid daily and monthly case/death data from JHU 
- acs data for county heterogeneity variables 
  - ipums census data for the share of IT 
- laus county data 
****************/

*global friends C:\Users\chris\Dropbox\1Publication and Research\2020 - Consumption and social networks
global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"


*----------------------------Covid case/death data 

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
merge m:1 county using "$friends/data/social explorer/acs2014_2018.dta"
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


*------------------------------ clean social explorer

*https://www.socialexplorer.com/tables/ACS2018_5yr/R12528551
quietly infile using "$friends/data/social explorer/acs2014_2018dic.dct", using("$friends/data/social explorer/acs2014_2018data.txt") clear
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
saveold "$friends/data/social explorer/acs2014_2018.dta",replace version(13)

***create binary indicators for high/low heterogeneity analysis
use "$friends/data/social explorer/acs2014_2018.dta",clear
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
saveold "$friends/data/social explorer/county_heterog_indicators.dta",replace version(13)


*-------------------- laus data for county unemployment rate stats

*2020 LAUS: https://www.socialexplorer.com/tables/US_unemployment_2020/R12654293
insheet using "$friends/data/social explorer/laus2020data.txt",clear
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
saveold "$friends/data/social explorer/laus2020.dta",replace version(13)




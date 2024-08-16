*------------------------------ Prepare data and processing it 

/*************

- acs data for county heterogeneity variables 

****************/

*global friends C:\Users\chris\Dropbox\1Publication and Research\2020 - Consumption and social networks
global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"


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



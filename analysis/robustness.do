*------------------------------ Robustness results

/*************
- Figure A.5 France and Italy's covid cases 
- Figure A.6 comparison of the PCI and SCI
****************/

*global friends C:\Users\chris\Dropbox\1Publication and Research\2020 - Consumption and social networks
global friends "/Users/tao/Dropbox/FriendsPandemicEmpirics/"

set scheme s1color


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


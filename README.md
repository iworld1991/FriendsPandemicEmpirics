# Replication Repo of _Learning from Friends in a Pandemic, Social Networks and the Macroeconomic Responses of Consumption_
- This is a replication repo of the published paper in _European Economic Review_
- Authors: [Tao Wang](taowangeconomics@gmail.com),  [Christos Makridis](christos.a.makridis@gmail.com)

## Raw Data Sources

- Data Name. Sample Period. Link. Location
- Covid cases/deaths by county by day, and by countries by day, 2020-2023,[JHU](https://github.com/CSSEGISandData/COVID-19), [./data/other/](./data/other/)
- Debit Card Transaction Data, 2020, Facteus through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing initiative during the Covid pandemic, [./data/spending/spend2bycountyD.dta](./data/spending/spend2bycountyD.dta): 
- Debit+ Credit Card Transaction Data, 2020-2023, Affinity Solution, through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing initiative during the Covid and also in the Realtime EconomicTracker by [Opportunity Insights](https://opportunityinsights.org), [./data/spending/spend2bycountyD.dta](./data/spending/spend2bycountyD.dta): 
- American Community Survey (ACS) 2014-2018, [./data/social_explorer/acs2014_2018.dta](./data/social_explorer/acs2014_2018.dta): 
- County heterogeneity indicators (created from ACS), 2020, [./data/social_explorer/county_heterog_indicators.dta](./data/social_explorer/county_heterog_indicators.dta) 
- County unemployment rate, 2020, [./data/social%20explorer/laus2020.dta](./data/social%20explorer/laus2020.dta): 
- State Covid Policies, 2020,[./data/other/state_policies.dta](./data/other/state_policies.dta)
- State Stay-at-home-order Policies, 2020, [./data/other/state_policies.dta](./data/other/state_policies.dta)
- IPUMS county information 2020, [./data/other/ipums_census_ITshare.dta](./data/other/ipums_census_ITshare.dta) 
- Facebook SCI between each U.S. county to foreign countries, 2019, [./data/facebook/County_Country.csv](./data/facebook/County_Country.csv) 

### large size (>50mb). This data is not on GitHub, but in the EER's replication archive.
- County pairs 500+miles, 2020, [./data/physical/sf12010countydistancemiles.dta](./data/physical/sf12010countydistancemiles.dta): 
- Facebook SCI, 2019, [./data/facebook/county_county_data.tsv](./data/facebook/county_county_data.tsv): 
- Google Mobility, 2020, Real-time EconomicTracker, [./data/other/](./data/other/): Google Mobility - County - Daily.csv
- Affinity Solution Daily Spending data, 2020-2023, [./data/spending/spend2_bycounty_D_long.dta](./data/spending/spend2_bycounty_D_long.dta): 
 
## Code Structure 
### Python
- [Reshaping raw microdata of Covid series](./analysis/python/covid_reshape.py)
- [Validating consumption measures](./analysis/python/Compare.ipynb)
### Stata
- [Step1.preparing data](./analysis/preparedata.do)
- [Step2.main results](./analysis/main.do)
- [Step3.additional robustness results](./analysis/robustness.do)

## Replication of Tables and Figures in the Publication

### Main texts
- [Figure 1, Table 1-6](./analysis/main.do)
### Online Appendix 
- [Table A.1-A.2, A.4-A.7, A.9, Figure A.1,A.5,A.6](./analysis/robustness.do)
- [Table A.3, A.4](./analysis/main.do)
- [Table A.2](./analysis/python/Compare.ipynb)

### Special note
-  Figure 1 is based on a large-sized proprietary micro dataset we obtained from Facteus. It is not included in this replication package. 


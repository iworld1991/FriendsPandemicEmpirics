# Replication Repo of _Learning from Friends in a Pandemic, Social Networks and the Macroeconomic Responses of Consumption_
- This is a replication repo of the published paper in _European Economic Review_
- Authors: [Tao Wang](taowangeconomics@gmail.com),  [Christos Makridis](christos.a.makridis@gmail.com)

## Raw Data Sources

- Data Name. Sample Period. Source, Location
- Covid cases/deaths by county by day, and by countries by day, 2020-2023, provided by [JHU Center for Systems Science and Engineering](https://github.com/CSSEGISandData/COVID-19), [/data/other/](/data/other/)
- Debit Card Transaction Data, 2020, Facteus through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing initiative during the Covid pandemic, [/data/spending/spend2bycountyD.dta](/data/spending/spend2bycountyD.dta)
- Debit+ Credit Card Transaction Data, 2020-2023, Affinity Solution, through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing initiative during the Covid and also in the Realtime EconomicTracker by [Opportunity Insights](https://opportunityinsights.org), [./data/spending/spend2bycountyD.dta](data/spending/spend2bycountyD.dta) for 2020 only, and [/data/spending/spend2_bycounty_D_long.dta](/data/spending/spend2_bycounty_D_long.dta) for 2020-2023.
- American Community Survey (ACS) 2014-2018, [/data/social_explorer/acs2014_2018.dta](/data/social_explorer/acs2014_2018.dta)
- County heterogeneity indicators (created from ACS), 2020, [/data/social_explorer/county_heterog_indicators.dta](/data/social_explorer/county_heterog_indicators.dta) 
- County unemployment rate, 2020, [/data/social%20explorer/laus2020.dta](/data/social%20explorer/laus2020.dta) 
- State Covid Policies, 2020,[/data/other/state_policies.dta](/data/other/state_policies.dta)
- State Stay-at-home-order Policies, 2020, [/data/other/state_policies.dta](/data/other/state_policies.dta)
- IPUMS county information 2020, [/data/other/ipums_census_ITshare.dta](/data/other/ipums_census_ITshare.dta) 
- Facebook SCI between each U.S. county to foreign countries, 2019, [/data/facebook/County_Country.csv](/data/facebook/County_Country.csv) 

### large size (>50mb).

    This data is not on GitHub, but in the EER's replication archive. Alternatively, you can download them using the provided link below and put it in the indicated location.

- Facebook SCI, 2019, [Location](./data/facebook/), [county_county_data.tsv](https://www.dropbox.com/scl/fi/hfcoal547ic2mptmay94j/county_county_data.tsv?rlkey=ew29d9oqb1xwqz4h37gra1m81&dl=0)
- County-to-county distance, 2020, [Location](./data/physical/), [sf12010countydistancemiles.dta](https://www.dropbox.com/scl/fi/dae2cqs09ha4ywhn9q9dc/sf12010countydistancemiles.dta?rlkey=akg27mz2vv2dx77hv2k4d703p&dl=0), [sf12010countydistance500miles.csv](https://www.dropbox.com/scl/fi/4jaz2awco10vg1cfpjrrq/sf12010countydistance500miles.csv?rlkey=5nis15kn252o0dmcbku8b62n1&dl=0)
- Google Mobility, 2020, Real-time EconomicTracker, [Location](./data/other/), [Google Mobility - County - Daily.csv](https://www.dropbox.com/scl/fi/rddl87guqsup4et4ty03d/Google-Mobility-County-Daily.csv?rlkey=3s1fw134tehuyznxyr4qlmq87&dl=0)
 
## Code Structure 
### Python
- [Reshaping raw microdata of Covid series](./analysis/python/covid_reshape.py)
- [Validating consumption measures](./analysis/python/Compare.ipynb)
### Stata
- [Step1.preparing data](./analysis/preparedata.do)
- [Step2.main results](./analysis/main.do)
- [Step3.additional robustness results](./analysis/robustness.do)

## Replication of Tables and Figures in the Publication

### Main results
- [Figure 1, Table 1-6](./analysis/main.do)
### Online Appendix 
- [Table A.1-A.2, A.4-A.7, A.9, Figure A.1,A.5,A.6](./analysis/robustness.do)
- [Table A.3, A.4](./analysis/main.do)
- [Table A.2](./analysis/python/Compare.ipynb)

### Special note
-  The package contains all raw data and code that replicates all tables and figures in the publication, except for the microdata used to produce Figure 1. Being a large proprietary dataset containing daily MCC-code transactions by zip code we obtained from SafeGraph, it is not included in this repo due to our data-sharing agreement with the provider.

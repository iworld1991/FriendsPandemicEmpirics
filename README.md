# Replication Repo of _Learning from Friends in a Pandemic, Social Networks and the Macroeconomic Responses of Consumption_
- This is a replication repo of the published paper in _European Economic Review_
- Authors: [Tao Wang](taowangeconomics@gmail.com),  [Christos Makridis](christos.a.makridis@gmail.com)

## Raw Data Sources

- Data Name. Sample Period. Link. Location
- Social Connectedness Index, 2016 and 2019, [Location](./data/facebook/)
- Debit Card Transaction Data, 2020, Facteus through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing initiative during the Covid pandemic, [Location](./data/spending/)
- Debit+ Credit Card Transaction Data, 2020-2023, Affinity Solution, through [Safegraph](https://www.safegraph.com/blog/safegraph-partners-with-dewey)'s data-sharing inititive during the Covid and also in the Realtime EconomicTracker by [Opportunity Insights](https://opportunityinsights.org), [Location](./data/spending/)
- Google mobility, 2020, Real-time EconomieicTracker as above, [Location](./data/other/)
- American Community Survey (ACS) [Location](./data/other/)

### large size (>50mb). This data is not on GitHub, but in the EER's replication archive.
- [County pairs 500+miles](./data/physical/):sf12010countydistancemiles.dta
- [Facebook SCI](./data/physical/): county_county_data.tsv
- [Google mobility](./data/other/): Google Mobility - County - Daily.csv
- [Affinity Solution Daily Spending data](./data/spending): spend2_bycounty_D_long.dta
 
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


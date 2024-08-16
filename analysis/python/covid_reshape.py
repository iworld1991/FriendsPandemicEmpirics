# ---
# jupyter:
#   jupytext:
#     cell_metadata_json: true
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.11.2
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

import pandas as pd
import numpy as np

dt = pd.read_csv("../../data/other/time_series_covid19_confirmed_US.csv")
dt2 = pd.read_csv("../../data/other/time_series_covid19_deaths_US.csv")

dt.tail()

# + {"code_folding": []}
dates = set(dt.columns) - set(['UID',
                               'iso2',
                               'iso3',
                               'code3',
                               'FIPS',
                               'Admin2',
                               'Province_State',
                               'Country_Region',
                               'Lat',
                               'Long_',
                               'Combined_Key'])
dates_list = list(dates)

for i,date in enumerate(dates):
    dt = dt.rename(columns = {date:'cases'+str(i)})
    dt2 = dt2.rename(columns = {date:'deaths'+str(i)})
# -

dates

dt = pd.wide_to_long(dt,stubnames='cases', i=['UID'], j="date_id")
dt2 = pd.wide_to_long(dt2,stubnames='deaths', i=['UID'], j="date_id")

dt.shape

dt['date_id'] = [idx[1] for idx in dt.index]
dt2['date_id'] = [idx[1] for idx in dt2.index]

dt['date'] = np.array([dates_list[dt['date_id'].iloc[i]] for i in range(len(dt))])
dt2['date'] = np.array([dates_list[dt2['date_id'].iloc[i]] for i in range(len(dt))])

# + {"code_folding": [0]}
drop_list = ['date_id',
             'Long_',
             'Province_State',
             'Combined_Key',
             'Admin2',
             'code3',
             'Lat',
             'iso3',
             'iso2',
             'Country_Region']
dt = dt.drop(columns= drop_list )
dt2 = dt2.drop(columns= drop_list)
dt2 = dt2.drop(columns= ['FIPS','date'])

# + {"code_folding": []}
dt = pd.merge(dt,
             dt2,
             left_index = True,
             right_index = True,
             how = 'outer')
# -

dt.tail()

dt = dt.dropna(subset=['FIPS'])

dt.to_stata("../../data/other/covid_counties_jhu.dta")



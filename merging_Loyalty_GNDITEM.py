#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 20 17:43:21 2017

@author: divya
"""

#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 20 17:36:14 2017

@author: divya
"""

#import dask, sys
from dask.diagnostics import ProgressBar
import dask.dataframe as dd
import pandas as pd, numpy as np
import dask
from pandas.tseries.tools import to_datetime

#Progress Bar
pbar = ProgressBar()
pbar.register()

#read GNDITEM file
df_gnditem = dd.read_csv('GNDITEM_utf_8.csv',encoding = 'utf-8')
print df_gnditem.head()
    
#Select only price > 0 and quantity = 1, and drop NA values
df2 = df_gnditem[df_gnditem.PRICE > 0.0 and df_gnditem.QUANTITY == 1.0]
df2 = df2.dropna()
print df2.head()
print dd.compute(df2.count())

#read Loyalty file
df_loyalty = pd.read_csv('loyalty_utf_8.csv', header = 0 ,encoding='utf-8')
        
len(df_loyalty)
#Drop NA values
df_loyalty = df_loyalty.dropna()
len(df_loyalty)

#convert to dask
df_loyalty = dd.from_pandas(df_loyalty, npartitions=3)

print df_loyalty.head()

#converting to same datatypes
df2['dlTableStoreNumber'] = df2['dlTableStoreNumber'].astype(int)
df2['CHECK'] = df2['CHECK'].astype(int)

df_loyalty['StoreNumber'] = df_loyalty['StoreNumber'].astype(int)
df_loyalty['ReceiptNumber'] = df_loyalty['ReceiptNumber'].astype(int)
df_loyalty['ReceiptDate'] = df_loyalty['ReceiptDate'].compute(get=dask.async.get_sync).to_datetime()


left_columns = [ "dlTableStoreNumber", 'CHECK']

right_columns = ["StoreNumber", "ReceiptNumber"]

#Merging both dataframes
df_merge = df2.merge(df_loyalty,how = 'inner', left_on=left_columns, right_on=right_columns)

print df_merge.head()
print dd.compute(df_merge.count())

#Working on date format, work in progress
df_loyalty['ReceiptDate'] = pd.to_datetime(df_loyalty['ReceiptDate'])

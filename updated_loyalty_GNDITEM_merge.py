
# coding: utf-8

# In[1]:

import dask
from dask import do
from dask import compute, delayed
import pandas as pd
import numpy as np
import dask.array as da
from dask.diagnostics import ProgressBar



import dask.dataframe as dd


#Read in the data
df = dd.read_csv('GNDITEM.csv')

df1 = pd.read_csv("Loyalty.csv")
#cat = dd.read_csv('CAT.csv')


#Convert loyalty data to dask dataframe
sd = dd.from_pandas(df1, npartitions=3)

# convert hours and minutes from float to integer to string
df.HOUR = df.HOUR.astype(int)
df.MINUTE = df.MINUTE.astype(int)

df.HOUR = df.HOUR.astype(str)
df.MINUTE = df.MINUTE.astype(str)
df.DOB = df.DOB.astype(str)

#combine DOB HOUR and MINUTE into one column
with ProgressBar():
    df['period'] = df.DOB+' '+df.HOUR+':'+df.MINUTE+':00'


#Convert period column into datetime64 format
with ProgressBar():
    meta = ('Date', pd.Timestamp)
    df.period = df.period.map_partitions(pd.to_datetime, format = '%Y-%m-%d %H:%M:%S', meta=meta).compute()

#Conver loyalty data columns into strings
df.dlTableStoreNumber = df.dlTableStoreNumber.astype(str)
sd.StoreNumber = sd.StoreNumber.astype(str)
sd.ReceiptNumber = sd.ReceiptNumber.astype(int)
sd.ReceiptNumber = sd.ReceiptNumber.astype(str)


right_columns = [ "dlTableStoreNumber", "CHECK", "period"]
left_columns = ["StoreNumber", "ReceiptNumber", "ReceiptDate"]

#Merge loyalty and GNDITEM based on store number, Receipt number, and date
r = sd.merge(df, left_on =left_columns, right_on = right_columns, how = 'inner' )


with ProgressBar():
    r.compute()


sd.head()






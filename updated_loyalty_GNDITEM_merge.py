
# coding: utf-8

# In[1]:

import dask
from dask import do
from dask import compute, delayed
import pandas as pd
import numpy as np
import dask.array as da
from dask.diagnostics import ProgressBar


# In[2]:

import dask.dataframe as dd


# In[3]:

df = dd.read_csv('GNDITEM.csv')

df1 = pd.read_csv("Loyalty.csv")
#cat = dd.read_csv('CAT.csv')


# In[4]:

sd = dd.from_pandas(df1, npartitions=3)


# In[19]:

df.HOUR = df.HOUR.astype(int)
df.MINUTE = df.MINUTE.astype(int)

df.HOUR = df.HOUR.astype(str)
df.MINUTE = df.MINUTE.astype(str)
df.DOB = df.DOB.astype(str)


# In[8]:

with ProgressBar():
    df['period'] = df.DOB+' '+df.HOUR+':'+df.MINUTE+':00'


# In[11]:

with ProgressBar():
    meta = ('Date', pd.Timestamp)
    df.period = df.period.map_partitions(pd.to_datetime, format = '%Y-%m-%d %H:%M:%S', meta=meta).compute()


# In[23]:

df.dlTableStoreNumber = df.dlTableStoreNumber.astype(str)
sd.StoreNumber = sd.StoreNumber.astype(str)
sd.ReceiptNumber = sd.ReceiptNumber.astype(int)
sd.ReceiptNumber = sd.ReceiptNumber.astype(str)


right_columns = [ "dlTableStoreNumber", "CHECK", "period"]
left_columns = ["StoreNumber", "ReceiptNumber", "ReceiptDate"]


# In[24]:

r = sd.merge(df, left_on =left_columns, right_on = right_columns, how = 'inner' )


# In[ ]:

with ProgressBar():
    r.compute()


# In[18]:

sd.head()


# In[22]:




# In[ ]:




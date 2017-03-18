
# coding: utf-8

# In[1]:

import dask
from dask import do
from dask import compute, delayed
import pandas as pd
import numpy as np


# In[2]:

import dask.dataframe as dd


# In[21]:

df = dd.read_csv('GNDITEM.csv')

df1 = pd.read_csv("Loyalty.csv")
#cat = dd.read_csv('CAT.csv')


# In[26]:

sd = dd.from_pandas(df1, npartitions=3)


# In[37]:

from pandas.tseries.tools import to_datetime

sd.ReceiptDate.astype('M8[us]')

meta = ('ReceiptDate', pd.Timestamp)
sd.ReceiptDate.map_partitions(pd.to_datetime, meta=meta)

df.head()


# In[38]:

columns = [ "dlTableStoreNumber", 'CHECK', "DOB"]

r_columns = ["StoreNumber", "ReceiptNumber", "ReceiptDate"]


# In[39]:

r = sd.merge(df, left_on =r_columns, right_on = columns, how = 'inner' )


# In[40]:

r.head()


# In[ ]:




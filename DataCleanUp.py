# -*- coding: utf-8 -*-
"""
Created on Mon Mar 13 19:17:07 2017

@author: Sriva
"""

import pandas as pd


#Summary Sales

####Survey Responses
summaryOverallSat = pd.read_csv('../../src/Summary Sales/Summary Overall Sat.csv')
print summaryOverallSat.isnull().sum()

####Summary Sales By Weekend
summarySales = pd.read_csv('../../src/Summary Sales/Summary Sales.csv')
summarySales["GuestCount"] = summarySales.groupby("SBRNumber").GuestCount.transform(lambda x: x.fillna(x.mean()))
summarySales["CateringReportingCurrency"] = summarySales.groupby("SBRNumber").CateringReportingCurrency.transform(lambda x: x.fillna(x.mean()))
summarySales["DiscountsReportingCurrency"] = summarySales.groupby("SBRNumber").DiscountsReportingCurrency.transform(lambda x: x.fillna(x.mean()))
summarySalesByStore = summarySales.groupby(by='SBRNumber')
summarySales.to_csv('../../src/Summary Sales/Summary Sales_cleaned.csv',index=False)


#TLD

#Item Category
category = pd.read_csv('../../src/TLD/CAT.csv')
print category.isnull().sum()

#Items
item = pd.read_csv('../../src/TLD/ITM.csv',dtype = {"dlTableStoreNumber":int,"ID":int,"SHORTNAME":str,"LONGNAME":str})
item.loc[item['SHORTNAME'].isnull(),'SHORTNAME'] = item['LONGNAME']
item.loc[item['LONGNAME'].isnull(),'LONGNAME']  = item['SHORTNAME']        
item.to_csv('../../src/TLD/ITM_cleaned.csv',index=False)


#Orders
order = pd.read_csv('../../src/TLD/ODR.csv')
print order.isnull().sum()

#Tenders
tdr = pd.read_csv('../../src/TLD/TDR.csv')
tdr = tdr.sort_values(['dlTableStoreNumber','ID'], ascending=[True,True])
tdr = tdr.drop_duplicates(subset = ['dlTableStoreNumber','NAME'])
tdr.to_csv('../../src/TLD/TDR_Cleaned.csv', index=False)

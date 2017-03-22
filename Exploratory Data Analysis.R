
## TLD Data files

  # The GNDITEM table holds line level check transactions
  lineTrans <- read.csv("Data/TLD/GNDITEM.csv", header = TRUE)
  format(object.size(lineTrans),units="Mb")
  head(lineTrans)
  summary(lineTrans)
  # Total no.of stores
  length(unique(lineTrans$dlTableStoreNumber))
  # No.of transactions made in each store
  table(lineTrans$dlTableStoreNumber)
  # All modes of transactions
  table(lineTrans$MODE)
  # Date of Business (No.of transactions made on each day)
  table(lineTrans$DOB)
  # Total no.of different items sold 
  length(unique(lineTrans$ITEM))
  # Total number of days (406)
  length(unique(lineTrans$DOB))
  # Table showing number of transactions made by each store on each day of business
  storeTransDOB <- table(lineTrans$DOB, lineTrans$dlTableStoreNumber, lineTrans$CHECK)
  write.csv(as.data.frame(storeTransDOB), file = "Data/TLD/Newly Created/storeTransDOB.csv")
  
  
  # The GNDTNDR table holds payments for Moe's stores in the last year
  payment <- read.csv("Data/TLD/GNDTNDR.csv", header = TRUE)
  format(object.size(payment),units="Mb")
  head(payment)
  summary(payment)
  # Total number of days (406)
  length(unique(payment$DATE))
  # Table showing number of transactions made by each store on each day of business
  storeTransGNDTNDR <- table(payment$StoreNumber, payment$DATE)
  write.csv(as.data.frame(storeTransGNDTNDR), file = "Data/TLD/Newly Created/storeTransGNDTNDR.csv")
  # All types of transactions 
  table(payment$TYPE)
  
  # The CAT table holds each store's item category information
  itemCategory <- read.csv("Data/TLD/CAT.csv", header = TRUE)
  format(object.size(itemCategory),units="Mb")
  head(itemCategory)
  summary(itemCategory)
  
  # The ITM holds each store's item setups
  items <- read.csv("Data/TLD/ITM.csv", header = TRUE)
  format(object.size(items),units="Mb")
  head(items)
  summary(items)
  
  # The ODR table holds each store's order mode setup
  orderMode <- read.csv("Data/TLD/ODR.csv", header = TRUE)
  format(object.size(orderMode),units="Kb")
  head(orderMode)
  summary(orderMode)
  
  # The TDR holds the tender type definitions for each store
  paymentMode <- read.csv("Data/TLD/TDR.csv", header = TRUE)
  format(object.size(paymentMode),units="Mb")
  head(paymentMode)
  summary(paymentMode)
  # Table of all payment modes
  table(paymentMode$ID)

## Summary Sales Data

  # Summary Weekly store sales
  summarySales <- read.csv("Data/Summary Sales/Summary Sales.csv", header = TRUE)
  head(summarySales)
  summary(summarySales)
  
  # Survey responses from customers regarding their overall experience
  summarySalesSat <- read.csv("Data/Summary Sales/Summary Overall Sat.csv", header = TRUE)
  head(summarySalesSat)
  summary(summarySalesSat)
  
  # List of Stores
  storeList <- read.csv("Data/Summary Sales/Store List.csv", header = TRUE)
  head(storeList)
  summary(storeList)

## Loyalty Rewards Data
  
  # All loyalty transactions that earned points for a customer, from our loyalty vendor Punchh  
  loyaltyRewards <- read.csv("Data/Loyalty/Loyalty Rewards.csv", header = TRUE)
  head(loyaltyRewards)
  summary(loyaltyRewards)

## Black Box Data files
  
  # Black Box Intelligence provides Focus Brands with industry performance averages. 
  # The data cannot be aggregated since they are reported averages and not store counts are provided 
  # to weight them properly.
    
  periodData <- read.csv("Data/Blackbox/PeriodData_2017W03.csv", header = TRUE)
  head(periodData)
  summary(periodData)
  
  weeklyData <- read.csv("Data/Blackbox/WeeklyData_2017W03.csv", header = TRUE)
  head(weeklyData)
  summary(weeklyData)
  
  yearData <- read.csv("Data/Blackbox/YearData_2017W03.csv", header = TRUE)
  head(yearData)
  summary(yearData)
  
  
  # Snippets of all tables
  head(lineTrans)
  head(payment)
  head(itemCategory)
  head(items)
  head(orderMode)
  head(paymentMode)
  head(summarySales)
  head(summarySalesSat)
  head(storeList)
  head(loyaltyRewards)
  head(periodData)
  head(weeklyData)
  head(yearData)
  
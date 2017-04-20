require(dplyr)
require(magrittr)
require(vcd)
require(MASS)

#Ingest data
ld <- read.csv('C:/Users/Sriva/Downloads/sqlite-tools-win32-x86-3180000/loyaltyWithGender.csv')
nrow(ld)
ldSubset <- ld[,c(6,4,5,3)]
head(ldSubset)

orders_n <- ldSubset
orders_n <- na.omit(orders_n)

nrow(orders_n)
head(orders_n)

RFM_raw <- with(orders_n, data.frame(CustomerID = sort(unique(UserId))))
RFM_raw <- cbind(RFM_raw, FirstPurchaseDate = with(orders_n, as.Date(as.integer(by(as.Date(ReceiptDate,'%Y-%m-%d'),UserId,min)),"1970-01-01")))
RFM_raw <- cbind(RFM_raw, LastPurchaseDate = with(orders_n, as.Date(as.integer(by(as.Date(ReceiptDate,'%Y-%m-%d'),UserId,max)),"1970-01-01")))
RFM_raw <- cbind(RFM_raw, NumberOfOrders = with(orders_n, as.numeric(by(ReceiptNumber, UserId, function(x) length(unique(x))))))
RFM_raw <- cbind(RFM_raw, TotalAmount = with(orders_n,as.numeric(by(ReceiptAmount,UserId,sum))))

nrow(RFM_raw)
head(RFM_raw)

#Get the last date of sale in the dataset
AsOfDate <- max(RFM_raw$LastPurchaseDate)
#save(RFM_raw, AsOfDate, file = "RFM_raw.Rda")

#Recency
Recency = as.integer(AsOfDate) - as.integer(RFM_raw$LastPurchaseDate)
RFM_raw <- cbind(RFM_raw, Recency)

#Frequency
RFM_raw$Frequency <- RFM_raw$NumberOfOrders

#MonetaryValue
MonetoryValue <- RFM_raw$TotalAmount / RFM_raw$NumberOfOrders
RFM_raw <- cbind(RFM_raw, MonetoryValue)

#Tenure
Tenure = as.integer(AsOfDate) - as.integer(RFM_raw$FirstPurchaseDate)
RFM_raw <- cbind(RFM_raw, Tenure)

RFM_segs <- data.frame(Recency_weeks = as.numeric(AsOfDate - RFM_raw$LastPurchaseDate) %/% 7)
row.names(RFM_segs) <- row.names(RFM_raw)

#write.csv(RFM_raw, file = "C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFM_data.csv", row.names = TRUE)

#Merge the RFM data with the customer dataset that has all the customer features with unique items and category per customer
data1 <- read.csv('C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFM_data.csv')
data2 <- read.csv('C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/Crosstab of Cat_Item_Age_Sales.csv')

head(data2)

RFM <- merge(data1,data2,by = "CustomerID")
nrow(RFM)

#write.csv(RFM, file = 'C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFM_Merge.csv', row.names = TRUE)

data3 <- read.csv('C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/src/region.csv', sep = ' ')

uniqueCustomer <- unique(data3$UserId)

uniqueData3 <- data3[!duplicated(data3),]

row.names(uniqueData3) <- NULL

#uniqueData3 <- uniqueData3[,1:2]
#colnames(uniqueData3) <- c('RowNum','CustomerID', 'Region')

RFMFeatures <- merge(RFM,uniqueData3, by = "CustomerID")

RFMFeatures <- within(RFMFeatures, rm('X'))

colnames(RFMFeatures) <- c('CustomerID','FirstPurchaseDate','LastPurchaseDate','Frequency','TotalAmount','Recency','Tenure','MonetaryValue','Gender','FirstName','LastName','Generation','CategoryBreadth','UndiscountedTotalSale','TotalItems','UniqueItems','Age','Region')

head(RFMFeatures)

#write.csv(RFMFeatures, file = 'C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFMFeatures.csv', row.names = TRUE)

RFMFeatures <- read.csv('C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFMFeatures.csv')

AsofDate <- max(as.Date(RFMFeatures$LastPurchaseDate,'%Y-%m-%d'))

#Recency

RFMFeatureSegs <- data.frame(Recency_weeks = as.numeric(AsOfDate - as.Date(RFMFeatures$LastPurchaseDate,'%Y-%m-%d')) %/% 7)

# max(RFMFeatureSegs$Recency_weeks)
# min(RFMFeatureSegs$Recency_weeks)
# 
# #Frequency
# 
# max(RFMFeatures$Frequency)
# min(RFMFeatures$Frequency)
# 
# #Monetary Value
# 
# max(RFMFeatures$MonetaryValue)
# min(RFMFeatures$MonetaryValue)
# 
# #Tenure
# 
# max(RFMFeatures$Tenure)
# min(RFMFeatures$Tenure)
# 
# #Breadth
# 
# max(RFMFeatures$CategoryBreadth)
# min(RFMFeatures$CategoryBreadth)
# 
# hist(RFMFeatures$Recency)
# hist(RFMFeatures$Frequency)
# hist(RFMFeatures$MonetaryValue)
# hist(RFMFeatures$Tenure)
# hist(RFMFeatures$CategoryBreadth)


#Get the feature dataset
RFMDerivedFeatures <- read.csv('C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFMDerivedFeatures.csv', sep = ',')
#colnames(RFMDerivedFeatures) <- c('Age','FrequencyS+egments','RecencySegments','MonetarySegments','TenureSegments','BreadthSegments','CategoryBreadth','CustomerId','FirstName','FirstPurchaseDate','Frequency','Gender','Generation','LastName','LastPurchaseDate','MonetaryValue','Recency','Region','Tenure','TotalAmount','TotalItems','UndiscountedTotalSales','UniqueItems')
#head(RFMDerivedFeatures)

RFMDerivedFeatures <- RFMDerivedFeatures[order(RFMDerivedFeatures$FrequencySegments,RFMDerivedFeatures$RecencySegments),]

#write.csv(RFMFeatures, file = 'C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFMDerivedFeatures.csv', row.names = TRUE)
require(gplots)


# Recency by Frequence - Counts
RxF <- as.data.frame(table(RFMDerivedFeatures$RecencySegments, RFMDerivedFeatures$FrequencySegments, dnn = c("Recency", "Frequency")),responseName = "Number_Customers")
RxF$Frequency <- factor(RxF$Frequency, levels = c("1-2 times","3-5 times","6-9 times","10-15 times","More than 15 times"))
RxF$Recency <- factor(RxF$Recency, levels = c("0-3 Months","4-7 Months","8-11 Months","12-15 Months","More than 15 Months"))
RxF <- RxF[order(RxF$Frequency,RxF$Recency,RxF$Number_Customers),]
RxF
with(RxF, balloonplot(Recency, Frequency, Number_Customers, zlab = "#Customers"))

options(digits = 4)
# Recency by Frequency - Annual Value (total annual sales to segment)
VbyRxF <- (aggregate(as.numeric(as.character(RFMDerivedFeatures$MonetaryValue)),
                     by = list(Recency = factor(RFMDerivedFeatures$RecencySegments),
                               Frequency = factor(RFMDerivedFeatures$FrequencySegments)),
                     sum))
names(VbyRxF)[3] <- "Annual_Sales"
VbyRxF$Annual_Sales <- VbyRxF$Annual_Sales / (15/12) 
## normalize to annual revenue


with(VbyRxF, balloonplot(Recency, Frequency, Annual_Sales / 1000, zlab =
                           "Annual Sales (000)"))

# a matrix of segment codes
RF_segs0 <- matrix("", nrow = 5, ncol = 5)
# manually make assignments
#object.browser() ## Fill in H, R, N, L, or O. Save as RF_segs.txt
RF_segs0[1,] <- c("N","O","O","O","")
RF_segs0[2,] <- c("R","R","R","L","")
RF_segs0[3,] <- c("R","R","L","L","")
RF_segs0[4,] <- c("H","R","L","L","")
RF_segs0[5,] <- c("H","H","L","","")
#RF_segs <- as.matrix(RF_segs0)
#RF_segs0
write.table(RF_segs0, file = "C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFM_segs.txt")
# get back into R
RF_segs <- as.matrix(read.delim("C:/Users/Sriva/Desktop/GeorgeMason/Spring2017/DAEN690/R Scripts/RFM_segs.txt", sep = " ",
                               na.strings = ""))
RF_segs[is.na(RF_segs)] <- "X" ## N/A's become "Lost"

# add colors and labels to balloon plot
# Magic values for balloon cell centers
RF_x <- matrix(2:6 + 0.25, nrow = 5, ncol = 5, byrow = TRUE)
RF_y <- matrix(5:1, nrow = 5, ncol = 5, byrow = FALSE)
RF_cols <- sapply(RF_segs, function(x) switch(x, H="gold",
                                              R="slategray2", N="green",
                                              L="yellow", O="darkgreen", "red"))

points(RF_x, RF_y, col = RF_cols, pch = 16, cex = 12)
text(RF_x, RF_y, RF_segs, cex = 2)


RFMDerivedFeatures$CustomerCategory <- ifelse((RFMDerivedFeatures$FrequencySegments %in% c("1-2 times")) & (RFMDerivedFeatures$RecencySegments %in% c("0-3 Months")), 'N', 
                                                ifelse(RFMDerivedFeatures$FrequencySegments %in% c("1-2 times") & RFMDerivedFeatures$RecencySegments %in% c("4-7 Months","8-11 Months","12-15 Months"), 'O',
                                                       ifelse(RFMDerivedFeatures$FrequencySegments %in% c("3-5 times","6-9 times","10-15 times") & RFMDerivedFeatures$RecencySegments %in% c("0-3 Months","4-7 Months","8-11 Months"), 'R',
                                                              ifelse(RFMDerivedFeatures$FrequencySegments %in% c("3-5 times","6-9 times","10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("8-11 Months","12-15 Months"), 'L',
                                                                     ifelse(RFMDerivedFeatures$FrequencySegments %in% c("1-2 times","3-5 times","6-9 times","10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("More than 15 Months"),'X',
                                                                            ifelse(RFMDerivedFeatures$FrequencySegments %in% c("10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("0-3 Months","4-7 Months"),'H','NA'))))))


RFMDerivedFeatures[RFMDerivedFeatures$FrequencySegments == '1-2 times',]


require(dplyr)
require(magrittr)
require(vcd)
require(MASS)

#Ingest data
ld <- read.csv('C:/Users/Downloads/sqlite-tools-win32-x86-3180000/loyaltyWithGender.csv')
nrow(ld)
str(ld)

#Extract the required data to generate RFM attributes
ldSubset <- ld[,c(6,4,5,3,9)]
head(ldSubset)
nrow(ldSubset)

orders_n <- ldSubset
orders_n <- na.omit(orders_n)

RFM_raw <- with(orders_n, data.frame(CustomerID = sort(unique(UserId))))
RFM_raw <- cbind(RFM_raw, FirstPurchaseDate = with(orders_n, as.Date(as.integer(by(as.Date(ReceiptDate,'%Y-%m-%d'),UserId,min)),"1970-01-01")))
RFM_raw <- cbind(RFM_raw, LastPurchaseDate = with(orders_n, as.Date(as.integer(by(as.Date(ReceiptDate,'%Y-%m-%d'),UserId,max)),"1970-01-01")))
RFM_raw <- cbind(RFM_raw, NumberOfOrders = with(orders_n, as.numeric(by(ReceiptNumber, UserId, function(x) length(unique(x))))))
RFM_raw <- cbind(RFM_raw, TotalAmount = with(orders_n,as.numeric(by(ReceiptAmount,UserId,sum))))

colnames(orders_n)[1] <- "CustomerID"
RFMR <- merge(orders_n,RFM_raw,by = "CustomerID")

head(orders_n)

#Get the last date of sale in the dataset
AsOfDate <- max(RFM_raw$LastPurchaseDate)

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

# Convert Recency from days to weeks
RFM_segs <- data.frame(Recency_weeks = as.numeric(AsOfDate - RFM_raw$LastPurchaseDate) %/% 7)
row.names(RFM_segs) <- row.names(RFM_raw)

RFMR <- merge(orders_n,RFM_raw,by = "CustomerID")

write.csv(RFM_raw, file = "C:/Users/R Scripts/RFM_data.csv", row.names = TRUE)

#Merge the RFM data with the customer dataset that has all the customer features with unique items and category per customer
data1 <- read.csv('C:/Users/R Scripts/RFM_data.csv')
data2 <- read.csv('C:/Users/R Scripts/Crosstab of Cat_Item_Age_Sales.csv')

RFM <- merge(data1,data2,by = "CustomerID")

#write.csv(RFM, file = 'C:/Users/R Scripts/RFM_Merge.csv', row.names = TRUE)

data3 <- read.csv('C:/Users/R Scripts/src/region.csv', sep = ' ')

uniqueCustomer <- unique(data3$UserId)
uniqueData3 <- data3[!duplicated(data3),]
row.names(uniqueData3) <- NULL
uniqueData3 <- uniqueData3[,1:2]
colnames(uniqueData3) <- c('CustomerID', 'Region')

RFMFeatures <- merge(RFM,uniqueData3, by = "CustomerID")

#colnames(RFMFeatures) <- c('CustomerID','FirstPurchaseDate','LastPurchaseDate','TotalAmount','Recency','Frequency','MonetaryValue','Tenure','Gender','FirstName','LastName','Generation','CategoryBreadth','UndiscountedTotalSale','TotalItems','UniqueItems','Age','Region')
#write.csv(RFMFeatures, file = 'C:/Users/R Scripts/RFMFeaturesWithGender.csv', row.names = TRUE)

RFMFeatures <- read.csv('C:/Users/R Scripts/RFMFeaturesWithGender.csv')
AsofDate <- max(as.Date(RFMFeatures$LastPurchaseDate,'%Y-%m-%d'))

#Recency

RFMFeatureSegs <- data.frame(Recency_weeks = as.numeric(AsOfDate - as.Date(RFMFeatures$LastPurchaseDate,'%Y-%m-%d')) %/% 7)

# Analysing the range of values for Recency, Frequency, MonetaryValue, Tenure and Breadth

# Recency
max(RFMFeatureSegs$Recency_weeks)
min(RFMFeatureSegs$Recency_weeks)
# Frequency
max(RFMFeatures$Frequency)
min(RFMFeatures$Frequency) 
# Monetary Value
max(RFMFeatures$MonetaryValue)
min(RFMFeatures$MonetaryValue) 
# Tenure
max(RFMFeatures$Tenure)
min(RFMFeatures$Tenure) 
#Breadth
max(RFMFeatures$CategoryBreadth)
min(RFMFeatures$CategoryBreadth) 

hist(RFMFeatures$Recency)
hist(RFMFeatures$Frequency)
hist(RFMFeatures$MonetaryValue)
hist(RFMFeatures$Tenure)
hist(RFMFeatures$CategoryBreadth)

#Get the feature dataset
RFMDerivedFeatures <- read.csv('C:/Users/R Scripts/RFMDerivedFeaturesWithLabels.csv', sep = ',')
#colnames(RFMDerivedFeatures) <- c('X','Age','FrequencySegments','RecencySegments','MOnetarySegments','TenureSegments','BreadthSegments','CategoryBreadth','CustomerID','FirstName','FirstPurchaseDate','Frequency','Generation','LastName','LastPurchaseDate','MonetarySegments','MonetaryValue','NumberOfRecords','RecencySegments','Recency','Region','Tenure','TOtalAmount','TotalItems','UndiscountedSales','UniqueItems')
head(RFMDerivedFeatures)
RFMDerivedFeatures <- within(RFMDerivedFeatures,rm('X'))
RFMDerivedFeatures <- RFMDerivedFeatures[order(RFMDerivedFeatures$FrequencySegments,RFMDerivedFeatures$RecencySegments),]

#write.csv(RFMDerivedFeatures, file = 'C:/Users/R Scripts/RFMDerivedSegmentsWithGender.csv', row.names = TRUE)
require(gplots)

# Recency by Frequence - Counts
RxF <- as.data.frame(table(RFMDerivedFeatures$RecencySegments, RFMDerivedFeatures$FrequencySegments, dnn = c("Recency", "Frequency")),responseName = "Number_Customers")
RxF$Frequency <- factor(RxF$Frequency, levels = c("1-2 times","3-5 times","6-9 times","10-15 times","More than 15 times"))
RxF$Recency <- factor(RxF$Recency, levels = c("0-3 Months","4-7 Months","8-11 Months","12-15 Months","More than 15 Months"))

options("scipen"=999)
RxF$Percentage <- prop.table(RxF$Number_Customers) * 100
RxF <- RxF[order(RxF$Frequency,RxF$Recency,RxF$Percentage),]
with(RxF, balloonplot(Recency, Frequency, Percentage , zlab = "%Customers \n Labels"))

options(digits = 4)
# Recency by Frequency - Annual Value (total annual sales to segment)
VbyRxF <- (aggregate(as.numeric(as.character(RFMDerivedFeatures$MonetaryValue)),
                     by = list(Recency = factor(RFMDerivedFeatures$RecencySegments),
                               Frequency = factor(RFMDerivedFeatures$FrequencySegments)),
                     sum))
names(VbyRxF)[3] <- "Annual_Sales"
VbyRxF$Annual_Sales <- VbyRxF$Annual_Sales / (15/12) 

# normalize to annual revenue
with(VbyRxF, balloonplot(Recency, Frequency, Annual_Sales, zlab =
                           "Annual Sales (000)"))

# a matrix of segment codes
RF_segs0 <- matrix("", nrow = 5, ncol = 5)

# manually make assignments
RF_segs0[1,] <- c("N","O","O","O","")
RF_segs0[2,] <- c("R","R","R","L","")
RF_segs0[3,] <- c("R","R","L","L","")
RF_segs0[4,] <- c("H","R","L","L","")
RF_segs0[5,] <- c("H","H","L","","")
write.table(RF_segs0, file = "C:/Users/R Scripts/RFM_segs.txt")

# get back into R
RF_segs <- as.matrix(read.delim("C:/Users/R Scripts/RFM_segs.txt", sep = " ",
                               na.strings = ""))
RF_segs[is.na(RF_segs)] <- "X" ## N/A's become "Lost"

# add colors and labels to balloon plot
RF_x <- matrix(2:6 + 0.25, nrow = 5, ncol = 5, byrow = TRUE)
RF_y <- matrix(5:1, nrow = 5, ncol = 5, byrow = FALSE)
RF_cols <- sapply(RF_segs, function(x) switch(x, H="gold",
                                              R="slategray2", N="green",
                                              L="yellow", O="darkgreen", "red"))

points(RF_x, RF_y, col = RF_cols, pch = 16, cex = 14)
text(RF_x, RF_y, RF_segs, cex = 2)

# RFMDerivedFeatures$CustomerCategory <- ifelse((RFMDerivedFeatures$FrequencySegments %in% c("1-2 times")) & (RFMDerivedFeatures$RecencySegments %in% c("0-2 Months")), 'N', 
#                                               ifelse(RFMDerivedFeatures$FrequencySegments %in% c("1-2 times") & RFMDerivedFeatures$RecencySegments %in% c("3-4 Months","5-6 Months","7-8 Months"), 'O',
#                                                      ifelse(RFMDerivedFeatures$FrequencySegments %in% c("3-5 times","6-9 times","10-15 times") & RFMDerivedFeatures$RecencySegments %in% c("0-2 Months","3-4 Months","5-6 Months"), 'R',
#                                                             ifelse(RFMDerivedFeatures$FrequencySegments %in% c("3-5 times","6-9 times","10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("5-6 Months","7-8 Months"), 'L',
#                                                                    ifelse(RFMDerivedFeatures$FrequencySegments %in% c("1-2 times","3-5 times","6-9 times","10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("7-8 Months","More Than 9 Months"),'X',
#                                                                           ifelse(RFMDerivedFeatures$FrequencySegments %in% c("10-15 times","More than 15 times") & RFMDerivedFeatures$RecencySegments %in% c("0-2 Months","3-4 Months"),'H','NA'))))))
# nrow(RFMDerivedFeatures$CustomerCategory)
# write.csv(RFMDerivedFeatures,file = 'C:/Users/R Scripts/RFMDerivedSegmentsWithLabelsAndGender.csv', row.names = TRUE)

spark_path <- strsplit(system("brew info apache-spark",intern=T)[4],' ')[[1]][1] # Get your spark path
.libPaths(c(file.path(spark_path,"libexec", "R", "lib"), .libPaths())) # Navigate to SparkR folder
library(SparkR) # Load the library
library(magrittr)

sparkR.session()

gnditem = read.df("/Users/Divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/TLD/GNDITEM.csv", 
                  'csv', header = "true", inferSchema = "true", na.strings = "NA")
#gndtndr = read.df("/Users/Divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/TLD/GNDTNDR.csv", 
                  #'csv', header = "true", inferSchema = "true", na.strings = "NA")
loyalty_data = read.df("/Users/divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/Loyalty_DistinctUsers_QueryResult.csv", 
                  'csv', header = "true", inferSchema = "true", na.strings = "NA")
head(loyalty_data)

createOrReplaceTempView(gnditem, "table")

gnditem_filtered <- sql("Select * from table where PRICE > 0 AND QUANTITY == 1")

gnditem_filtered$CheckDate = date_format(gnditem_filtered$DOB, 'yyyy-MM-dd')
gnditem_filtered$CheckTime = concat_ws(sep =':', gnditem_filtered$HOUR,gnditem_filtered$MINUTE)
gnditem_filtered$CheckTime = date_format(gnditem_filtered$CheckTime, "HH:mm")

gnditem_filtered$ModDate <- concat_ws(sep=" ",gnditem_filtered$CheckDate,gnditem_filtered$CheckTime)#,":",gnditem_filtered$MINUTE))

gnditem_filtered$ModDate = date_format(gnditem_filtered$ModDate, 'yyyy-MM-dd HH:mm')

loyalty_data$ModDate = unix_timestamp(loyalty_data$ReceiptDate, 'MM/dd/yy HH:mm')
loyalty_data$ModDate = from_unixtime(loyalty_data$ModDate, 'yyyy-MM-dd HH:mm')
head(loyalty_data)

gnditem_filtered_new = select(gnditem_filtered, "dlTableStoreNumber", 'CHECK', "ITEM", "PARENT", "CATEGORY",
                          "MODE", "HOUR", "MINUTE", "PRICE", "DOB", "QUANTITY", "DISCPRIC", 'ModDate')
str(gnditem_filtered_new)

mergedDF = merge(gnditem_filtered_new,loyalty_data, by.x = c("dlTableStoreNumber" ,"CHECK", "ModDate"), 
                 by.y = c("StoreNumber", "ReceiptNumber", "ModDate"))
head(mergedDF)
str(mergedDF)


#createOrReplaceTempView(mergedDF, "table1")
#visitCountDf <- sql("Select 'StoreNumber', 'CHECK', 'ITEM', 'PARENT', 'CATEGORY','MODE', 'PRICE', 'QUANTITY',
#              'DISCPRIC', count('ModDate_x'), 'Location', 'ReceiptAmount', 'UserId', 'FirstName', 'LastName',
#              'Gender', 'Birthday', 'FavoriteLocation', 'ZipCode' from table1  
#              groupBy 'UserId'")

#visitCountDf <- groupBy(mergedDF$ModDate_x, 'UserId') %>%count()

#visitCountDf = summarize(groupBy(mergedDF, mergedDF$UserId), count = n(mergedDF$ModDate_x))

#head(visitCountDf)

#visitCountDf = summarize(groupBy(mergedDF, mergedDF$UserId), count = n(mergedDF$ModDate_x))
#receiptAmntDf = summarize(groupBy(mergedDF, mergedDF$UserId), avg = avg(mergedDF$ReceiptAmount))
#This is what I need
itemCountDf = summarize(groupBy(mergedDF, mergedDF$UserId), count = n(mergedDF$ITEM))
head(itemCountDf)
#Take unique receiptamounts from loyalty df

properDataset = merge(itemCountDf,loyalty_data, by = "UserId")
head(properDataset)
count(properDataset)


#Creating the R datframe from SparkDataframe
Rdf <- collect(select(properDataset, "UserId_x", "count", "StoreNumber", "Location", "ReceiptNumber",
                      "VisitCount", "TotalReceiptAmount", "FirstName", "LastName", "Gender", "Birthday", 
                      "FavoriteLocation", "ZipCode"))
write.table(Rdf, file = "/Users/divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/RDf_ItemCount_Loyalty.csv", 
            append = FALSE, quote = TRUE, sep = " ", eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),fileEncoding = "utf-8")

#**********************************************
# Spark Kmeans code
#kmeansDF <- sample(twoDF, FALSE, 0.7)
#kmeansTestDF <- sample(twoDF, FALSE, 0.3)
#kmeansModel <- spark.kmeans(kmeansDF, ~ count, k = 3)

# Model summary
#summary(kmeansModel)

# Get fitted result from the k-means model
#showDF(fitted(kmeansModel))

# Prediction
#kmeansPredictions <- predict(kmeansModel, kmeansTestDF)
#showDF(kmeansPredictions)
#**********************************************
Rdf = read.csv("/Users/divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/RDf_ItemCount_Loyalty.csv")
library(ggplot2)
str(Rdf)

set.seed(20)
cluster1 <- kmeans(Rdf$count, 4)
cluster1

cluster1$cluster <- as.factor(cluster1$cluster)
ggplot(Rdf, aes(Rdf$count, Rdf$VisitCount, color = cluster1$cluster)) + geom_point()

numericDF = Rdf[ , -which(names(Rdf) %in% c("UserId","FirstName", "LastName", "Gender", "Birthday", 
                                            "StoreNumber", "Location", "ReceiptNumber", "FavoriteLocation", "ZipCode"))]
str(numericDF)
numericDF$VisitCount = sapply(numericDF$VisitCount, as.numeric)
numericDF <- na.omit(numericDF)
cluster2 <- kmeans(numericDF, 4)
cluster2

cluster2$cluster <- as.factor(cluster2$cluster)
ggplot(numericDF, aes(numericDF$ItemCount, numericDF$VisitCount, numericDF$TotalReceiptAmount,
                      color = cluster2$cluster)) + geom_point()

library(MASS)
library(rgl)

plot3d(numericDF, box=TRUE,
       xlab="ItemCount", ylab="VisitCount", zlab="ReceiptAmount", col = cluster2$cluster)



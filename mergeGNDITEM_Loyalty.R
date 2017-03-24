
spark_path <- strsplit(system("brew info apache-spark",intern=T)[4],' ')[[1]][1] # Get your spark path
.libPaths(c(file.path(spark_path,"libexec", "R", "lib"), .libPaths())) # Navigate to SparkR folder
library(SparkR) # Load the library

sparkR.session()

gnditem = read.df("/Users/Divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/TLD/GNDITEM.csv", 
                  'csv', header = "true", inferSchema = "true", na.strings = "NA")
loyalty_data = read.df("/Users/divya/OneDrive/Data Analytics/Spring 2017/DAEN 690/Data/Loyalty/Loyalty Rewards.csv", 
                  'csv', header = "true", inferSchema = "true", na.strings = "NA")

createOrReplaceTempView(gnditem, "table")

gnditem_filtered <- sql("Select * from table where PRICE > 0 AND QUANTITY == 1")

head(gnditem_filtered)
head(loyalty_data)

gnditem_filtered$CheckDate = concat(gnditem_filtered$DOB)

head(gnditem_filtered)
str(gnditem_filtered)
str(loyalty_data)

gnditem_filtered$CheckDate = date_format(gnditem_filtered$DOB, 'yyyy-MM-dd')
gnditem_filtered$CheckTime = concat_ws(sep =':', gnditem_filtered$HOUR,gnditem_filtered$MINUTE)
gnditem_filtered$CheckTime = date_format(gnditem_filtered$CheckTime, "HH:mm")
head(gnditem_filtered)

gnditem_filtered$ModDate <- concat_ws(sep=" ",gnditem_filtered$CheckDate,gnditem_filtered$CheckTime)#,":",gnditem_filtered$MINUTE))
head(gnditem_filtered)

gnditem_filtered$ModDate = date_format(gnditem_filtered$ModDate, 'yyyy-MM-dd HH:mm')
head(gnditem_filtered)

loyalty_data$ModDate = unix_timestamp(loyalty_data$ReceiptDate, 'MM/dd/yy HH:mm')
loyalty_data$ModDate = from_unixtime(loyalty_data$ModDate, 'yyyy-MM-dd HH:mm')
head(loyalty_data)
str(loyalty_data)

gnditem_filtered_new = select(gnditem_filtered, "dlTableStoreNumber", 'CHECK', "ITEM", "PARENT", "CATEGORY",
                          "MODE", "HOUR", "MINUTE", "PRICE", "DOB", "QUANTITY", "DISCPRIC", 'ModDate')
head(gnditem_filtered_new)

mergedDF = merge(gnditem_filtered_new,loyalty_data, by.x = c("dlTableStoreNumber" ,"CHECK", "ModDate"), 
                 by.y = c("StoreNumber", "ReceiptNumber", "ModDate") )
head(mergedDF)




require(magrittr)
require(vcd)

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

AsOfDate <- max(RFM_raw$LastPurchaseDate)
save(RFM_raw, AsOfDate, file = "RFM_raw.Rda")

Recency = as.integer(AsOfDate) - as.integer(RFM_raw$LastPurchaseDate)
RFM_raw <- cbind(RFM_raw, Recency)

Tenure = as.integer(AsOfDate) - as.integer(RFM_raw$FirstPurchaseDate)
RFM_raw <- cbind(RFM_raw, Tenure)

MonetoryValue <- RFM_raw$TotalAmount / RFM_raw$NumberOfOrders
RFM_raw <- cbind(RFM_raw, MonetoryValue)

RFM_segs <- data.frame(Recency_weeks = as.numeric(AsOfDate - RFM_raw$LastPurchaseDate) %/% 7)
row.names(RFM_segs) <- row.names(RFM_raw)


#Segmenting the customers
#Recency
RFM_segs$Recency <- ordered(ifelse(RFM_segs$Recency_weeks <= 12, "0-3",
                                   ifelse(RFM_segs$Recency_weeks <= 24 , "4-6",
                                          ifelse(RFM_segs$Recency_weeks <= 36, "7-9",
                                                 ifelse(RFM_segs$Recency_weeks <= 60, "10 - 12", "13-17")))), 
                            levels = c("0-3","4-6","7-9","10-12","13-17"))

#Frequency based on number of orders
RFM_segs$Frequency_count <- RFM_raw$NumberOfOrders
RFM_segs$Frequency <- ordered(ifelse(RFM_segs$Frequency_count == 1, "1",
                                     ifelse(RFM_segs$Frequency_count <= 5, '5-2',
                                            ifelse(RFM_segs$Frequency_count <= 10, '10-6', '10+'))),
                              levels = c("10+","10-6","5-2","1"))

#Monetory Value based on average ReceiptAmount
RFM_segs$Monetary_Value  <- RFM_raw$MonetoryValue
RFM_segs$Monetory <- ordered(ifelse(RFM_segs$Monetary_Value <= 15, "15-0",
                                    ifelse(RFM_segs$Monetary_Value <= 40, "40-16",
                                           ifelse(RFM_segs$Monetary_Value <= 60, "41-60",
                                                  ifelse(RFM_segs$Monetary_Value <= 80, "61-80","80+")))),
                             levels = c("80+","61-80","41-60","40-16","15-0"))

#Tenure of the customer
RFM_segs$Tenure_weeks <- as.numeric(AsOfDate - RFM_raw$FirstPurchaseDate) %/% 7
RFM_segs$Tenure <- ordered(ifelse(RFM_segs$Tenure_weeks <= 12, "0-12",
                                  ifelse(RFM_segs$Tenure_weeks <= 24, "13-24",
                                         ifelse(RFM_segs$Tenure_weeks <= 36, "25-36",
                                                ifelse(RFM_segs$Tenure_weeks <= 60, "37-60","60+")))),
                           levels = c("60+","37-60","25-36","13-24","0-12"))

head(RFM_segs)
save(RFM_segs, file = "RFM_segs.Rda")

RFM_st <- structable(~Recency + Frequency + Monetory, data = RFM_segs)
mm <- function(f){
  mosaic(f, data = RFM_st, 
         shade = TRUE, 
         labeling_args = list(rot_labels = c(left = 90, top = 45),
                              just_labels = c(left = "left",
                                              top = "center")),
         spacing = spacing_dimequal(unit(c(3.0, 0.8), "lines")),
         keep_aspect_ratio = FALSE
  )
}

mm (~Frequency + Recency)
mm (~Frequency + Monetory)
mm (~Monetory + Recency)





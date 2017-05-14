# Read the data into R data frame
CustomerData <- read.csv('C:/Users/R Scripts/RFMDerivedFeaturesWithLabels.csv')

# set the seed to make your partition reproductible
set.seed(123)
train_ind <- sample(seq_len(nrow(CustomerData)), size = smp_size) 
train <- CustomerData[train_ind, ]
test <- CustomerData[-train_ind, ]
nrow(train)
nrow(test)
write.csv(train,'C:/Users/R Scripts/train.csv')
write.csv(test,'C:/Users/R Scripts/test.csv')

####################### Code to bind promotion on sale ################################################

library(sqldf)
promotion_lbl = read.csv("C:/Users/R Scripts/Crosstab of Cat_Item_Age_Sales With Promotion.csv")
train <- read.csv('C:/Users/R Scripts/train.csv')
test <- read.csv('C:/Users/R Scripts/test.csv')
str(promotion_lbl) 
names(promotion_lbl)[names(promotion_lbl) == 'User.Id'] <- 'CustomerId'
names(promotion_lbl)[names(promotion_lbl) == 'Discounts.Taken'] <- 'HasPromotion' 
promotion_df_train <- sqldf("SELECT CustomerId, HasPromotion FROM promotion_lbl
                             JOIN train USING(CustomerId)")
promotion_df_test <- sqldf("SELECT CustomerId, HasPromotion FROM promotion_lbl
                            JOIN test USING(CustomerId)")
 
train_new = sqldf("SELECT * from train JOIN promotion_df_train USING(CustomerId)")
test_new = sqldf("SELECT * from test JOIN promotion_df_test USING(CustomerId)")
  
train_new <- within(train_new,rm('X','X.1','FirstName','LastName'))
test_new <- within(test_new,rm('X','X.1','FirstName','LastName'))

write.csv(train_new,'C:/Users/R Scripts/TrainFeatures.csv')
write.csv(test_new,'C:/Users/R Scripts/TestFeatures.csv')

############################## Read the train and test data into dataframe ##################################

train <- read.csv('C:/Users/R Scripts/TrainFeatures.csv')
test <- read.csv('C:/Users/R Scripts/TrainFeatures.csv')

############################## XGBoost implementation #######################################################

library(corrplot)
library(xgboost)
library(caret) 
library(dplyr)
library(pROC)
library(klaR)
library(caret)
library(outliers)

train_new <- na.omit(train)
train_new$Region <- as.numeric(as.factor(train_new$Region))
trainFeatures <- train_new[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]
trainFeatures <- sapply(trainFeatures,as.numeric)

#Preprocessing
outlier(trainFeatures)
nrow(trainFeatures)
identifyOutliers <-  function(x) {
   qnt <- quantile(x, probs=c(.25, .75))
   H <- 1.5 * IQR(x)
   outlier <- (x < (qnt[1] - H)) | (x > qnt[2] + H)
   outlier
 }
which(identifyOutliers(trainFeatures$TotalAmount))
trainFeatures$TotalAmount[identifyOutliers(trainFeatures$TotalAmount)] <- NA
outlierRemoved <- rm.outlier(trainFeatures, fill = FALSE, median = FALSE, opposite = FALSE)
nrow(outlierRemoved)
trainFeatures <- na.omit(trainFeatures)
trainFeatures <- outlierRemoved
trainFeaturesTrans <- preProcess(trainFeatures[,1:5],method = 'BoxCox')
trainFeatures <- predict(trainFeaturesTrans , trainFeatures)

#Feature Correlation
nrow(trainFeatures)
dim(trainFeatures)
mCorrPlot <- cor(trainFeatures)
corrplot(mCorrPlot,method = 'circle')
trainFeatures <- na.omit(trainFeatures)
num.class=length(levels(trainFeatures$CustomerCategory))
predictors <- colnames(trainFeatures[,-6])
label <- as.numeric(as.factor(trainFeatures[,6]))-1
print(table(label))
length(label)

#setting the parameter for Cross validation and XGBoost
param       = list("objective" = "multi:softmax", 	# multi class classification
                   "num_class"=  6 ,  				# Number of classes in the dependent variable.
                   "eval_metric" = "mlogloss",  	# evaluation metric 
                   "nthread" = 4,   			 	# number of threads to be used
                   "max_depth" = 6,    		 		# maximum depth of tree
                   "eta" = 0.3,    			 		# step size shrinkage
                   "gamma" = 0.3,    			 	# minimum loss reduction
                   "subsample" = 0.5,    		 	# part of data instances to grow tree
                   "colsample_bytree" = 0.5, 		# subsample ratio of columns when constructing each tree
                   "min_child_weight" = 1 		 	# minimum sum of instance weight needed in a child
                   )

###############Step 1: Cross Validation to identify the round with minimum loss error###########################

set.seed(100)
cv.nround = 50;
bst.cv = xgb.cv(
  param=param,
  data = as.matrix(trainFeatures[,predictors]),
  label = label,
  nfold = 4,
  nrounds=cv.nround,
  prediction=T)

################ Get the minimum logloss ##################################

min.loss.idx = which.min(bst.cv$evaluation_log$test_mlogloss_mean)
cat ("Minimum logloss occurred in round : ", min.loss.idx, "\n")
#min.error.idx = which.min(bst.cv$evaluation_log$train_merror_mean)
#cat ("Minimum error occurred in round : ", min.error.idx, "\n")

print(min.loss.idx)
#print(min.error.idx)

############## Step 2: Training the model with minlogloss ##############################

set.seed(100)
bst = xgboost(
  param=param,
  data =as.matrix(trainFeatures[,predictors]),
  label = label,
  nrounds=min.loss.idx)


############## Preparing the test data #################################################

test_new <- na.omit(test)
test_new$Region <- as.numeric(as.factor(test_new$Region))
testFeatures <- test_new[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]
testFeatures <- sapply(testFeatures,as.numeric)
testFeatures <- na.omit(testFeatures)
# testFeaturesTrans <- preProcess(testFeatures[,1:5],method = 'BoxCox')
# testFeatures <- predict(testFeaturesTrans , testFeatures)

mCorrPlot <- cor(testFeatures)
corrplot(mCorrPlot,method = 'circle')

############### Step 3: Predictions on test data ########################################
# boxplot(train$TotalAmount)
# hist(train$TotalAmount)

predictedValue <- predict(bst, as.matrix(testFeatures[,predictors]))
TestPredicted <- cbind(TestPredicted,predictedValue)

TestPredicted <- as.data.frame(TestPredicted)

head(TestPredicted)
length(TestPredicted$CustomerCategory)
length(TestPredicted$predictedValue)
class(TestPredicted$CustomerCategory)
class(TestPredicted$predictedValue)
table(TestPredicted$CustomerCategory)
table(TestPredicted$predictedValue)

# Classifier Accuracy
confusionMatrix(TestPredicted$predictedValue, TestPredicted$CustomerCategory)
cm <- confusionMatrix(TestPredicted$predictedValue, TestPredicted$CustomerCategory)
cm_class <- as.data.frame(cm$byClass)
cm_class <- na.omit(cm_class)
mean_precision<-mean(cm_class$`Pos Pred Value`)
mean_recall <- mean(cm_class$Sensitivity)
precision <- mean_precision
recall <- mean_recall
F1 <- (2 * precision * recall) / (precision + recall)

# AUC
actual <- TestPredicted$CustomerCategory
multiclass.roc(actual, predictedValue)
plot.roc(actual,predictedValue,print.auc=1,ci=1,auc.polygon = TRUE)

# Feature Importance
importance_matrix <- xgb.importance(feature_names = predictors,model = bst)
print(importance_matrix)
xgb.plot.importance(importance_matrix)

##################################### NaiveBayes using klaR ##############################################

library(ROCR)
library(klaR)
library(MLmetrics)

# Get the data
trainnb <- train[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]
testnb <- test[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]

# Model
model <- NaiveBayes(trainnb$CustomerCategory~., data=trainnb)

# make predictions
x_test <- testnb[,1:5]
y_test <- testnb[,6]
x_test <- na.omit(x_test)
y_test <- na.omit(y_test)
nrow(x_test)
length(y_test)
predictions <- predict(model, x_test)

# summarize results
confusionMatrix(predictions$class, y_test)
predicted_set <- as.data.frame(predictions)
predicted_set$obs <- y_test
names(predicted_set) <- c('pred','H','L','N','O','R','X','obs')

mnLogLoss(predicted_set,lev = levels(testnb$CustomerCategory))
lvls = levels(trainnb$CustomerCategory)

aucs = c()
plot(x=NA, y=NA, xlim=c(0,1), ylim=c(0,1),
     ylab='True Positive Rate',
     xlab='False Positive Rate',
     bty='n')

for (type.id in 1:6) {
  type = as.factor(trainnb$CustomerCategory == lvls[type.id])
  nbmodel = NaiveBayes(type ~ ., data=train[, -6])
  nbprediction = predict(nbmodel, testnb[,-6], type='raw')
  
  score = nbprediction$posterior[, 'TRUE']
  actual.class = testnb$CustomerCategory == lvls[type.id]
  
  pred = prediction(score, actual.class)
  
  nbperf = performance(pred, "tpr", "fpr")
  roc.x = unlist(nbperf@x.values)
  roc.y = unlist(nbperf@y.values)
  print(roc.x)
  print(roc.y)
  
  
  lines(roc.y ~ roc.x, col=type.id+1, lwd=2)
  
  nbauc = performance(pred, "auc")
  nbauc = unlist(slot(nbauc, "y.values"))
  aucs[type.id] = nbauc
}

lines(x=c(0,1), c(0,1),legend(0.9,0.6,lvls),
      col=c("red","green","blue","cyan","cyan","purple","yellow"))

mean(aucs)


################# Naive Bayes using Caret R  ########################################

library(AppliedPredictiveModeling)
library(doMC)
library(caret)

set.seed(1417)

trainnb <- train[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]
testnb <- test[,c('Age','TotalAmount','Region','HasPromotion','Tenure','CustomerCategory')]

trainnb <- na.omit(trainnb)
testnb <- na.omit(testnb)

registerDoMC(cores = 4)
mod <- train(CustomerCategory ~ ., data = trainnb, method = "nb",
             tuneLength = 10,
             trControl = trainControl(classProbs = TRUE,
                                      summaryFunction = multiClassSummary))

test_pred <- predict(mod, testnb, type = "prob")
test_pred$obs <- testnb$CustomerCategory
test_pred$pred <- predict(mod, testnb)

multiClassSummary(test_pred, lev = levels(test_pred$obs))

cm <- confusionMatrix(test_pred$obs,test_pred$pred)
cm_class <- as.data.frame(cm$byClass)
cm_class <- na.omit(cm_class)
mean_precision<-mean(cm_class$`Pos Pred Value`)
mean_recall <- mean(cm_class$Sensitivity)
precision <- mean_precision
recall <- mean_recall
F1 <- (2 * precision * recall) / (precision + recall)



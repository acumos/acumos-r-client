## Copyright (C) 2020 Orange
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
########### Acumos component source example ###########
# Calculate variable means by Species on Iris dataset
acumos_transform <- function(..., inputs=c(
  Sepal.Length="numeric",
  Sepal.Width="numeric",
  Petal.Length="numeric",
  Petal.Width="numeric",
  Species="character"
), outputs=c(
  Species="character",
  avg.Sepal.Length="numeric",
  avg.Sepal.Width="numeric",
  avg.Petal.Length="numeric",
  avg.Petal.Width="numeric"
)){
  df<-as.data.frame(list(...))
  means<-by(df, df$Species, function(x){
    apply(x[,-5], MARGIN = 2, mean)
  })
  res<-as.data.frame(do.call(rbind,means))
  colnames(res)<-paste0("avg.",colnames(res))
  res<-data.frame(Species=as.character(rownames(res)),res, row.names = NULL, stringsAsFactors = F)
  res
}
# Predict Species on Iris dataset using RF
## Train the model 
library(randomForest)
rf <- randomForest(Species ~ ., data=iris)
## Write the function executing the model
acumos_predict <- function(..., inputs=c(
  Sepal.Length="numeric",
  Sepal.Width="numeric",
  Petal.Length="numeric",
  Petal.Width="numeric"
)
, outputs=c(predictedSpecies="character")
){
  res<-list(as.character(predict(rf, as.data.frame(list(...)))))
  names(res)<-"predictedSpecies"
  res
} 

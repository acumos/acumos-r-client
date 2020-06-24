## ===============LICENSE_START=======================================================
## Acumos Apache-2.0
## ===================================================================================
## Copyright (C) 2020 Orange Intellectual Property. All rights reserved.
## ===================================================================================
## This Acumos software file is distributed by AT&T and Tech Mahindra
## under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## This file is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ===============LICENSE_END=========================================================


# Install Dependancies :

install.packages("randomForest")
library(randomForest)

install.packages("curl")

install.packages("RProtoBuf")
install.packages("acumos",,c("http://r.research.att.com","http://rforge.net"))

# create the model bundle
acumos::compose(predict=function(..., inputs=lapply(iris[-5], class)) print(as.character(predict(rf, as.data.frame(list(...))))),
        aux = list(rf = randomForest(Species ~ ., data=iris)),name="example_iris", file="model_bundle_example_iris.zip")
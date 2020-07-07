## ===============LICENSE_START=======================================================
## Acumos Apache-2.0
## ===================================================================================
## Copyright (C) 2020 Orange Intellectual Property. All rights reserved.
## ===================================================================================
## This Acumos software file is distributed by Orange
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

if ("httr" %in% rownames(installed.packages())==FALSE) {print("test failed : httr not installed")}
if ("jsonlite" %in% rownames(installed.packages())==FALSE) {print("test failed : jsonlite not installed")}
if ("RProtoBuf" %in% rownames(installed.packages())==FALSE) {print("test failed : RProtobuf not installed")}
if ("Rserve" %in% rownames(installed.packages())==FALSE) {print("test failed : Rserve not installed")}
if ("acumos" %in% rownames(installed.packages())==FALSE) {print("test failed : acumos R client not installed")}

if (("httr" %in% rownames(installed.packages())==TRUE) && ("jsonlite" %in% rownames(installed.packages())==TRUE) && ("RProtoBuf" %in% rownames(installed.packages())==TRUE) && ("Rserve" %in% rownames(installed.packages())==TRUE) && ("acumos" %in% rownames(installed.packages())==TRUE)) {print("test successful all dependancies packages installed")}
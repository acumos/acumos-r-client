## ===================LICENSE_START========================================================
## Acumos Apache-2.0
## ========================================================================================
## Copyright (C) 2020 Orange Intellectual Property. All rights reserved.
## ========================================================================================
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
## ====================LICENSE_END==========================================================


FROM r-base:4.0.2
ARG dir=/tmp/acumos-package
RUN mkdir $dir

COPY acumos-package $dir/
WORKDIR $dir

### system update ####
RUN apt-get update
RUN apt-get install -y libcurl4-openssl-dev libssl-dev protobuf-compiler libprotobuf-dev libprotoc-dev

### Install acumso-r-client and dependancies
RUN Rscript R_client_and_dependancies.R

## test acumos-r-client and dependancies
RUN Rscript tests_install_R_client_and_dependancies.R

## create a model bundel
RUN Rscript $dir/example_iris.R

## test if model bundle exist
RUN  ls model_bundle_example_iris.zip >> /dev/null 2>&1 && echo "test successfull : Model bundle created" || echo "test failed : Model bundle has not been created"

CMD ["Rscript","example_iris.R"]

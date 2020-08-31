<!---
.. ===============LICENSE_START=======================================================
.. Acumos CC-BY-4.0
.. ===================================================================================
.. Copyright (C) 2017-2018 AT&T Intellectual Property & Tech Mahindra. All rights reserved.
.. ===================================================================================
.. This Acumos documentation file is distributed by AT&T and Tech Mahindra
.. under the Creative Commons Attribution 4.0 International License (the "License");
.. you may not use this file except in compliance with the License.
.. You may obtain a copy of the License at
..
.. http://creativecommons.org/licenses/by/4.0
..
.. This file is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
.. ===============LICENSE_END=========================================================
-->

# Acumos R Client
![Acumoslogo](/docs/images/Acumos_logo_white.png)


 This repository holds the Acumos R Client(https://gerrit.acumos.org/r/acumos-R-client) which helps provide a way to use R in the Acumos Platform.
 It has to be used in conjunction with the Model Runner (https://gerrit.acumos.org/r/generic-model-runner).


Please see the documentation in the "docs" folder.

# Acumos R Interface

## Install

Under Debian/Ubuntu, install `remotes` and `acumos` dependencies first:

    apt install -y git-core libssl-dev libcurl4-openssl-dev make protobuf-compiler libprotoc-dev libprotobuf-dev

Then, in R, install `remotes`:

    install.packages("remotes")

Install this development version of `acumos` using `remotes`:

    remotes::install_github("acumos/acumos-r-client"; subdir="acumos-package")

## Usage

### Create a component

To create a deployment component, use `acumos::compose()` with the functions to expose. If type specs are not defined, they default to `c(x="character")`.

The component consists of a bundle `component.amc` which is a ZIP file with `meta.json` defining the component and its metadata, `component.bin` the binary payload and `component.proto` with the protobuf specs.

Please consult R documentation page for details, i.e., use `?compose` in R

Example:
    
    install.packages("randomForest")
    library(randomForest)
    library(acumos)
    compose(predict=function(..., inputs=lapply(iris[-5], class)) as.character(predict(rf, as.data.frame(list(...)))),
        aux = list(rf = randomForest(Species ~ ., data=iris)),
        name="Random Forest",
        file="component.amc"
        )

### Deploy a component

To run the component you have to create a `runtime.json` file with at least `{"input_port":8100}` or similar to define which port the component should listen to. If there are output components there should also be a `"output_url"` entry to specify where to send the result to. It can be either a single entry or a list if the results are to be sent to multiple components. Example:

    {"input_port":8100, "output_url":"http://127.0.0.1:8101/predict"}

With the component bundle `component.amc` plus `runtime.json` in place the component can be run using

    R -e 'acumos:::run()'

The `run()` function can be configured to set the component directory and/or location of the component bundle. If you don't want to create a file, the `runtime` parameter also accepts the runtime structure, so you can also use

    R -e 'acumos:::run(runtime=list(input_port=8100, output_url="http://127.0.0.1:8101/predict"))'

See also `?run` in R

### Onboard a component on Acumos platform

Once the model bundle is created, you can use the `push()` API client to on-board it in Acumos. This is CLI
(Command Line Interface) on-boarding. An example R command is the following:

	acumos::push(url = "https://<hostname>/onboarding-app/v2/models",
		file = "component.amc",
        token = "<username>:<token>",
        create = FALSE,
        license = "path/to/your/license.json")
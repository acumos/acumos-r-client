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

    apt-get update
	apt install -y git-core libssl-dev libcurl4-openssl-dev make protobuf-compiler libprotoc-dev libprotobuf-dev

Then, in R, install `remotes`:

    install.packages("remotes")

Install this development version of `acumos` using `remotes`:

    remotes::install_github("acumos/acumos-r-client", subdir="acumos-package")

## Usage

### Create a component

To create a deployment component, use `acumos::compose()` with the functions to expose. If type specs are not defined, they default to `c(x="character")`.

The component consists of a bundle `component.amc` which is a ZIP file with `meta.json` defining the component and its metadata, `component.bin` the binary payload, `component.proto` with the protobuf specs
and `component.swagger.yaml` with the Swagger API definition.

Please consult R documentation page for details, i.e., use `?compose` in R.

Example:
    
    install.packages("randomForest")
    library(randomForest)
    library(acumos)
    compose(predict=function(..., inputs=lapply(iris[-5], class)) as.character(predict(rf, as.data.frame(list(...)))),
        aux = list(rf = randomForest(Species ~ ., data=iris)),
        name="Random Forest",
        file="component.amc"
        )

### Create a component by writing a component R source code

You can also compose your model bundle directly from the R source code you used to build your model.

A regular component source code file is an R script in which at least one of the three following functions are defined:
`acumos_predict`, `acumos_transform` or `acumos_fit`. They respectively correspond to the functions `predict`, `transform`
and `fit` of `compose()`. In that script, if the functions `acumos_generate`, `acumos_service` or `acumos_initialize` are defined,
they will also correspond to the other function type arguments of `compose()`, namely `generate`, `service` and `initialize`.

    acumos::composeFromSource(file = "path/to/your/R/script/acumos.R",
        name = "MyComponentName",
        outputfile = "component.amc",
        addSource = TRUE)

The `addSource` parameter is a boolean that allows you to add the R source code (*component.R*) in your model bundle.

The path to an example component source code file can be found by executing the following R command:

    print(system.file("examples", "example_0", "acumos.R", package = "acumos"))

### Deploy a component

To run the component you have to create a `runtime.json` file with at least `{"input_port":8100}` or similar to define which port the component should listen to. If there are output components there should also be a `"output_url"` entry to specify where to send the result to. It can be either a single entry or a list if the results are to be sent to multiple components. Example:

    {"input_port":8100, "output_url":"http://127.0.0.1:8101/predict"}

With the component bundle `component.amc` plus `runtime.json` in place the component can be run using

    R -e 'acumos:::run()'

The `run()` function can be configured to set the component directory and/or location of the component bundle. If you don't want to create a file, the `runtime` parameter also accepts the runtime structure, so you can also use

    R -e 'acumos:::run(runtime=list(input_port=8100, data_response=TRUE))'

See also `?run` in R.

### Onboard a component on Acumos platform

#### CLI on-boarding with `push()` function

Once the model bundle is created, you can use the `push()` API client to on-board it on Acumos. This is CLI
(Command Line Interface) on-boarding. An example R command is the following:

    acumos::push(url = "https://<hostname>/onboarding-app/v2/models",
        file = "component.amc",
        token = "<username>:<token>",
        create = FALSE,
        license = "path/to/your/license.json")

`url`: can be found in the ON-BOARDING MODEL page of your Acumos portal and looks like :
`<hostname>/onboarding-app/v2/models`

`file`: component.amc (your model bundle)

`username` : your Acumos username

`token`: API token available in the Acumos portal in your profile section

`create` : logical parameter (Boolean) to trigger the creation of microservice at the end of
on-boarding process. By default create=TRUE, if you don't want to create the microservice modify the
value to FALSE (create =FALSE)

`license`: path to the license profile file : The license profile file name must be "license.json".

#### CLI on-boarding with `pushFromSource()` function

Rather than creating the model bundle with `compose()` and then on-boarding it with `push()`, you can use the
`pushFromSource()` function that allow you to on-board your model directly from your R source code and put this R
source code inside the model bundle.

	acumos::pushFromSource(url = "https://<hostname>/onboarding-app/v2/models",
		file = "path/to/your/R/script/acumos.R",
		name = "MyComponentName", addSource = FALSE,
		token = "<username>:<token>", create = FALSE,
		license = "path/to/your/license.json")

The path to an example component source code file can be found by executing the following R command:

	print(system.file("examples", "example_0", "acumos.R", package = "acumos"))

#### Authentication

The use of API token is recommended to avoid typing your password in command line, but you can also authenticate yourself by using the `auth()` API:

	acumos::auth("https://<hostname>", "username", "password")

`url`: can be found in the ON-BOARDING MODEL page of your Acumos portal and looks like "https://<hostname>/onboarding-app/v2/auth"

`username` : your Acumos username

`password` : your Acumos password

In response, you will receive an authentication token to be used in the `push()` or `pushFromSource()` function instead of "<username>:<token>"

Whatever the function you used, at the end of a successful CLI on-boarding with microservice creation, you will receive a message with the Acumos docker URI
of your model.

#### Web on-boarding

You can also drag & drop your model bundle on the "ON-BORADING BY WEB" page in your Acumos instance,
or browse you model bundle from this page. This is Web on-boarding.

You can on-board your model with a license profile, you just have to browse your license profile file or drag and drop it.

Whatever the case, CLI or WEB on-boarding, if the license profile file extension is not 'json' the license
on-boarding will not be possible and if the name is not 'license' Acumos will rename your license
file as license.json and you will see your license profile file as "license-1.json" in the artifacts table.
If you upload a new version of your license through the portal, the license number revision will be
increased by one like that "license-2.json". To help user create the license profile file expected by Acumos
a license profile editor user guide is available here : `License profile editor user guide <../../license-manager/docs/user-guide-license-profile-editor.html>`_

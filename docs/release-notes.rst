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

=============================
Acumos R Client Release Notes
=============================

These release notes cover the Acumos R client

Version 0.4-4, 01 July 2021
------------------------------
* Enclosed the URL in DESCRIPTION in angle brackets (<...>) `ACUMOS-4341 <https://jira.acumos.org/browse/ACUMOS-4341>`_
* Debug DEBIAN test-api fail : write the intermediate zip file produced by `compose()` into the temp dir `ACUMOS-4341 <https://jira.acumos.org/browse/ACUMOS-4341>`_

Version 0.4-3, 07 June 2021
------------------------------
* The zip file produced by `compose()` will contain a another zip file (model.zip) including the component.bin and the compenent.swagger.yaml files. This mimics the current python client behavior, so that the compenent.swagger.yaml file can be uploaded without changes at Acumos on-boarding and Acumos Portal. `ACUMOS-4326 <https://jira.acumos.org/browse/ACUMOS-4326>`_
* In the `push` function, if component.swagger.yaml exists it will be zipped along with component.bin into model.zip. And the request 'payload' is model.zip in this case.`ACUMOS-4326 <https://jira.acumos.org/browse/ACUMOS-4326>`_
* In the `push` function, if a model.zip file exists in the model bundle, it will be unzipped.`ACUMOS-4326 <https://jira.acumos.org/browse/ACUMOS-4326>`_

Version 0.4-2, 02 April 2021
------------------------------
* Set that when create==FALSE deploy cannot be set to TRUE. `ACUMOS-4305 <https://jira.acumos.org/browse/ACUMOS-4305>`_
* Correct the `push` function so that the swagger YAML file is uploaded as part of the bundle.
* By default, set the bundle (component) file extension to '.zip' instead of '.amc'.

Version 0.4-1, 02 October 2020
------------------------------
* debug `pkg.deps()`: (i) a less R version dependant base packages listing, (ii) continue the while loop until the good order of package dependencies is found, (iii) correctly exclude base packages (remove versions and whitespaces in the while loop). `ACUMOS-4280 <https://jira.acumos.org/browse/ACUMOS-4280>`_
* handle component variables to run without modifying `.GlobalEnv` (not allowed by the CRAN policies) `ACUMOS-4268 <https://jira.acumos.org/browse/ACUMOS-4268>`_
* use of `thesthat`: test that the API works after 'run()'.

Version 0.4-0, 03 September 2020
--------------------------------
* with `compose()`, generate a new file, `component.swagger.yaml`, that describes the component API using swagger 2.0. `ACUMOS-4212 <https://jira.acumos.org/browse/ACUMOS-4212>`_
* serve a swagger UI at the path `/` and the swagger YAML description file at the path `/swagger.yaml`, using `RestRserve`. `ACUMOS-4212 <https://jira.acumos.org/browse/ACUMOS-4212>`_
* the API can now receive and send data with "application/vnd.google.protobuf" and "application/json" content types. The content-type must be precised, and is considered as "application/json" by default.

Version 0.3-0, 13 March 2020
----------------------------
* add `composeFromSource()` and `pushFromSource()` functions, enabling respectively to compose and to push a bundle from an R file (considered as the component source) in which all the functions and auxiliary objects needed to compose the bundle are defined : `ACUMOS-3972 <https://jira.acumos.org/browse/ACUMOS-3972>`_
* change `push()` to look up and include in the POST request a potential `component.R` file contained in the bundle :  `ACUMOS-3776 <https://jira.acumos.org/browse/ACUMOS-3776>`_

Version 0.2-8, 12 April 2019
----------------------------
* add 'create' and 'headers' parameters to push() : `ACUMOS-2278 <https://jira.acumos.org/browse/ACUMOS-2268/>`_
* add 'license' file : `ACUMOS-2278 <https://jira.acumos.org/browse/ACUMOS-2278/>`_
* change the meaning of '...' in push() to supply any additional elements for body of the 'POST' request. This allows optional  parameters to be added to the onboarding service.

Version 0.2-7
-------------
* allow the 'file' argument in run() to be a directory containing the unpacked component.

Version 0.2-6
-------------
* added send.msg(..., response=TRUE) to allow more easy testing of REST-style pushes (internal interface only).
* minor documentation updates such as mention of data_response run-time option.

Version 0.2-5
-------------
* updated to generate meta.json version 0.5.0
* added service rpc entry in the proto file

Version 0.2-4
-------------
* update push() to take the bundle and upload in pieces until the server supports bundles.
* include schema version in meta.json

Version 0.2-3
-------------
* improve package dependency detection by removing versions and whitespaces

Version 0.2-2
-------------
* add run(init.only=TRUE) option to setup the run-time environment without actually running the server
* new runtime parameter data_response=TRUE enables direct passing of the output data to the caller.When set the POST request to the functions (like /predict) returns the result in the same request. If not set (the default) it only retuns success/failure status.

Version 0.2-1
-------------
* add auth() function to obtain authentication token from Acumos.
* add push(token=) to use token (obtained form auth()) for authentication purposes.

Version 0.2-0
-------------
* switch to using bundle model component files (.amc) instead of individual files (.json/.bin/.proto)
* add debuging env var ACUMOS_DEBUG for verbose logging

Version 0.1-2
-------------
* add support for push()
* include non-loaded dependencies

Version 0.1-1
-------------
* add documentation
* add transform, fit, genertae and service endpoints

Version 0.1-0
-------------
* initial version


The Acumos R Client library code is maintained by Simon Urbanek at
Forge <https://r-forge.r-project.org/>`_.

See also:

* `Acumos R client info on rforge.net <http://rforge.net/acumos/>`_
* `NEWS <https://github.com/s-u/acumos/blob/master/NEWS>`_ for info on revisions
  to the Acumos R Client
* `Acumos R Interface <https://github.com/s-u/acumos>`_ guide on github

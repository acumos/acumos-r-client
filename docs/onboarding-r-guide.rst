.. ===============LICENSE_START=======================================================
.. Acumos
.. ===================================================================================
.. Copyright (C) 2017-2018 AT&T Intellectual Property & Tech Mahindra. All rights reserved.
.. ===================================================================================
.. This Acumos documentation file is distributed by AT&T and Tech Mahindra
.. under the Creative Commons Attribution 4.0 International License (the "License");
.. you may not use this file except in compliance with the License.
.. You may obtain a copy of the License at
..
..      http://creativecommons.org/licenses/by/4.0
..
.. This file is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
.. ===============LICENSE_END=========================================================
.. NOTE: THIS FILE IS LINKED TO FROM THE DOCUMENTATION PROJECT
.. IF YOU CHANGE THE LOCATION OR FILE NAME, YOU MUST UPDATE THE DOCS PROJECT INDEX.RST

==========================
Acumos R Client User Guide
==========================

Using the Acumos R Client
=========================

Please refer to the `Acumos R Client Installation and Maintenance Guide <installation-and-maintenance-guide.html>`_ prior to the following

Model bundle
------------

To on-board a model in Acumos you need to create a model bundle, use compose() with the functions to expose to create it. Below is an example
of how create a model bundle based on the IRIS model.

.. code:: bash

    compose(predict=function(..., inputs=lapply(iris[-5], class)) print(as.character(predict(rf, as.data.frame(list(...))))),
    aux = list(rf = randomForest(Species ~ ., data=iris)),name="IRIS_model", file="path/to/store/the/model/bundle/IRIS_model.zip")

This model bundle contains :

#) meta.json defining the component and their metadata,
#) component.bin the binary payload,
#) and component.proto with the protobuf specs.


Please consult R documentation page for details, use the following command in R

.. code:: bash
   ??acumos

or see the `Compose <http://www.rforge.net/doc/packages/acumos/compose.html>`_ page at RForge.

If you used R under windows you could meet an issue using the acumos::compose() function due to some
problems between R under windows and zip. If RTools is not installed on your windows environment,
the model bundle will not be created. So please follows the installation procedure of
`Rtools <https://cran.r-project.org/bin/windows/Rtools/>`_ then set your environmental variables
properly, add the bin folder of Rtools to the system path.

You can also compose your model bundle directly from the R source code you used to build your model.

.. code:: bash

    composeFromSource(file="path/to/your/R/script",name="name of your model", outputfile = "component.zip", addSource='T')

The "addSource" parameter is a boolean that allow you to add the R source code in your modle bundle.


CLI and Web on-boarding
-----------------------

- CLI on-boarding with push() function

Once the model bundle is created, you can use the push() API to on-board it in Acumos. This is CLI
(Command Line Interface) on-boarding.

.. code-block:: bash

	push("https://url","file","username:token","create","license")

url can be found in the ON-BOARDING MODEL page of your Acumos portal and looks like :
"hotsname:port/onboarding-app/v2/models"

file : component.zip (your model bundle)

username : your Acumos username

token : Api token available in the Acumos portal in your profile section

create : logical parameter (Boolean) to trigger the creation of microservice at the end of
on-boarding process. By default create=TRUE, if you don't want to create the microservice modify the
value to FALSE (create =FALSE)

license : path to the license profile file : The license profile file name must be "license.json".

- CLI on-boarding with pushFromSource() function

Rather than create the model bundle with compose() and then on-board the model with push(), you can use the
pushFromSource() function that allow you to on-board your model directly from your R source code and put this R 
source code inside the model bundle.

.. code-block:: bash

        pushFromSource("https://url",file="path/to/your/R/script",name="name of your model",addSource=T,"username:token","create","license")

- Authentication

                
The use of Api token is recommended to avoid typing your password in command line, but you can also authenticate yourself by using the auth() API:

.. code-block:: bash

	auth("https://url","username","password")

url can be found in the ON-BOARDING MODEL page of your Acumos portal and looks like "hostname:port/onboarding-app/v2/auth"

username : your Acumos username

password : your Acumos password

In response, you will receive an authentication token to be used in the push() or pushFromSource() function instead of "usernale:token"

Whatever the function you used, at the end of a successful CLI on-boarding with microservice creation, you will receive a message with the Acumos docker URI
of your model.

- Web on-boarding

You can also drag & drop your model bundle on the "ON-BORADING BY WEB" page in your Acumos instance,
or browse you model bundle from this page. This is Web on-boarding.

You can on-board your model with a license profile, you just have to browse your license profile file or drag and drop it.

Whatever the case, CLI or WEB on-boarding, if the license profile file extension is not 'json' the license
on-boarding will not be possible and if the name is not 'license' Acumos will rename your license
file as license.json and you will see your license profile file as "license-1.json" in the artifacts table.
If you upload a new version of your license through the portal, the license number revision will be
increased by one like that "license-2.json". To help user create the license profile file expected by Acumos
a license profile editor user guide is available here : `License profile editor user guide <../../license-manager/docs/user-guide-license-profile-editor.html>`_




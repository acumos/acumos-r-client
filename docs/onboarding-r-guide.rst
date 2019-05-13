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

=========================
R Model On-Boarding guide
=========================
.. note::
    R Client v0.2-8 was tested with the Acumos Boreas platform release

Prerequisites
=============
Before you begin:

#) You must have the following packages installed in your system : protobuf-compiler,protobuf-c-compiler, libprotobuf-c-dev, libprotobuf-dev,libprotoc-dev

#) You must have an Acumos account

#) You must have protobuf 3 installed on your system (version 2 will not work).

   .. code:: bash

      git clone https://github.com/google/protobuf.git protobuf
      cd protobuf
      ./autogen.sh
      ./configure --prefix=`pwd`/../`uname -m`-linux-gnu
      make
      make install

#) You must have R installed on you system (R>3.4.4). Please have a look at `cran.r-project.org <https://cran.r-project.org/>`_

Installing the Acumos R Client
==============================

Within R you need to install and load all dependent packages from CRAN first.

.. code:: bash

    install.packages(c("Rcpp","RCurl","RUnit","rmarkdown","knitr","pinp","xml2"))
    library(Rcpp,Rcurl,RUnit,rmarkdown,knitr,pinp)

Then Install the Acumos R Client package and RProtobuf package thanks to the following command:

.. code:: bash

    install.packages("RProtoBuf")
    install.packages("acumos",,c("http://r.research.att.com","http://rforge.net"))


Alternatively, to install from sources:

.. code:: bash

    git clone git@github.com:s-u/acumos.git or git clone https://github.com/s-u/acumos.git
    R CMD build acumos
    R CMD INSTALL acumos_*.tar.gz


Using the Acumos R Client
=========================

Model bundle
------------

To on-board a model in Acumos you need to create a model bundle, use acumos::compose() with the
functions to expose to create it. Below is an example of how create a model bundle nade on the IRIS
model

.. code:: bash

    acumos::compose(predict=function(..., inputs=lapply(iris[-5], class)) print(as.character(predict(rf, as.data.frame(list(...))))),aux = list(rf = randomForest(Species ~ ., data=iris)),name="IRIS_model", file="path/to/store/the/model/bundle/IRIS_model.zip")

This model bundle contains : 

#) meta.json defining the component and their metadata,
#) component.bin the binary payload,
#) and component.proto with the protobuf specs.


Please consult R documentation page for details, i.e., use ?compose in R or see
the `Compose <http://www.rforge.net/doc/packages/acumos/compose.html>`_ page at
RForge.

If you used R under windows you could meet an issue using the acumos::compose() function due to some
problems between R under windows and zip. If RTools is not installed on your windows environment,
the model bundle will not be created. So please follows the installation procedure of
`Rtools <https://cran.r-project.org/bin/windows/Rtools/>`_ then set your environmental variables
properly, add the bin folder of Rtools to the system path.

Authentication and upload
-------------------------

- CLI on-boarding

Once the model bundle is created, you can use the push() API to upload it in Acumos. This CLI
(Command Line Interface) on-boarding.

.. code-block:: bash

    acumos::push("https://url","file","username:token","create","license")

url can be found in the ON-BOARDING MODEL page of your Acumos portal and looks like :
"hotsname:port/onboarding-app/v2/models"

file : component.zip

username : your Acumos username

token : Authentication token available in the Acumos portal in your profile section

create : logical parameter (Boolean) to trigger the creation of microservice at the end of
on-boarding process. By default create=TRUE, if you don't want to create the microservice modify the
value to FALSE (create =FALSE)

license : path to the license file : "license.json". After onboarding the model with license,
the artifacts will show license file with name "license.json" even if user has uploaded the license
file with different name.

You can also authenticate yourself by using the auth() API:

.. code-block:: bash

    acumos::auth("url","username","password")

url can be found in the ON-BOARDING MODEL page of your Acumos portal and lokks like
"hostname:port/onboarding-app/v2/auth"

username : your Acumos username

password : your Acumos password


In the Response, you will receive an authentication token to be used in the acumos::push() function
like that : acumos::push("https://url","file","token","create","license")

-Web on-boarding

You can also drag & drop your model bundle on the "ON-BORADING BY WEB" page in your Acumos instance,
or browse you model bundle from this page.

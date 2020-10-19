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

==================================================
Acumos R Client Installation and Maintenance Guide
==================================================

Prerequisites
=============
Before you begin:

#) You must have an Acumos account

#) You must have R installed on you system (R>3.4.4). Please refer to `cran.r-project.org <https://cran.r-project.org/>`_

Installing the Acumos R client
==============================

Under **Debian/Ubuntu**, you may need to install first some packages:

.. code:: bash 

	apt-get update
	apt-get install -y libssl-dev libcurl4-openssl-dev make protobuf-compiler libprotoc-dev libprotobuf-dev

Install the Acumos R client package in R:

.. code:: bash

	install.packages("acumos")
	
If you want to install the version under development, please use `remotes` or `devtools`:

.. code:: bash

	remotes::install_github("acumos/acumos-r-client", subdir="acumos-package")

or

.. code:: bash

	devtools::install_github("acumos/acumos-r-client", subdir="acumos-package")
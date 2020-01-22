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
.. note::
    R Client v0.2-8 was tested with the Acumos Boreas platform release

Prerequisites
=============
Before you begin:

#) You must have the following packages installed in your system : protobuf-compiler, protobuf-c-compiler, libprotobuf-c-dev, libprotobuf-dev, libprotoc-dev

#) You must have an Acumos account

#) You must have R installed on you system (R>3.4.4). Please have a look at `cran.r-project.org <https://cran.r-project.org/>`_

Installing the Acumos R Client
==============================

Install the Acumos R Client package and RProtobuf package thanks to the following command:

.. code:: bash

    install.packages("acumos",,c("http://r.research.att.com","http://rforge.net"))


Alternatively, you can only install Acumos from sources:

.. code:: bash

    git clone git@github.com:s-u/acumos.git or git clone https://github.com/s-u/acumos.git
    R CMD build acumos
    R CMD INSTALL acumos_*.tar.gz

and then intall RProtobuf in R

.. code:: bash

    install.packages("RProtoBuf")


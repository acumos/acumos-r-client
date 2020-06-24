if ("httr" %in% rownames(installed.packages())==FALSE) {print("test failed : httr not installed")}
if ("jsonlite" %in% rownames(installed.packages())==FALSE) {print("test failed : jsonlite not installed")}
if ("RProtoBuf" %in% rownames(installed.packages())==FALSE) {print("test failed : RProtobuf not installed")}
if ("Rserve" %in% rownames(installed.packages())==FALSE) {print("test failed : Rserve not installed")}
if ("acumos" %in% rownames(installed.packages())==FALSE) {print("test failed : acumos R client not installed")}

if (("httr" %in% rownames(installed.packages())==TRUE) && ("jsonlite" %in% rownames(installed.packages())==TRUE) && ("RProtoBuf" %in% rownames(installed.packages())==TRUE) && ("Rserve" %in% rownames(installed.packages())==TRUE) && ("acumos" %in% rownames(installed.packages())==TRUE)) {print("test successful all dependancies packages installed")}
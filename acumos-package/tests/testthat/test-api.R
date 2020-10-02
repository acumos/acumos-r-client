context("api")

test_that("run API works", {
  
  # create temp test dir
  dir <- tempfile("acumos-runtime-test")
  dir.create(dir)
  
  # compose a simple RF component
  library(randomForest)
  compose(predict=function(..., inputs=lapply(iris[-5], class)){
    print(as.character(predict(rf, as.data.frame(list(...)))))
  },
  aux = list(rf = randomForest(Species ~ ., data=iris)),
  name="Random Forest", 
  file = file.path(dir,"component.zip"))
  
  # run the RF component in background
  p <- callr::r_bg(function(dir){acumos:::run(where = dir, file=file.path(dir,"component.zip"), runtime=list(input_port=3330, data_response=TRUE))}, args = list(dir))
  Sys.sleep(6) ## wait a bit for the server to start
  head(p$read_output_lines())
  
  # read the ProtoBuf file
  unzip(file.path(dir,"component.zip"), exdir=dir)
  RProtoBuf::readProtoFiles(file.path(dir, "component.proto"))
  
  # prepare request payloads
  dat=iris[c(1,100,150),-5]
  json_payload=RestRserve::to_json(dat)
  proto_payload=acumos:::data2msg(data=dat, output = "predictInput")
  
  # test some requests
  ## json-json
  out_json_json<-httr::content(httr::POST(url="http://127.0.0.1:3330/predict", 
                                          body=json_payload, 
                                          httr::content_type("application/json"),
                                          httr::accept("application/json")
  ))
  readable_out_json_json<-unname(unlist(out_json_json))
  ## proto-json
  out_proto_json<-httr::content(httr::POST(url="http://127.0.0.1:3330/predict", 
                                           body=proto_payload, 
                                           httr::content_type("application/vnd.google.protobuf"),
                                           httr::accept("application/json")
  ))
  readable_out_proto_json<-unname(unlist(out_proto_json))
  ## proto-proto
  out_proto_proto<-httr::content(httr::POST(url="http://127.0.0.1:3330/predict", 
                                            body=proto_payload, 
                                            httr::content_type("application/vnd.google.protobuf"),
                                            httr::accept("application/vnd.google.protobuf")
  ))
  readable_out_proto_proto<-acumos:::msg2data(out_proto_proto, input="predictOutput")
  readable_out_proto_proto<-unname(unlist(readable_out_proto_proto))
  ## json-proto
  out_json_proto<-httr::content(httr::POST(url="http://127.0.0.1:3330/predict", 
                                           body=json_payload, 
                                           httr::content_type("application/json"),
                                           httr::accept("application/vnd.google.protobuf")
  ))
  readable_out_json_proto<-acumos:::msg2data(out_json_proto, input="predictOutput")
  readable_out_json_proto<-unname(unlist(readable_out_json_proto))
  
  # clean up
  p$interrupt()
  p$kill()
  unlink(dir, TRUE)
  
  # test
  expect_identical(
    lapply(list(readable_out_json_json,
                readable_out_proto_json,
                readable_out_proto_proto,
                readable_out_json_proto), 
           identical, y=c("setosa","versicolor","virginica")),
    list(TRUE,TRUE,TRUE,TRUE))
  
  # clean again
  rm("dat", "dir", "json_payload", "out_json_json", "out_json_proto", "out_proto_json", 
       "out_proto_proto", "p", "proto_payload", "readable_out_json_json", "readable_out_json_proto", 
       "readable_out_proto_json", "readable_out_proto_proto")
})

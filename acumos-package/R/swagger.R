## Copyright (C) 2020 Orange
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
#
#' Generate swagger json from defined functions
swaggerYaml<-function(predict, transform, fit, name, componentVersion){
  pathlist<-list()
  deflist<-list()
  for(i in 1:3){
    switch (i,
            "1" = {
              x="predict"
              isnotmissing<-!missing(predict)
              if(isnotmissing){
                sig <- fetch.types(predict)
              }
            },
            "2" = {
              x="transform"
              isnotmissing<-!missing(transform)
              if(isnotmissing){
                sig <- fetch.types(transform)
              }
            },
            "3" = {
              x="fit"
              isnotmissing<-!missing(fit)
              if(isnotmissing){
                sig <- fetch.types(fit)
              }
            }
    )
    if(isnotmissing){
      path_i<-list(list(
        post=list(
          operationId=paste0(x,"_service_",x),
          responses=list(
            "200"=list(
              description="A successful response.",
              schema=list(
                "$ref"=paste0("#/definitions/",x,"Output")
              )
            ),
            default=list(
              description="An unexpected error response.",
              schema=list(
                "$ref"="#/definitions/runtimeError"
              )
            )
          ),
          parameters=list(list(
            name= "body", 
            "in"= "body",
            required= TRUE,
            schema= list(
              "$ref"=paste0("#/definitions/",x,"Input")
            )
          )
          ),
          tags=list(
            paste0(x,"_service")
          )
        )
      ))
      names(path_i)<-paste0("/",x)
      pathlist<-c(pathlist,path_i)
      propertiesListInput<-lapply(sig$inputs,function(j){
        list(
          type= "array",
          items=list(
            type=type2swagger(j)
          )
        )
      })
      names(propertiesListInput)<-names(sig$inputs)
      propertiesListOutput<-lapply(sig$outputs,function(j){
        list(
          type= "array",
          items=list(
            type= type2swagger(j)
          )
        )
      })
      names(propertiesListOutput)<-names(sig$outputs)
      inputlist=list(list(
        type= "object",
        properties=propertiesListInput
      ))
      names(inputlist)<-paste0(x,"Input")
      outputlist=list(list(
        type= "object",
        properties=propertiesListOutput
      ))
      names(outputlist)<-paste0(x,"Output")
      deflist<-c(deflist,
                 inputlist,
                 outputlist
      )
    }
  }
  deflist<-c(deflist,list(
    protobufAny=list(
      type="object",
      properties=list(
        typeURL=list(
          type="string"
        ),
        value=list(
          type="string",
          format="byte"
        )
      )
    ),
    runtimeError=list(
      type="object",
      properties=list(
        error=list(
          type="string"
        ),
        code=list(
          type="integer",
          format="int32"
        ),
        message=list(
          type="string"
        ),
        details=list(
          type="array",
          items=list(
            "$ref"="#/definitions/protobufAny"
          )
        )
      )
    )
  ))
  apilist<-list(swagger="2.0", 
                info=list(
                  title=name,
                  version=componentVersion
                ),
                consumes=c("application/json","application/vnd.google.protobuf"),
                produces=c("application/json","application/vnd.google.protobuf"),
                paths=pathlist,
                definitions=deflist
  )
  return(apilist)
}
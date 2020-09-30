## Copyright (C) 2017 AT&T
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

## collect dependencies - i.e. loaded packages and their versions
pkg.deps <- function() {
  ip <- installed.packages()
  p <- loadedNamespaces()
  base <-  c("R",rownames(ip[
    ip[,"Priority"]%in%c("base")|
      ip[,"License"]%in%paste0("Part of R ",R.version$major,".",R.version$minor),
    ]))
  p <- unique(p[! p %in% base])
  np <- p
  p <- character()
  ## iterate recursively until no new deps are detected
  while (length(np) != length(p) | !identical(order(np),order(p))) {
    p <- np
    m <- na.omit(match(p, rownames(ip)))
    xp <- unique(gsub(" .*","",unlist(strsplit(c(ip[m,"Depends"], ip[m,"LinkingTo"], ip[m, "Imports"]), ", *"))))
    xp <- unique(gsub("\\s+","",gsub("[ \t(]+.*", "", xp))) ## remove versions and whitespaces
    np <- na.omit(unique(c(xp, p)))
    np <- np[! np %in% base]
  }
  l <- lapply(np, function(o) { d=packageDescription(o); d=d[c("Package", "Version")]; names(d)=c("name","version"); d })
  list(l)
}
## fetch type info from a function
fetch.types <- function(f, default.in=c(x="character"), default.out=c(x="character")) {
  args <- formals(f)
  in. <- if ("inputs" %in% names(args)) eval(args$inputs, environment(f)) else default.in
  out. <- if ("outputs" %in% names(args)) eval(args$outputs, environment(f)) else default.out
  list(inputs=in., outputs=out.)
}

## compose a component
compose <- function(predict, transform, fit, generate, service, initialize, aux=list(), name="R Component", componentVersion="unknown version", file="component.amc") {
  dir <- tempfile("acumos-component")
  if (!all(dir.create(dir))) stop("unable to create demporary directory in `",dir,"' to assemble the component bundle")

  meta <- list(schema="acumos.schema.model:0.5.0", name=name,
               runtime=list(list(name="r", version="1.0",
                                 dependencies = c(list(R=paste(R.version$major, R.version$minor, sep='.')), packages=I(pkg.deps())))),
               methods=list()
  )
  comp <- list(aux = aux, packages = loadedNamespaces())
  proto <- 'syntax = "proto2";\n'
  if (!missing(predict)) {
    comp$predict <- predict
    sig <- fetch.types(predict)
    meta$methods$predict = list(description="predict", input="predictInput", output="predictOutput")
    proto <- c(proto, protoDefine("predictInput", sig$inputs), protoDefine("predictOutput", sig$outputs), protoService("predict"))
  }
  if (!missing(transform)) {
    comp$transform <- transform
    sig <- fetch.types(transform)
    meta$methods$transform = list(description="transform", input="transformInput", output="transformOutput")
    proto <- c(proto, protoDefine("transformInput", sig$inputs), protoDefine("transformOutput", sig$outputs), protoService("transform"))
  }
  if (!missing(fit)) {
    comp$fit <- fit
    sig <- fetch.types(fit)
    meta$methods$fit = list(description="fit", input="fitInput", output="fitOutput")
    proto <- c(proto, protoDefine("fitInput", sig$inputs), protoDefine("fitOutput", sig$outputs), protoService("fit"))
  }
  if (!missing(generate)){
    comp$generate <- generate
    sig <- fetch.types(generate)
    meta$methods$generate = list(description="generate", input="generateInput", output="generateOutput")
    proto <- c(proto, protoDefine("generateInput", sig$inputs), protoDefine("generateOutput", sig$outputs))
  }
  if (!missing(service)) comp$http.service <- service
  if (!missing(initialize)) comp$initialize <- initialize
  if (length(meta$methods) < 1L) warning("No methods defined - the component won't do anything")
  saveRDS(comp, file=file.path(dir, "component.bin"))
  writeLines(jsonlite::toJSON(meta, auto_unbox=TRUE), file.path(dir, "meta.json"))
  writeLines(proto, file.path(dir, "component.proto"))
  yaml::write_yaml(swaggerYaml(predict, transform, fit, name, componentVersion), file.path(dir, "component.swagger.yaml"),
                   handlers = list(
                     logical = function(x) {
                       result <- ifelse(x, "true", "false")
                       class(result) <- "verbatim"
                       return(result)
                     }
                   ))
  ## -j ignores paths (is it portable in Widnows?)
  if (file.exists(file) && unlink(file)) stop("target file already exists and cannot be removed")
  zip(file, c(file.path(dir, "component.bin"), file.path(dir, "meta.json"), file.path(dir, "component.proto"), file.path(dir, "component.swagger.yaml")), extras="-j")
  unlink(dir, TRUE)
  invisible(meta)
}

type2proto <- function(x) sapply(x, function(o) {
  switch(o,
         character = "string",
         integer = "int32",
         numeric = "double",
         raw = "bytes",
         stop("unsupported type ", o)) })
type2swagger <- function(x) sapply(x, function(o) {
  switch(o,
         character = "string",
         integer = "integer",
         numeric = "number",
         raw = "string",
         stop("unsupported type ", o)) })
## proto has a more restricted definiton of identifiers so we have to work around that
## by introducing a special quoting scheme
pQ <- function(x) gsub(".", "_o", gsub("_", "_X", x, fixed=TRUE), fixed=TRUE)
pU <- function(x) gsub("_X", "_", gsub("_o", ".", x, fixed=TRUE), fixed=TRUE)

protoDefine <- function(name, types) {
  paste0("message ", name, " {\n",
         paste0("\trepeated ", type2proto(types), " ", pQ(names(types)), " = ", seq.int(types), ";", collapse="\n"),
         "\n}\n")
}

protoService <- function(name, inputType = paste0(name, "Input"), outputType = paste0(name, "Output"))
  paste0("service ", name, "_service {\n\trpc ", name, " (", inputType, ") returns (", outputType, ");\n}\n\n")

.dinfo <- function(level, ..., exp) {
  cd <- Sys.getenv("ACUMOS_DEBUG")
  if (nzchar(cd) && as.integer(cd) >= level) {
    writeLines(paste0(Sys.getpid(), "/", as.numeric(Sys.time()),": ", ...), stderr())
    if (!missing(exp)) writeLines(capture.output(exp), stderr())
  }
}

run <- function(where=getwd(), file="component.amc", runtime="runtime.json", init.only=FALSE) {
  file <- path.expand(file)
  .dinfo(1L, "INFO: starting component in '", where,"', archive:", file, ", runtime:", runtime)
  if (dir.exists(file)) {
    .dinfo(2L, "INFO: component is a directory, assuming unpacked content")
    dir <- file
  } else {
    dir <- tempfile("acumos-runtime")
    dir.create(dir)
    on.exit(unlink(dir, TRUE))
    unzip(file, exdir=dir)
    .dinfo(2L, "INFO: component unpacked in ", dir)
  }
  metadata <- file.path(dir, "meta.json")
  payload <- file.path(dir, "component.bin")
  proto <- file.path(dir, "component.proto")
  swagger<-file.path(dir,"component.swagger.yaml")
  c.files <- c(metadata, payload, proto)
  ok <- file.exists(c.files)
  if (!all(ok)) stop(paste0("invalid archive (missing ",
                            paste(basename(c.files[!ok]), collapse=", "),
                            ")"))
  meta <- jsonlite::fromJSON(readLines(metadata), FALSE)
  .dinfo(2L, "INFO: loaded metadata:", exp=print(meta))
  comp <- readRDS(payload)
  .dinfo(2L, "INFO: components:", exp=str(comp))
  aux <- comp$aux
  comp$aux <- NULL
  .dinfo(2L," INFO: managed aux vars: ", exp=print(names(aux)))
  rt <- runtime <- if (is.list(runtime)) runtime else jsonlite::fromJSON(readLines(runtime), FALSE)
  .dinfo(2L, "INFO: loading runtime: ", exp=print(rt))
  RProtoBuf::readProtoFiles(proto)
  if (length(comp$packages)) {
    .dinfo(2L, "INFO: loading packages: ", exp=print(comp$packages))
    for (pkg in comp$packages) library(pkg, character.only=TRUE)
  }
  if (is.function(comp$initialize)) {
    .dinfo(1L, "INFO: calling initialize()")
    comp$initialize()
  }
  if (init.only) return(TRUE)
  if (is.function(comp$generate)) {
    .dinfo(1L, "INFO: calling generate()")
    comp$generate()
  } else {
    if (is.null(rt$input_port)) stop("input port is missing in the runtime")
    .dinfo(1L, "INFO: starting HTTP server on port ", rt$input_port)
    app = Application$new(middleware = list())
    encode_decode_middleware = EncodeDecodeMiddleware$new()
    encode_decode_middleware$ContentHandlers$set_decode("application/vnd.google.protobuf", identity)
    encode_decode_middleware$ContentHandlers$set_encode("application/vnd.google.protobuf", identity)
    app$append_middleware(encode_decode_middleware)
    req_handler_overloaded <- function(request, response){
      req_handler(request=request, response=response, comp=comp, meta=meta, runtime=runtime, aux=aux)
    }
    if (is.function(comp$predict)) app$add_post(path = "/predict", FUN = req_handler_overloaded)
    if (is.function(comp$transform)) app$add_post(path = "/transform", FUN = req_handler_overloaded)
    if (is.function(comp$fit)) app$add_post(path = "/fit", FUN = req_handler_overloaded)
    if(file.exists(swagger)){
      app$add_openapi(path = "/swagger.yaml", file_path = swagger)
      app$add_swagger_ui(path = "/", path_openapi = "/swagger.yaml", use_cdn = TRUE)
    }
    backend = BackendRserve$new()
    wd<-getwd()
    on.exit(setwd(wd))
    setwd(where)
    backend$start(app, http_port = rt$input_port)
  }
}

send.msg <- function(url, payload, response=FALSE) {
  .dinfo(3L, "INFO: POST to ", url)
  .dinfo(4L, "INFO: payload: ", exp=print(payload))
  r <- tryCatch(httr::POST(url, body=payload),
                error=function(e) stop("ERROR: failed to send data to ",url,": ", as.character(e)))
  if (isTRUE(response)) return(r)
  if (identical(r$status_code, 200L)) TRUE else {
    warning("POST to ", url, " was not successful: ", rawToChar(r$content))
    FALSE
  }
}

data2msg <- function(data, output) {
  res.msg <- RProtoBuf::P(output)$new()
  .dinfo(4L, "INFO: data2msg: ", exp=str(data))
  if (is.list(data) && !is.null(names(data))) {
    for (n in names(data)) res.msg[[pQ(n)]] <- data[[n]]
  } else res.msg[[1]] <- data
  res.msg$serialize(NULL)
}

msg2data <- function(msg, input) {
  schema <- RProtoBuf::P(input)
  .dinfo(4L, "INFO: msg2data input: ", exp=print(msg))
  data <- schema$read(msg)
  n <- names(data)
  data <- lapply(n, function(o) data[[o]])
  names(data) <- pU(n)
  .dinfo(4L, "INFO: msg2data result: ", exp=str(data))
  data
}

with_env <- function(f, e=parent.frame()) {
  stopifnot(is.function(f))
  environment(f) <- e
  f
}

req_handler <- function(request, response, comp, meta, runtime, aux){ 
  fn.env <- new.env()
  for (i in names(aux)) assign(i, aux[[i]], envir = fn.env)
  fn <- NULL
  fn.meta <- NULL
  .dinfo(2L, "INFO: handing HTTP ", request$path, ", method ", request$method)
  .dinfo(4L, "INFO: state: meta: ", exp=str(meta))
  .dinfo(4L, "INFO: state: comp: ", exp=str(comp))
  fn.type <- "<unknown>"
  if (isTRUE(grepl("^/predict", request$path))) {
    fn <- comp$predict
    fn.meta <- meta$methods$predict
    fn.type <- "predict"
  }
  if (isTRUE(grepl("^/transform", request$path))) {
    fn <- comp$transform
    fn.meta <- meta$methods$transform
    fn.type <- "transform"
  }
  if (isTRUE(grepl("^/fit", request$path))) {
    fn <- comp$fit
    fn.meta <- meta$methods$fit
    fn.type <- "fit"
  }
  .dinfo(3L, "INFO: handler type: ", fn.type, ", formats: ", exp=str(fn.meta))
  if (is.null(fn)) {
    if (is.function(comp$http.service)) return(comp$http.service(request$path, request$method, request$body, request$headers))
    return("ERROR: unsupported API call (fn is null)")
  }
  if (!is.function(fn)) return(paste0("ERROR: this component doesn't support ", fn.type, "()"))
  if (is.null(fn.meta$input)) return(paste0("ERROR: ", fn.type, "() schema is missing input type specification"))
  tryCatch({
    if(request$content_type %in% "application/vnd.google.protobuf"){
      res <- do.call(with_env(fn,fn.env), msg2data(request$body, fn.meta$input))
      if (!is.null(res) && !is.null(fn.meta$output) && length(unlist(res))>0) {
        msg <- data2msg(res, fn.meta$output)
        for (url in runtime$output_url)
          send.msg(url, msg)
        if (isTRUE(runtime$data_response)){
          if(request$accept %in% "application/vnd.google.protobuf"){
            response$set_body(msg)
            response$set_content_type("application/vnd.google.protobuf")
            return(response)
          }else{
            response$set_body(res)
            response$set_content_type("application/json")
            return(response)
          }
        }
      }else{
        response$set_status_code(500L)
        response$set_body("Unable to compute. Please verify the arguments.")
        return(response)
      }
    }else{
      if(is.null(names(request$body)) && length(request$body)==1){ # string
        dat<-jsonlite::fromJSON(request$body)
      }else{ # list (from json)
        dat<-request$body
      }
      res <- do.call(with_env(fn,fn.env), dat)
      if(!is.null(res) && length(unlist(res))>0){
        if(request$accept %in% "application/vnd.google.protobuf"){
          msg<-data2msg(res, fn.meta$output)
          response$set_body(msg)
          response$set_content_type("application/vnd.google.protobuf")
          return(response)
        }else{
          response$set_body(res)
          response$set_content_type("application/json")
          return(response)
        }
      }
    }
    response$set_body("OK")
    response$set_content_type("text/plain")
    return(response)
  }, error=function(e){
    paste("ERROR: in execution: ", as.character(e))
    response$set_status_code(500L)
    response$set_body("Unable to compute. Please verify the arguments.")
    return(response)
  })
}

auth <- function(url, user, password) {
  auth_req = list(request_body=list(password=as.character(password)[1L], username=as.character(user)[1L]))
  res <- POST(url, body=jsonlite::toJSON(auth_req, auto_unbox=TRUE), add_headers(`Content-type` = "application/json"))
  if (status_code(res) < 400L) { ## OK
    info <- jsonlite::fromJSON(rawToChar(res$content))
    if (is.null(info$jwtToken))
      stop("jwtToken is missing in the authorization response: ", rawToChar(res$content))
    info$jwtToken
  } else stop("Authentiaction request failed: ", rawToChar(res$content))
}

push <- function(url, file="component.amc", token, create=TRUE, license, headers, ...) {
  ## FIXME: the server currently accepts only multiplart form
  ## with the uncompressed contents - until the server is fixed to
  ## support the component bundle properly we have to unpack and push
  dir <- tempfile("acumos-push")
  dir.create(dir)
  on.exit(unlink(dir, TRUE))
  unzip(file, exdir=dir)
  metadata <- file.path(dir, "meta.json")
  payload <- file.path(dir, "component.bin")
  proto <- file.path(dir, "component.proto")
  addSource<-file.exists(file.path(dir, "component.R"))
  if(addSource){
    source <- upload_file(file.path(dir, "component.R"), type = "text/plain; charset=UTF-8")
  }else{
    source <- NULL
  }
  headers <- if (missing(headers)) list() else as.list(headers)
  headers[["Content-Type"]] <- "multipart/form-data"
  headers[["isCreateMicroservice"]] <- if (isTRUE(create)) "true" else "false"
  if (!missing(token)) headers$Authorization <- token
  body <- list(
    metadata = upload_file(metadata, type = "application/json; charset=UTF-8"),
    schema = upload_file(proto, type = "text/plain; charset=UTF-8"),
    model = upload_file(payload, type = "application/octet"),
    source = source)
  body <- body[!sapply(body, is.null)]
  aux <- list(...)
  if (length(names(aux))) for (i in names(aux)) body[[i]] <- aux[[i]]
  if (!missing(license)) {
    license <- path.expand(license)
    if (!file.exists(license))
      stop("specified license file `", license, "` does not exist")
    system(paste("cp",shQuote(license), shQuote(file.path(dir, "license.json"))))
  }
  if (file.exists(file.path(dir, "license.json"))) body$license <- upload_file(file.path(dir, "license.json"), "text/plain")
  req <- POST(url, body=body,
              do.call(httr::add_headers, headers), encode="multipart")
  if (http_error(req)) stop("HTTP error in the POST request: ", content(req))
  if (content(req)$status=="SUCCESS") {
    cat("Model pushed successfully to :",url,"\n")
    if(headers[["isCreateMicroservice"]]=="true") {cat("Acumos model docker image successfully created :",content(req)$dockerImageUri,"\n")}
  }
  invisible(content(req))
}

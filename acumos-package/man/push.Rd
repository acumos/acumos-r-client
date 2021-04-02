\name{push}
\alias{push}
\alias{auth}
\title{
  Push a component into the Acumos repository
}
\description{
  \code{push} pushes a component into the Acumos repository.

  \code{auth} obtains an authentication token to be used with
  \code{push} where required.
}
\usage{
push(url, file = "component.amc", token, create=TRUE, deploy=FALSE, license,
     headers, ...)
auth(url, user, password)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{url}{URL for the POST request}
  \item{file}{component bundle file as created by \code{compose}}
  \item{token}{token obtained from \code{auth} (optional)}
  \item{create}{logical, \code{isCreateMicroservice} parameter.
   If TRUE the model Docker image is automatically created by the Acumos platform.
   See Acumos onboarding documentation.}
  \item{deploy}{logical.
   If TRUE the model is automatically deployed by the Acumos platform based on an
  external jenkins server configuration.
   This parameter cannot take the value TRUE, when the parameter
   \code{create} takes the value FALSE.
   See Acumos onboarding documentation.}
  \item{license}{optional string, name of a file to supply as the
    license. If not specified \code{push()} will also try to locate
    a \code{license.json} file in the component bundle if present.}
  \item{headers}{optional, named list or named character vector
    of HTTP headers that are to be added to the request. NOTE:
    the meaning of optional headers depends on the onboarding server
    so consult the documentation of the onboarding server for
    supported additional headers and their meaning.}
  \item{user}{user name to use for authentication}
  \item{password}{password to use for authentication}
  \item{\dots}{any additional form entries to push as body content.
    If the entry is to be passed as a file upload, use
    \code{upload_file(<file>, <mime-type>)}.}
}
%\details{
%}
\value{
  \code{push}: invisibly, result of the request (may change in the
  future)

  \code{auth}: authentication token
}
%\references{
%}
\author{
  Simon Urbanek
}
%\note{
%}
\seealso{
  \code{\link{compose}}
}
\keyword{interface}

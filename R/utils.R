#' Utility functions for the tgR.data package
#'
#'
#' Checks for correct credentials.
#' @export
check_credentials <- function() {
  if ("" %in% Sys.getenv(c("REDURI","TGR", "S3META", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_DEFAULT_REGION"))) {
    stop("You have missing credentials.")} else message("Credentials set successfully.")
}
#'
#'
#'
#' Sets credentials from a file.
#' @param path The path to the file to source that contains appropriately defined environment variables (see requiredCredentials.R for an example).
#' @export
set_credentials <- function(path) {
  # These are the most likely defaults for our users which can be overwritten by their own creds.
  Sys.setenv(REDURI="https://redcap.fredhutch.org/API/")
  Sys.setenv(AWS_DEFAULT_REGION = "us-west-2")
  source(path)
  if ("" %in% Sys.getenv(c("REDURI","TGR", "S3META", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_DEFAULT_REGION"))) {
    stop("You have missing credentials.")} else message("Credentials set successfully.")
}

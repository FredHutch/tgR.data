#' Utility functions for the tgR.data package
#'
#'
#' Checks for correct AWS credentials.
#' @export
check_aws_credentials <- function() {
  if ("" %in% Sys.getenv(c( "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_DEFAULT_REGION"))) {
    stop("You have missing AWS credentials.")} else message("Credentials set successfully.")
}
#' Checks for correct AWS S3 metadata credentials.
#' @export
check_s3meta_credentials <- function() {
  if ("" %in% Sys.getenv(c("REDURI", "S3META"))) {
    stop("You have missing TGR S3 Metadata credentials.")} else message("Credentials set successfully.")
}
#' Checks for correct dataset annotation credentials.
#' @export
check_annot_credentials <- function() {
  if ("" %in% Sys.getenv(c("REDURI","TGR"))) {
    stop("You have missing TGR Dataset Annotation credentials.")} else message("Credentials set successfully.")
}
#' Checks for all correct credentials.
#' @export
check_all_credentials <- function() {
  if ("" %in% Sys.getenv(c("REDURI","TGR", "S3META",  "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_DEFAULT_REGION"))) {
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

#' Permanently deletes data provenance in REDCap for files that have been deleted in S3
#'
#' @param uuid (Required) UUID of object to delete data provenance for
#' @export

delete_file_entries <- function(uuid = NULL) {
  suppressMessages(check_credentials())
  if(is.null(uuid)) {stop("Please provide uuid(s) for file entries to delete.")}
  message("Deleting records cannot be undone. ")
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='delete',
                   'records[0]'= uuid,
                   returnFormat='json')
  httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")
  message(paste("Deleted record", uuid))
}

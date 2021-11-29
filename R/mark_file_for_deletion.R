#' Marks files in REDCap that have been deleted from S3
#'
#' @param uuid (Required) UUID of object to mark for deletion of data provenance
#' @export

mark_file_for_deletion <- function(uuid = NULL) {
  suppressMessages(check_credentials())
  if(is.null(uuid)) {stop("Please provide uuid(s) for file entries to delete.")}
  csv <- paste(paste0('\"', paste("uuid","deleted_object", sep = '\",\"')),
               paste0(paste(uuid, 1, sep = '\",\"'), '\"'), sep = '\"\n\"')
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   format='csv',
                   type='flat',
                   data=csv,
                   returnFormat = 'csv',
                   returnContent= "ids")
  results <- httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")
  suppressMessages(idDF<-httr::content(results))
  if(results$status_code == "200") {message(paste("Marked record for deletion:", idDF$id))} else
  {stop(paste0("Process unsuccessful. Status code: ", results$status_code))}
}

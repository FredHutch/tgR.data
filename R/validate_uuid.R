#' Checks to ensure a uuid is not already used
#'
#' @param uuid (Required) uuid you'd like to check
#' @return Returns NA if all uuids are valid, and an array of invalid uuids if any are invalid
#' @details Note: Only works for admin users.
#' @export
#'
validate_uuid <- function(uuid = NULL) {
  if(is.null(uuid)) {stop("Please provide at least one uuid.")}
  suppressMessages(check_credentials())
  message("Checking for existing record(s) with the uuid(s) provided.")
  logic <- paste0("[uuid] = '", paste(uuid, collapse = "' OR [uuid] = '"), "'")
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='uuid',
                   rawOrLabel='raw',
                   rawOrLabelHeaders='raw',
                   exportCheckboxLabel='false',
                   exportSurveyFields='false',
                   exportDataAccessGroups='false',
                   returnFormat='csv',
                   filterLogic=logic)
  alreadyUsed <- suppressMessages(httr::content(
    httr::POST(url = Sys.getenv("REDURI"),
               body = formData, encode = "form", show_col_types = FALSE)))

  if (nrow(alreadyUsed)>0) {result <- alreadyUsed$uuid} else {result <- NA}
  return(result)
}

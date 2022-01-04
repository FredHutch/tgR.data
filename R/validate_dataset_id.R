#' Checks to ensure a dataset_id is not already used and is valid
#'
#' @param dataset_id (Required) dataset_id(s) you'd like to check
#' @return Returns NA if all dataset_ids are valid, and an array of invalid dataset_ids if any are invalid
#' @details Unfortunately this currently only works for an admin user.
#' @export
#'
validate_dataset_id <- function(dataset_id = NULL) {
  if(is.null(dataset_id)) {stop("Please provide at least one dataset_id.")}
  suppressMessages(check_s3meta_credentials())
  message("Checking for existing record(s) with the dataset_id(s) provided.")
  logic <- paste0("[dataset_id] = '", paste(dataset_id, collapse = "' OR [dataset_id] = '"), "'")
  formData <- list("token"=Sys.getenv("TGR"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='dataset_id',
                   rawOrLabel='raw',
                   rawOrLabelHeaders='raw',
                   exportCheckboxLabel='false',
                   exportSurveyFields='false',
                   exportDataAccessGroups='false',
                   returnFormat='csv',
                   filterLogic=logic)
  alreadyUsed <- suppressMessages(a <- httr::content(
    httr::POST(url = Sys.getenv("REDURI"),
               body = formData, encode = "form", show_col_types = FALSE)))

  if (nrow(alreadyUsed)>0) {result <- alreadyUsed$dataset_id} else {result <- NA}
  return(result)
}

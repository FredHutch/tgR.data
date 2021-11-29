#' Find files that used to be in S3 that are marked for deletion of their data provenance
#'
#' @param bucket (Required) Bucket to query
#' @param prefix (Required) Bucket prefix to query
#' @param DAG (Optional) Data access group(s) to query if you are part of multiple DAG's
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#'
#' @return A data frame containing metadata about files marked for deletion of data provenance. Requesting data from a specific prefix can speed up the request.
#' @export

get_deleted_files <- function(bucket = NULL, prefix = NULL, DAG=NULL, file_type = NULL) {
  check_credentials()
  if(any(sapply(list(bucket, prefix), is.null))) {stop("Please provide all required inputs.")}
  logic = paste0("[deleted_object] = '1' and [bucket_name] = '", bucket,"'")
  chatString = paste0("Retrieving data provenance for data in ", bucket,"...")
  if(is.null(prefix)==F){ logic = paste0(logic, " and [bucket_prefix] = '", prefix, "'")
                          chatString = paste0("Retrieving data provenance for data in ", bucket, ", and in prefix ", prefix, "...")}
  if(is.null(file_type)==F) { logic = paste0(logic, " and [file_type] = '", file_type,"'")
                          chatString = paste0("Retrieving data provenance for data in ", bucket, ", in prefix ", prefix,
                                              ", and with a file type of ", file_type, "...")}
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='object_prefix',
                   'fields[1]'='bucket_name',
                   'fields[2]'='bucket_prefix',
                   'fields[3]'='deleted_object',
                   'forms[0]'='data_provenance',
                   rawOrLabel='raw',
                   rawOrLabelHeaders='raw',
                   exportCheckboxLabel='false',
                   exportSurveyFields='false',
                   exportDataAccessGroups='true',
                   returnFormat='csv',
                   filterLogic=logic
  )
  message(chatString)
  results <- suppressMessages(httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")))
  message(paste0("Retrieved ", nrow(results), " records."))
  if(nrow(results)>0) {
    results <- results %>% dplyr::select(-dplyr::contains("_complete"))
    if (allowEmpty == F) {results <- results %>% dropWhen()}
    if (is.null(DAG)==F) {results <-  results[results$redcap_data_access_group %in% DAG,]}
  } else {results <- data.frame()}
  return(results)
}

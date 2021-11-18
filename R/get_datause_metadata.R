#' Find data use metadata about files in S3
#'
#' @param bucket (Required) Bucket to query
#' @param prefix (Optional) Bucket prefix to query
#' @param DAG (Optional) Data access group(s) to query if you are part of multiple DAG's
#' @param allowEmpty (Optional) Returns even empty columns if set to TRUE - use if you are interested in applying new annotations
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#'
#' @return A data frame containing data use information about files in S3. Requesting data from a specific prefix can speed up the request.
#' @export

get_datause_metadata <- function(bucket, prefix = NULL, DAG=NULL, allowEmpty = F, file_type = NULL) {
  check_credentials()
  logic = paste0("[bucket_name] = '", bucket,"'")
  chatString = paste0("Retrieving data use information for data in ", bucket,"...")
  if(is.null(prefix)==F){ logic = paste0(logic, " and [bucket_prefix] = '", prefix, "'")
  chatString = paste0("Retrieving data use information for data in ", bucket, ", and in prefix ", prefix, "...") }
  if(is.null(file_type)==F) { logic = paste0(logic, " and [file_type] = '", file_type,"'")
  chatString = paste0("Retrieving data use information for data in ", bucket, ", in prefix ", prefix,
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
                   'forms[0]'='tgr_data_use',
                   rawOrLabel='raw',
                   rawOrLabelHeaders='raw',
                   exportCheckboxLabel='false',
                   exportSurveyFields='false',
                   exportDataAccessGroups='true',
                   returnFormat='csv',
                   filterLogic=logic
  )
  message(chatString)
  results <- httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form"))
  message(paste0("Retrieved ", nrow(results), " records."))
  if(nrow(results)>0) {
    results <- results %>% dplyr::select(-dplyr::contains("_complete"))
    if (allowEmpty == F) {results <- results %>% dropWhen()}
    if (is.null(DAG)==F) {results <-  results[results$redcap_data_access_group %in% DAG,]}
  } else {results <- data.frame()}
  return(results)
}

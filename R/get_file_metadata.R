#' Find file metadata about files in S3
#'
#' @param bucket (Required) Bucket to query
#' @param prefix (Optional) Bucket prefix to query
#' @param DAG (Optional) Data access group(s) to query if you are part of multiple DAG's
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#'
#' @return A data frame containing metadata about files in S3. Requesting data from a specific prefix can speed up the request.
#' @export
get_file_metadata <- function(bucket, prefix = NULL, DAG=NULL, file_type = NULL) {
  check_credentials()
  logic = paste0("[bucket_name] = '", bucket,"'")
  if(is.null(prefix)==F){ logic = paste0(logic, " and [bucket_prefix] = '", prefix, "'") }
  if(is.null(file_type)==F) { logic = paste0(logic, " and [file_type] = '", file_type,"'") }
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='object_prefix',
                   'fields[1]'='bucket_name',
                   'fields[2]'='bucket_prefix',
                   'forms[0]'='s3_metadata',
                   rawOrLabel='raw',
                   rawOrLabelHeaders='raw',
                   exportCheckboxLabel='false',
                   exportSurveyFields='false',
                   exportDataAccessGroups='true',
                   returnFormat='csv',
                   filterLogic=logic)
  message(paste0("Retrieving data from ", bucket, " in prefix ", prefix, "..."))
  results <- suppressMessages(httr::content(
    httr::POST(url = Sys.getenv("REDURI"),
               body = formData, encode = "form", show_col_types = FALSE)))
  message(paste0("Retrieved ", nrow(results), " records."))
  if(nrow(results)>0) {
    results <- results %>% dplyr::select(-dplyr::contains("_complete")) %>% dropWhen()
    if (is.null(DAG)==F) {results <-  results[results$redcap_data_access_group %in% DAG,]}
  } else {results <- data.frame()}
  return(results)
}

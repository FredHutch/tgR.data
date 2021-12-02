#' Find user supplied data provenance information about files in S3
#'
#' @param bucket (Required) Bucket to query
#' @param uuid
#'  (Optional) UUID(s) to get data provenance for
#' @param prefix (Optional) Bucket prefix to query
#' @param DAG (Optional) Data access group to query if you are part of multiple DAGs
#' @param allowEmpty (Optional) Returns even empty columns if set to TRUE - use if you are interested in applying new annotations
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#'
#' @return A data frame containing metadata about files in S3. Requesting data from a specific prefix or other options can speed up the request.
#' @export

get_data_provenance <- function(bucket, uuid = NULL, prefix = NULL, DAG=NULL, allowEmpty = F, file_type = NULL) {
  check_credentials()
  if(is.null(bucket)) {stop("Please provide bucket name.")}
  logic = paste0("[bucket_name] = '", bucket,"'")
  chatString = paste0("Retrieving data provenance for data in ", bucket)
  if(is.null(uuid)==F){ logic = paste0(logic, " and ", paste0("[uuid] = '", paste(uuid, collapse = "' OR [uuid] = '"), "'"));
      chatString <- paste0(chatString, " and for specific UUIDs")}
  if(is.null(prefix)==F){ logic = paste0(logic, " and [bucket_prefix] = '", prefix, "'")
      chatString <- paste0(chatString, " and in the prefix ", prefix)}
  if(is.null(file_type)==F) { logic = paste0(logic, " and ",  paste0("[file_type] = '", paste(uuid, collapse = "' OR [file_type] = '"), "'"))
      chatString <- paste0(chatString, " and of the file types ", file_type)}
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='uuid',
                   'fields[1]'='object_prefix',
                   'fields[2]'='bucket_name',
                   'fields[3]'='bucket_prefix',
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

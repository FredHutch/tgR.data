#' Find file metadata about files in S3
#'
#' @param bucket (Required) Bucket to query
#' @param prefix (Optional) Bucket prefix to query
#' @param DAG (Optional) Data access group(s) to query if you are part of multiple DAG's
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#' @param includeDeleted (Optional) Defaults to FALSE.
#'
#' @return A data frame containing metadata about files in S3. Requesting data from a specific prefix can speed up the request.
#' @export
get_file_metadata <- function(bucket, prefix = NULL, DAG=NULL, file_type = NULL, includeDeleted = FALSE) {
  check_credentials()
  chatString <- "Retrieving "
  if (includeDeleted == FALSE) {
    logic = "[deleted_object] = '0' and ";
    chatString <- paste0(chatString, "data about files in bucket ")
    } else {chatString <- paste0(chatString, "data about all files (even deleted) in bucket ")}
  logic = paste0("[bucket_name] = '", bucket,"'")
  chatString <- paste0(chatString, bucket)
  if(is.null(prefix)==F){ logic = paste0(logic, " and [bucket_prefix] = '", prefix, "'");
  chatString <- paste0(chatString, " in prefix ", prefix)}
  if(is.null(file_type)==F) { logic = paste0(logic, " and [file_type] = '", file_type,"'");
  chatString <- paste0(chatString, " of file type ", file_type)}
  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   action='export',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   'fields[0]'='object_key',
                   'fields[1]'='bucket_name',
                   'fields[2]'='bucket_prefix',
                   'forms[0]'='s3_metadata',
                   exportDataAccessGroups='true',
                   filterLogic=logic)
  message(chatString)
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

#' Find user supplied data provenance information about files in S3
#'
#' @param bucket Bucket(s) to query
#' @param prefix Bucket prefix(es) to query
#' @param uuid uuid(s) to get data provenance for
#' @param DAG (Optional) Data access group to query if you are part of multiple DAGs
#' @param allowEmpty (Optional) Returns even empty columns if set to TRUE - use if you are interested in applying new annotations
#' @param file_type (Optional) Specific file type(s) to query for, such as "bamCramSam", "variants" or "tabularMatrix"
#'
#' @details At least one bucket and/or prefix is required.
#' @return A data frame containing metadata about files in S3. Requesting data from a specific prefix or other options can speed up the request.
#' @export

get_data_provenance <- function(bucket=NULL, prefix=NULL, uuid = NULL,
                                DAG=NULL, allowEmpty = F, file_type = NULL) {

  check_credentials()
    # if they didn't provide uuids, then they have to provide at least some bucket names or some prefixes and then if they provide file_types, filter for that too
  if(is.null(bucket) & is.null(prefix)) {stop("Please provide at least one bucket or bucket prefix name.")}
    if(is.null(bucket) == F & is.null(prefix) == T) {
      # if bucket only is provided
      logic = paste0("([bucket_name] = '", paste(unique(bucket), collapse = "' OR [bucket_name] = '"), "' )")
      chatString = paste0("Retrieving data provenance for data in the bucket(s) ", paste(unique(bucket), collapse = ", "))
    } else if(is.null(bucket) == T & is.null(prefix) == F){
      # if prefix only is provided
      logic = paste0("([bucket_prefix] = '", paste(unique(prefix), collapse = "' OR [bucket_prefix] = '"), "' )")
      chatString = paste0("Retrieving data provenance for data in the prefix(es) ", paste(unique(prefix), collapse = ", "))
    } else {
      logic = paste0(
        paste0("([bucket_prefix] = '", paste(unique(prefix), collapse = "' OR [bucket_prefix] = '"), "' )"),
        paste0(" AND ([bucket_name] = '", paste(unique(bucket), collapse = "' OR [bucket_name] = '"), "' )"))
      chatString = paste0("Retrieving data provenance for data in the bucket(s) ", paste(unique(bucket), collapse = ", "),
                          " and in the prefix(es) ", paste(unique(prefix), collapse = ", "))
    }
    if(is.null(file_type)==F) { logic = paste0(logic, " AND ",  paste0("( [file_type] = '", paste(unique(file_type), collapse = "' OR [file_type] = '"), "' )"))
    chatString <- paste0(chatString, " and of the file type(s) ", paste(unique(file_type), collapse = ", "))}
    # Now get data when not provided uuids
    formData <- list("token"=Sys.getenv("S3META"),
                     content='record', action='export',
                     format='csv', type='flat', csvDelimiter=',',
                     exportDataAccessGroups='true',
                     returnFormat='csv',
                     filterLogic=logic )
    message(chatString)
    results <- suppressMessages(httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")))

  if (is.null(uuid)==F){results <- results[results$uuid %in% uuid,]}
  if(nrow(results)>0) {
    results <- results %>% dplyr::select(-dplyr::contains("_complete"))
    if (allowEmpty == F) {results <- results %>% dropWhen()}
    if (is.null(DAG)==F) {results <-  results[results$redcap_data_access_group %in% DAG,]}
  } else {results <- data.frame()}
message(paste0("Retrieved ", nrow(results), " records."))
  return(results)
}

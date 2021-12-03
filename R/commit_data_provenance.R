#' Commits data provenance to REDCap about files in S3 with a unique id
#'
#' @param uuid (Required without bucket_name, object_prefix and DAG) Unique ID of the file in S3
#' @param bucket_name (Required without uuid) Bucket where the file is stored
#' @param object_prefix (Required without uuid) Prefix of the file in S3 (such as tg/projectA/file.csv)
#' @param DAG (Required without uuid) Data access group to assign this file to
#' @param data_provenance (Required) A named list of character objects that contains the data provenance to commit to REDCap about this file.
#'
#' @export
#'
commit_data_provenance <- function(uuid = NULL, bucket_name = NULL, object_prefix = NULL, DAG = NULL,
                                   data_provenance = NULL ) {
  check_credentials()
  if(is.null(uuid)==T) {
    if(any(sapply(formals(), is.null))) {stop("Please provide all required inputs.")}}

  # is the data provenance a list?
  if(is.list(data_provenance) == F) {stop("Please supply all data provenance information as a named list.")}
  # is it named?
  if(is.null(names(data_provenance)) == T) {stop("Data provenance list requires names.")}
  # are the names valid metadata right now?
  formData <- list("token"=Sys.getenv("S3META"),
                   content='exportFieldNames',
                   format='csv')
  message("Checking for validity of data provenance names.")
  fields <- suppressMessages(httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")))
  wrongfields <- names(data_provenance)[!names(data_provenance) %in% fields$original_field_name]
  if(length(wrongfields)>0) {stop(paste0("Data provenance list has these invalid names: ", paste(wrongfields, collapse = ", "), "."))}

  message("Committing data provenance. ")
  csv <- paste(paste0('\"', paste("uuid","bucket_name", "object_prefix","redcap_data_access_group",
                     paste(names(data_provenance), collapse = '\",\"'), sep = '\",\"')),
               paste0(paste(uuid, bucket_name, object_prefix, DAG,
                            paste(data_provenance, collapse = '\",\"'), sep = '\",\"'), '\"'), sep = '\"\n\"')

  formData <- list(token=Sys.getenv("S3META"),
                   content='record', format='csv', type='flat',
                   csvDelimiter=',', data=csv, returnFormat = 'csv',
                   returnContent= "ids")
  results <- httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")
  suppressMessages(idDF<-httr::content(results))
  if(results$status_code == "200") {message(paste0("Commit successful for uuid(s): ", paste(idDF$id, collapse = ", ")))} else
    {stop(paste0("Commit unsuccessful. Status code: ", results$status_code))}
}




#' Commits a batch of data provenance to REDCap about files in S3
#'
#' @param df Data frame of uuids and data provenance to commit for a batch of files
#' @param overwriteWithBlanks Default is FALSE and will not overwrite data if there are NAs or blanks in the data frame, however TRUE will overwrite.
#' @details Note:  NAs or blanks in the data frame will not overwrite existing data in this version.
#' @export
#'
commit_data_provenance_batch <- function(df = NULL, overwriteWithBlanks = FALSE) {
  check_credentials()
  if(is.null(df)==T) {stop("Please provide a data frame containing the data provenance for this batch.")}
  if(!"uuid" %in% colnames(df)){ stop("The data frame must include a column of valid uuids.")}

  message("Checking for validity of data provenance names.")
  formData <- list("token"=Sys.getenv("S3META"),
                   content='exportFieldNames',
                   format='csv')
  fields <- suppressMessages(httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")))
  givenFields <- colnames(subset(df, select = -redcap_data_access_group))
  wrongfields <- givenFields[!givenFields %in% fields$original_field_name]
  if(length(wrongfields)>0) {stop(paste0("Data provenance has these invalid names: ", paste(wrongfields, collapse = ", "), "."))}

  # Prep the data frame for writing as a csv
  con <-  base::textConnection(object  = "thiscsv", open = "w", local= TRUE)
  utils::write.csv(df, con, row.names = FALSE, na = "")
  close(con)
  csv <- paste(thiscsv, collapse = "\n")

  message("Committing data provenance. ")
  if (overwriteWithBlanks == F) {
  formData <- list(token=Sys.getenv("S3META"), content='record',
                   format='csv', type='flat', csvDelimiter=',',
                   data=csv, returnFormat = 'csv', returnContent= "ids")}
  if (overwriteWithBlanks == T) {
    formData <- list(token=Sys.getenv("S3META"), content='record',
                     format='csv', type='flat', csvDelimiter=',',
                     data=csv, returnFormat = 'csv', returnContent= "ids",
                     overwriteBehavior = 'overwrite')}
  results <- httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")
  suppressMessages(idDF<-httr::content(results))
  if(results$status_code == "200") {message(paste0("Commit successful for id(s): ", paste(idDF$id, collapse = ", ")))} else
  {stop(paste0("Commit unsuccessful. Status code: ", results$status_code))}
}





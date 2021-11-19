#' Tags files in S3 with a unique id, then commits data provenance to REDCap
#'
#' @param bucket_name (Required) Bucket where the file is stored
#' @param object_prefix (Required) Prefix of the file in S3 (such as tg/projectA/file.csv)
#' @param DAG (Required) Data access group to assign this file to
#' @param data_provenance (Required) A named list of character objects that contains the data provenance to commit to REDCap about this file.
#'
#' @export
#'
tag_and_commit_data_provenance <- function(bucket_name = NULL, object_prefix = NULL, DAG = NULL,
                                   data_provenance = NULL ) {
  check_credentials()
  if(any(sapply(formals(), is.null))) {stop("Please provide all required inputs.")}
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

  message("Tagging file in S3.")
  newuuid <- uuid::UUIDgenerate()
  paws.storage::s3()$put_object_tagging(
    Bucket = bucket_name,
    Key = object_prefix,
    Tagging = list(
      TagSet = list(list(Key = "uuid",Value = newuuid))))

  message("Committing data provenance. ")
  csv <- paste(paste("bucket_name", "object_prefix","redcap_data_access_group", "uuid", names(data_provenance), sep = ","),
               paste(bucket_name, object_prefix, DAG, newuuid, data_provenance, sep = ","), collapse = "\n")

  formData <- list("token"=Sys.getenv("S3META"),
                   content='record',
                   format='csv',
                   type='flat',
                   csvDelimiter=',',
                   data=csv)
  message(chatString)
  results <- httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")
  if(results$status_code == "200") {message("Commit successful.")} else
    {stop(paste0("Commit unsuccessful. Status code: ", results$status_code))}
}

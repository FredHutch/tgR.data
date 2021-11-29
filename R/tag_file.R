#' Tags new files in S3 with a unique id
#'
#' @param bucket_name (Required) Bucket where the file is stored
#' @param object_prefix (Required) Prefix of the file in S3 (such as tg/projectA/file.csv)
#' @return Returns uuid of the object tagged.
#' @export
#'
tag_file <- function(bucket_name = NULL, object_prefix = NULL) {
  if(any(sapply(formals(), is.null))) {stop("Please provide all required inputs.")}
  check_credentials()
  message("Tagging file in S3.")
  newuuid <- uuid::UUIDgenerate()
  results <- paws.storage::s3()$put_object_tagging(
    Bucket = bucket_name,
    Key = object_prefix,
    Tagging = list(
      TagSet = list(list(Key = "uuid",Value = newuuid))))
  message(paste0("Tagged file with version id: ", results$VersionId))
  return(newuuid)
}

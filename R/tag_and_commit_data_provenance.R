#' Commits data provenance to REDCap about files in S3 with a unique id
#'
#' @param uuid (Required) Unique ID of the file in S3
#' @param bucket_name (Required) Bucket where the file is stored
#' @param object_prefix (Required) Prefix of the file in S3 (such as tg/projectA/file.csv)
#' @param DAG (Required) Data access group to assign this file to
#' @param data_provenance (Required) A named list of character objects that contains the data provenance to commit to REDCap about this file.
#'
#' @export
#'
tag_and_commit_data_provenance <- function(uuid = NULL, bucket_name = NULL, object_prefix = NULL, DAG = NULL,
                                   data_provenance = NULL ) {
  check_credentials()
  uuid <- tag_file(bucket_name = bucket_name, object_prefix = object_prefix)
  commit_data_provenance(uuid = uuid, bucket_name = bucket_name, object_prefix = object_prefix,
                         DAG = DAG, data_provenance = data_provenance)
}



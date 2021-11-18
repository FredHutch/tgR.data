#' Queries for dataset annotations
#'
#' @param harmonizedOnly (Optional) Whether you want only the annotations that are harmonized across all projects (TRUE) or a complete data set (FALSE, default).
#' @param evenEmptyCols (Optional) Whether you want even the empty fields in your final data frame (TRUE) or if you just want columns where there is at least one value in the resulting dataset (FALSE, default).
#' @param DAG (Optional) A character vector containing the name(s) of the TGR data access group(s) for which to request data if you belong to multiple.
#' @return Returns a data frame of annotations.
#' @author Amy Paguirigan
#' @export
get_dataset_annotations <- function(DAG = NULL, harmonizedOnly = FALSE, evenEmptyCols = FALSE) {
  check_credentials()

  tgrData <- suppressMessages(
    REDCapR::redcap_read_oneshot(
      Sys.getenv("REDURI"), Sys.getenv("TGR"),
      export_data_access_groups = T, guess_type = F)$data %>%
      dplyr::select(-dplyr::ends_with("_complete")))

  if (harmonizedOnly == TRUE) {
    harmfields <- suppressMessages(
      REDCapR::redcap_metadata_read(Sys.getenv("REDURI"), Sys.getenv("TGR"))$data)
    Keep <- harmfields %>% dplyr::filter(grepl("tgr_*", form_name)==T) %>% dplyr::select(field_name)
    tgrData <- tgrData %>% dplyr::select(dplyr::one_of("molecular_id", "redcap_data_access_group", Keep$field_name))
  }
  tgrData[tgrData == ""] <- NA
  if (is.null(DAG) == T ) {message("Returning all data you have access to.")
  } else {
    if (DAG %in% tgrData$redcap_data_access_group){
        tgrData <- tgrData %>% dplyr::filter(redcap_data_access_group %in% DAG)
        message(paste0("DAGs returned: ", paste(unique(tgrData$redcap_data_access_group), collapse = ", ")))
      } else {stop("Invalid DAG or you do not have permissions to that DAG.")}
    }
  if (evenEmptyCols == F) {
    tgrData <- tgrData %>%
      Filter(function(x)!all(is.na(x)), .) %>%
      Filter(function(x)!all(x==0), .)
  }
  return(tgrData)
}



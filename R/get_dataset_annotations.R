#' Queries for dataset annotations
#'
#' @param harmonizedOnly (Optional) Whether you want only the annotations that are harmonized across all projects (TRUE) or a complete data set (FALSE, default).
#' @param dataset_ids (Optional) If you want annotations for specific dataset_ids.
#' @param evenEmptyCols (Optional) Whether you want even the empty fields in your final data frame (TRUE) or if you just want columns where there is at least one value in the resulting dataset (FALSE, default).
#' @param DAG (Optional) A character vector containing the name(s) of the TGR data access group(s) for which to request data if you belong to multiple.
#' @return Returns a data frame of annotations.
#' @author Amy Paguirigan
#' @export
get_dataset_annotations <- function(harmonizedOnly = FALSE, dataset_ids = NULL, evenEmptyCols = FALSE, DAG = NULL) {
  check_annot_credentials()
  formData <- list("token"=Sys.getenv("TGR"),
                   content='record', action='export',
                   format='csv', type='flat',
                   exportDataAccessGroups='true',
                   returnFormat='csv')
  if (is.null(dataset_ids)==F) {formData <- c(formData, records=paste0(dataset_ids, collapse = ","))}
  results <- httr::content(a<- httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form"),
                             guess_max = 5000, show_col_types = FALSE) %>% dplyr::select(-dplyr::ends_with("_complete"))

  if (harmonizedOnly == TRUE) {
    formData <- list("token"=Sys.getenv("TGR"),
                     content='metadata',
                     format='csv')
    meta <- suppressMessages(httr::content(httr::POST(url = Sys.getenv("REDURI"), body = formData, encode = "form")))
    Keep <- meta %>% dplyr::filter(grepl("tgr_*", form_name)==T) %>% dplyr::select(field_name)
    tgrData <- results %>% dplyr::select(dplyr::one_of("molecular_id", "redcap_data_access_group", Keep$field_name))
  }

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



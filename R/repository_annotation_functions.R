#' (Admin) Finds undefined REDCap variables
#'
#' Pulls sample data down from REDCap and compares them with the defined annotation list in GitHub and identifies variables in REDCap that need defining in GitHub.  Only variables for which there is a value in at least one record are returned.
#'
#' @return A data frame that is a template to add to the commonKnowledge data in the tgr-annotations repo with new definitions or corrections.
#' @author Amy Paguirigan
#' @noRd
#' Requires **admin** REDCap credentials to be set in the environment.
tgr_undefined_annotations <- function() {
  suppressMessages(check_annot_credentials())
  # Get current definitions
  commonKnowledge <- tgr_definitions()
  # Get currently used annotations
  sciMeta <- get_dataset_annotations(harmonizedOnly = F, evenEmptyCols = T)
  # Remove project memberships
  defineMe <- sciMeta %>% dplyr::select(-dplyr::starts_with("data_is_"))
  # Divide up into categorical annotations and non-categorial so they can be defined differently
  categorical <- commonKnowledge %>% dplyr::filter(Type == "categorical")
  noLevelAnnots <- commonKnowledge %>% dplyr::filter(Type != "categorical")

  # Find all values used in the project, and find their associated Annotation
  usedAnnots <- purrr::map_dfr(colnames(defineMe), function(i){
    Y <- unique(dplyr::select(defineMe, tidyselect::all_of(i)))
    colnames(Y) <- "Value"
    Y$Value <- as.character(Y$Value)
    Y$Annotation <- i
    Y
  })
  # find used categorical variables
  usedCat <- usedAnnots %>% dplyr::filter(Annotation %in% categorical$Annotation & is.na(Value) !=T )
  # determine if any are missing annotation or value definitions
  missingCat <- dplyr::anti_join(usedCat, categorical)
  missingCat <- dplyr::left_join(missingCat, commonKnowledge) %>% dplyr::mutate(ValueDescription = "")
  usedOther <- usedAnnots %>% dplyr::filter(!Annotation %in% categorical$Annotation) %>% dplyr::select(Annotation) %>% unique()
  missingOther <- dplyr::left_join(usedOther, commonKnowledge) %>% dplyr::filter(is.na(AnnotationDescription) == T) %>% dplyr::select(Annotation)
  missingOther <- dplyr::left_join(missingOther, commonKnowledge) %>% dplyr::mutate(Value = "", ValueDescription = "")

  # Just output the unique annotations/values that need definitions.
  makeMeaning <- unique(rbind(missingCat, missingOther))

  return(makeMeaning)
}



#' Pull Current TGR Annotation and Value definitions
#'
#' @description Pulls current data about annotations from GitHub for use in annotating molecular data sets in the Repository.
#' @return A data frame containing the current TGR Annotations, Values and their Definitions
#' @author Amy Paguirigan
#' @export
tgr_definitions <- function() {
  suppressMessages(annotations <- jsonlite::fromJSON(httr::content(httr::GET("https://raw.github.com/FredHutch/tgr-annotations/main/annotations.json"),
                                                                   as = "parsed")))
  suppressMessages(values <- jsonlite::fromJSON(httr::content(httr::GET("https://raw.github.com/FredHutch/tgr-annotations/main/values.json"),
                                                              as = "parsed")))
  commonKnowledge <- suppressMessage(dplyr::full_join(annotations, values) %>% dplyr::arrange(Category, Annotation, Value))

  return(commonKnowledge)
}




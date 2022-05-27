# tgR.data

This package currently is wrapping a pile of functions commonly in use to interact with and manage the Fred Hutch Genomics Repository data annotation databases.    

## Installation

You will need the following packages installed as well:
```{r}
install.packages(pkgs = c("httr", "REDCapR", "aws.s3", "jsonlite", "magrittr", "dplyr", "purrr", "RCurl", "checkmate", "stringr"))
```

You can install the most recent version of `tgR.data` by:

```r
require(remotes)
remotes::install_github('FredHutch/tgR.data')
```

Install a specific release version (in this case v0.0.4 ) by:
```r
require(remotes)
remotes::install_github('FredHutch/tgR.data@v0.0.4')
```

## Credentials
To use this package, you must have access to the TGR REDCap projects (both TGR Dataset Annotations and TGR S3 Metadata), and have generated an API token for each (by logging into https://redcap.fredhutch.org/, going to the sidebar on the left, and choosing "API").  

These tokens must be saved in a local file much like [this template file](https://github.com/FredHutch/tgR.data/blob/main/requiredCredentials.R).  

If you have the permissions to tag files in S3 with uuid's from the Repository, you will also need your AWS credentials in that same file as noted.  


## Docker
I have provided a dockerfile and a built container at `vortexing/r_tgr.data:v0.0.4` (or whatever is currently specified in the dockerfile in this repo) for use in workflows. 

## WDL
There is a WDL subworkflow in this repo that can be used in the context of another WDL workflow to directly copy the desired outputs from a scientific workflow to the appropriate S3 archiving location, tag the file with a TGR uuid and then commit the workflow-related data provenance to REDCap for posterity.  By incorporating this WDL workflow into your scientific workflows you can select, archive, and automagically retain the data provenance for files of interest that arise from your computational work.  This reduces the long term burden of annotation of datasets in S3.  

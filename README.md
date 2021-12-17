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

Install a specific release version (in this case 0.0.1) by:
```r
require(remotes)
remotes::install_github('FredHutch/tgR.data@0.0.1')
```

## Credentials
To use this package, you must have access to the TGR REDCap projects (both TGR Dataset Annotations and TGR S3 Metadata), and have generated an API token for each (by logging into https://redcap.fredhutch.org/, going to the sidebar on the left, and choosing "API").  

These tokens must be saved in a local file much like [this template file](https://github.com/FredHutch/tgR.data/blob/main/requiredCredentials.R).  

If you have the permissions to tag files in S3 with uuid's from the Repository, you will also need your AWS credentials in that same file as noted.  

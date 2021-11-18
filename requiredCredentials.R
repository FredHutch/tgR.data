# You will need an API token from REDCap for two different projects to fully use this package
## This is the API token for your user to the S3 metadata project
Sys.setenv(S3META="yourS3MetadataREDCapAPItokenhere")
## This is the API token for your user to the TGR Unified project
Sys.setenv(TGR="yourTGRREDCapAPItokenhere")
## These are your AWS credentials provided by IT
Sys.setenv(AWS_ACCESS_KEY_ID="yours3accesskeyhere")
Sys.setenv(AWS_SECRET_ACCESS_KEY="yours3secretaccesskeyhere")
Sys.setenv(AWS_REGION = "us-west-2")


## WDL task for copying a file to S3, tagging it, and then committing the data provenance to the Repository
## You'll need to save an appropriate credentials file in an accessible directory to use this in a workflow
version 1.0
workflow sync_tgR_DataProvenance {
  input {
    String dirToSync
    String destinationPrefix
    String destinationBucket
    String DAG
    String credentialsPath
    String? genomeVersion
    String? stage
  }
  String rDocker = "vortexing/r_tgr.data:v0.0.4"
  String awscliModule = "awscli/1.18.35-foss-2019b-Python-3.7.4"

  call syncDirectory {
    input:
      dirToSync = dirToSync,
      destinationPrefix = destinationPrefix,
      destinationBucket = destinationBucket,
      taskModules = awscliModule
  }

  call tagAndCommit {
    input:
      s3fullPrefix = copyFile.s3fullPrefix,
      bucket = destinationBucket,
      DAG = DAG,
      credentialsPath = credentialsPath,
      workflowName = copyFile.workflowName,
      workflowID = copyFile.workflowID,
      workflowTask = copyFile.workflowTask,
      genomeVersion = genomeVersion,
      stage = stage,
      taskDocker = rDocker
  }
}

task syncDirectory {
  input {
    String dirToSync
    String destinationPrefix
    String destinationBucket
    String taskModules
  }
  command <<<
    set -eo pipefail

    aws s3 sync ~{dirToSync} s3://~{destinationBucket}/$s3fullPrefix --only-show-errors --acl bucket-owner-full-control

  >>>
  runtime {
    cpu: 4
    modules: taskModules
  }
  output {

  }
}

task tagAndCommit {
  input {
    String s3fullPrefix
    String bucket
    String DAG
    String credentialsPath
    String workflowName
    String workflowID
    String workflowTask
    String? genomeVersion
    String? stage
    String taskDocker
  }
  
  command <<<
    set -eo pipefail

    Rscript -e "library(tgr.data); set_credentials(~{credentialsPath}); \
      tag_and_commit_data_provenance(bucket_name = ~{bucket}, object_prefix = ~{s3fullPrefix}, DAG = ~{DAG}, \
        data_provenance = list('workflow_name' = ~{workflowName}, 'workflow_id' = ~{workflowID}, 'workflow_task_name' = ~{workflowTask}) \
        ~{', stage=' + stage + ','} ~{'genome_version=' + genomeVersion}))"

  >>>
  output {
  }
  runtime {
    docker: taskDocker
    cpu: 1
  }
}
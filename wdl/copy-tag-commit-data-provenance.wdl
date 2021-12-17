## WDL task for copying a file to S3, tagging it, and then committing the data provenance to the Repository
## You'll need to save an appropriate credentials file in an accessible directory to use this in a workflow
version 1.0
workflow copyTagCommitDataProvenance {
  input {
    File filetocopy
    String destinationPrefix
    String destinationBucket
    String DAG
    String credentialsPath
    String? genomeVersion
    String? stage
  }
  String rDocker = "vortexing/r_tgr.data:v0.0.3"
  String awscliModule = "awscli/1.18.35-foss-2019b-Python-3.7.4"

  call copyFile {
    input:
      filetocopy = filetocopy,
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

task copyFile {
  input {
    File filetocopy
    String destinationPrefix
    String destinationBucket
    String taskModules
  }
  command <<<
    set -eo pipefail

    localpath=$(echo ~{filetocopy} | awk -Fcromwell-executions '{print $2}')
    IFS="/" read -ra chunks <<< "$localpath"
    workflowName=${chunks[1]}
    workflowID=${chunks[2]}
    workflowTask=${chunks[3]#"call-"}

    # Adjust the path you want to put files into here. 
    s3fullPrefix="~{destinationPrefix}/$workflowName/$workflowID/$workflowTask/${chunks[-1]}" 

    echo "Copy the file to S3---------------------------------------"
    aws s3 cp ~{filetocopy} s3://~{destinationBucket}/$s3fullPrefix --only-show-errors --acl bucket-owner-full-control

    echo $s3fullPrefix > s3fullPrefix.txt
    echo $workflowName > workflowName.txt
    echo $workflowID > workflowID.txt
    echo $workflowTask > workflowTask.txt
  >>>
  runtime {
    cpu: 4
    modules: taskModules
  }
  output {
    String s3fullPrefix = read_string("s3fullPrefix.txt")
    String workflowName = read_string("workflowName.txt")
    String workflowID = read_string("workflowID.txt")
    String workflowTask = read_string("workflowTask.txt")
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
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${ terraform_ci_role_arn }" 
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }%{~ if artifact_bucket_arn != "" },
    {
      "Effect": "Allow",
      "Resource": [
        "${ artifact_bucket_arn }",
        "${ artifact_bucket_arn }/*"
      ],
      "Action": [
        "s3:ListBucket",
        "s3:*Object"
      ]
    }%{ endif }
  ]
}


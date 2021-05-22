{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "codebuild:StartBuild",
            "codebuild:StopBuild",
            "codebuild:BatchGetBuilds"
        ],
        "Resource": [
            "${ plan_arn }",
            "${ apply_arn }",
            "${ test_arn }"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "events:PutTargets",
            "events:PutRule",
            "events:DescribeRule"
        ],
        "Resource": [
            "${ sfn_event_role_arn}"
        ]
    }
  ]
}

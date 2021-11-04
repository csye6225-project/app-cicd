resource "aws_iam_policy" "cd_ec2_s3_policy" {
  name        = "CodeDeploy-EC2-S3"
  description = "CodeDeploy-EC2-S3 Policy for the Server (EC2)"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : ["s3:Get*", "s3:List*"],
        "Effect" : "Allow",
        "Resource" : ["${var.s3_bucket_arn}", "${var.s3_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_policy" "gh_upto_s3_policy" {
  name        = "GH-Upload-To-S3"
  description = "GH-Upload-To-S3 Policy for GitHub Actions to Upload to AWS S3"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:PutObject", "s3:Get*", "s3:List*"],
        "Resource" : ["${var.s3_bucket_arn}", "${var.s3_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_policy" "gh_cd_dp_policy" {
  name        = "GH-Code-Deploy"
  description = "GH-Code-Deploy Policy for GitHub Actions to Call CodeDeploy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["codedeploy:RegisterApplicationRevision", "codedeploy:GetApplicationRevision"],
        "Resource" : ["arn:aws:codedeploy:${var.region}:${var.account_id}:application:csye6225-webapp"]
        }, {
        "Effect" : "Allow",
        "Action" : ["codedeploy:CreateDeployment", "codedeploy:GetDeployment"],
        "Resource" : ["*"]
        }, {
        "Effect" : "Allow",
        "Action" : ["codedeploy:GetDeploymentConfig"],
        "Resource" : ["arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime", "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime", "arn:aws:codedeploy:${var.region}:${var.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "cdes_role" {
  name                = "CodeDeployEC2ServiceRole"
  managed_policy_arns = [aws_iam_policy.cd_ec2_s3_policy.arn]
  force_detach_policies = true
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "cds_role" {
  name = "CodeDeployServiceRole"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "gh-upto-s3-attach" {
  name       = "gh-upload-to-s3-attachment"
  users      = [var.aws_iam_username]
  policy_arn = aws_iam_policy.gh_upto_s3_policy.arn
}

resource "aws_iam_policy_attachment" "gh-cd-dp-attach" {
  name       = "gh-code-deploy-attachment"
  users      = [var.aws_iam_username]
  policy_arn = aws_iam_policy.gh_cd_dp_policy.arn
}


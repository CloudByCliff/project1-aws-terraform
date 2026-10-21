
# ==========================================
# PROJECT 1 - S3 APPLICATION DEPLOYMENT
# Allow EC2 to download application packages
# ==========================================

resource "aws_iam_role_policy" "read_app_artifacts" {
  name = "${var.project_name}-read-app-artifacts"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DownloadProject1Application"
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.app_artifacts.arn}/releases/*"
        ]
      }
    ]
  })
}

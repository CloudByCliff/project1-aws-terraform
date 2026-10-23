
# ==============================================
# PROJECT 1 - CLOUDWATCH MONITORING AND ALERTS
# ==============================================

variable "alert_email" {
  description = "Email destination for AWS monitoring alerts"
  type        = string
  sensitive   = true
}

# 1. Shared email notification channel

resource "aws_sns_topic" "project1_alerts" {
  name = "${var.project_name}-ops-alerts"

  tags = {
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.project1_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 2. Correct SNS topic access policy

data "aws_iam_policy_document" "alerts_policy" {

  # Allow this AWS account to manage its topic
  statement {
    sid    = "AllowAccountManagement"
    effect = "Allow"

    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.project1_alerts.arn
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }

  # Allow CloudWatch alarms from Project 1
  # to send notification messages
  statement {
    sid     = "AllowCloudWatchPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]

    resources = [
      aws_sns_topic.project1_alerts.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:${var.project_name}-*"
      ]
    }
  }
}

resource "aws_sns_topic_policy" "project1_alerts" {
  arn    = aws_sns_topic.project1_alerts.arn
  policy = data.aws_iam_policy_document.alerts_policy.json
}

# 3. Monitor healthy application servers

resource "aws_cloudwatch_metric_alarm" "healthy_servers" {
  alarm_name          = "${var.project_name}-healthy-servers-low"
  alarm_description   = "Fewer than 2 healthy application targets"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "LessThanThreshold"
  threshold           = 2
  treat_missing_data  = "missing"

  dimensions = {
    LoadBalancer = aws_lb.project1.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.project1_alerts.arn]
  ok_actions    = [aws_sns_topic.project1_alerts.arn]
}

# 4. Monitor application server errors

resource "aws_cloudwatch_metric_alarm" "app_errors" {
  alarm_name          = "${var.project_name}-application-5xx-errors"
  alarm_description   = "More than 5 application server errors in 5 minutes"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.project1.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.project1_alerts.arn]
  ok_actions    = [aws_sns_topic.project1_alerts.arn]
}

# 5. Monitor database CPU usage

resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name          = "${var.project_name}-database-high-cpu"
  alarm_description   = "RDS CPU usage exceeds 80 percent"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80
  treat_missing_data  = "missing"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  alarm_actions = [aws_sns_topic.project1_alerts.arn]
  ok_actions    = [aws_sns_topic.project1_alerts.arn]
}

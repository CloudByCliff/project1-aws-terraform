
# ============================================
# AWS PROJECT 1 - ACCOUNT-WIDE BILLING ALERTS
# Monthly budget: $25 USD
# ============================================

# This budget covers the entire AWS account.
# No service or region filters are applied.

resource "aws_budgets_budget" "monthly_account_cost" {
  name         = "${var.project_name}-monthly-account-budget"
  budget_type  = "COST"
  limit_amount = "25"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # ALERT 1: Actual spending exceeds 80%
  # $20 out of the $25 monthly budget.

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # ALERT 2: Actual spending exceeds 100%
  # $25 monthly budget threshold.

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  # ALERT 3: Forecast monthly spending
  # is expected to exceed $25.

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Project = var.project_name
    Purpose = "CostMonitoring"
  }
}

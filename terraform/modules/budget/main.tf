resource "aws_budgets_budget" "main" {
  name              = "cloudzenia-budget"
  budget_type       = "COST"
  limit_amount      = "50.0"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2025-04-01_00:00"
  time_period_end   = "2030-12-31_23:59"

  notification {
    notification_type          = "ACTUAL"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = ["nagacharan4286@gmail.com"]
  }
}

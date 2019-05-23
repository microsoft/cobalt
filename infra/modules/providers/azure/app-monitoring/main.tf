resource "azurerm_monitor_action_group" "appmonitoring" {
  name                = "${var.action_group_name}"
  resource_group_name = "${var.resource_group_name}"
  short_name          = "${var.action_group_short_name}"

  email_receiver {
    name        = "${var.action_group_email_receiver_name}"
    email_address = "${var.action_group_email_receiver}"
  }
}

resource "azurerm_monitor_metric_alert" "appmonitoring" {
  name                = "${var.metric_alert_name}"
  resource_group_name = "${azurerm_monitor_action_group.appmonitoring.resource_group_name}"
  scopes              = ["${var.resource_ids}"]

  criteria {
    metric_namespace = "${var.metric_alert_criteria_namespace}"
    metric_name      = "${var.metric_alert_criteria_name}"
    aggregation      = "${var.metric_alert_criteria_aggregation}"
    operator         = "${var.metric_alert_criteria_operator}"
    threshold        = "${var.metric_alert_criteria_threshold}"

    dimension {
      name     = "Instance"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.appmonitoring.id}"
  }
}

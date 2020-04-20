//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

data "azurerm_resource_group" "svcplan" {
  name = var.resource_group_name
}

resource "azurerm_app_service_plan" "svcplan" {
  name                       = var.service_plan_name
  location                   = data.azurerm_resource_group.svcplan.location
  resource_group_name        = var.resource_group_name
  kind                       = var.service_plan_kind
  tags                       = var.resource_tags
  reserved                   = var.service_plan_kind == "Linux" ? true : var.service_plan_reserved
  app_service_environment_id = var.app_service_environment_id

  sku {
    tier     = var.service_plan_tier
    size     = var.service_plan_size
    capacity = var.service_plan_capacity
  }
}

resource "azurerm_monitor_autoscale_setting" "app_service_auto_scale" {
  name                = "${var.service_plan_name}-autoscale"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.svcplan.location
  target_resource_id  = azurerm_app_service_plan.svcplan.id

  profile {
    name = "Scaling Profile"

    capacity {
      default = 1
      minimum = var.autoscale_capacity_minimum
      maximum = azurerm_app_service_plan.svcplan.maximum_number_of_workers
    }

    dynamic "rule" {
      for_each = var.scaling_rules
      content {
        scale_action {
          direction = rule.value.scale_action.direction
          type      = rule.value.scale_action.type
          value     = rule.value.scale_action.value
          cooldown  = rule.value.scale_action.cooldown
        }
        metric_trigger {
          metric_resource_id = azurerm_app_service_plan.svcplan.id
          metric_name        = rule.value.metric_trigger.metric_name
          time_grain         = rule.value.metric_trigger.time_grain
          statistic          = rule.value.metric_trigger.statistic
          time_window        = rule.value.metric_trigger.time_window
          time_aggregation   = rule.value.metric_trigger.time_aggregation
          operator           = rule.value.metric_trigger.operator
          threshold          = rule.value.metric_trigger.threshold
        }
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}


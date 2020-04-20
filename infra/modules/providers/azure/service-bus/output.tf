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

output "namespace_name" {
  description = "The namespace name."
  value       = azurerm_servicebus_namespace.servicebus.name
}

output "resource_group" {
  description = "The resource group name of the Service Bus namespace."
  value       = data.azurerm_resource_group.resourcegroup.name
}

output "namespace_id" {
  description = "The namespace ID."
  value       = azurerm_servicebus_namespace.servicebus.id
}

output "namespace_authorization_rules" {
  description = "List of namespace authorization rules."
  value = {
    for auth in azurerm_servicebus_namespace_authorization_rule.sbnamespaceauth :
    auth.name => {
      listen = auth.listen
      send   = auth.send
      manage = auth.manage
    }
  }
}

output "service_bus_namespace_default_primary_key" {
  description = "The primary access key for the authorization rule RootManageSharedAccessKey which is created automatically by Azure."
  value       = azurerm_servicebus_namespace.servicebus.default_primary_key
}

output "service_bus_namespace_default_connection_string" {
  description = "The primary connection string for the authorization rule RootManageSharedAccessKey which is created automatically by Azure."
  value       = azurerm_servicebus_namespace.servicebus.default_primary_connection_string
}


output "topics" {
  value = {
    for topic in azurerm_servicebus_topic.sptopic :
    topic.name => {
      id   = topic.id
      name = topic.name
      authorization_rules = {
        for auth in azurerm_servicebus_topic_authorization_rule.topicaauth :
        auth.name => {
          listen = auth.listen
          send   = auth.send
          manage = auth.manage
        } if topic.name == auth.topic_name
      }
      subscriptions = {
        for subscription in azurerm_servicebus_subscription.subscription :
        subscription.name => {
          name = subscription.name
        } if topic.name == subscription.topic_name
      }
    }
  }
  description = "All topics with the corresponding subscriptions"
}
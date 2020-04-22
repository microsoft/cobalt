# Service Bus

This Terrafom based service-bus module grants templates the ability to create service bus main functionality and Advanced features as well.

## _More on Service Bus_

Microsoft Azure Service Bus is a fully managed enterprise integration message broker. Service Bus can decouple applications and services.

Data is transferred between different applications and services using messages. A message is in binary format and can contain JSON, XML, or just text.

### namespaces

A namespace is a container for all messaging components. Multiple queues and topics can be in a single namespace, and namespaces often serve as application containers.

### Topics

You can also use topics to send and receive messages. While a queue is often used for point-to-point communication, topics are useful in publish/subscribe scenarios.

Topics can have multiple, independent subscriptions. A subscriber to a topic can receive a copy of each message sent to that topic. Subscriptions are named entities. Subscriptions persist, but can expire or autodelete.

For more information, Please check Azure Service Bus [documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview).

## Characteristics

An instance of the `service-bus` module deploys the _**Service Bus**_ in order to provide templates with the following:

- Ability to provision a single Service Bus namespace
- Ability to provision a configurable list of topic(s) and corresponding subscription(s)
- Ability to configure message TTLs
- Ability to enable dead lettering
- Ability to allow subscription sessions to guarantee ordered message processing
- Ability to allow message topic forwarding
- Ability to support azure resource tags

## Out Of Scope

The following are not support in the time being

- Terraform support for Service Bus vnet integration is not available [https://github.com/terraform-providers/terraform-provider-azurerm/issues/3930](https://github.com/terraform-providers/terraform-provider-azurerm/issues/3930). However, this still can be implemented in other ways.'
- MI can be integrated with service bus using Terraform. However, MSI is not available in Germany and China 21Vianet yet.

## Definition

Terraform resources used to define the `service-bus` module include the following:

- [azurerm_servicebus_namespace](https://www.terraform.io/docs/providers/azurerm/r/servicebus_namespace.html)
- [azurerm_servicebus_namespace_authorization_rule](https://www.terraform.io/docs/providers/azurerm/r/servicebus_namespace_authorization_rule.html)
- [azurerm_servicebus_topic](https://www.terraform.io/docs/providers/azurerm/r/servicebus_topic.html)
- [azurerm_servicebus_subscription](https://www.terraform.io/docs/providers/azurerm/r/servicebus_subscription.html)
- [azurerm_servicebus_subscription_rule](https://www.terraform.io/docs/providers/azurerm/r/servicebus_subscription_rule.html)

## Usage

Service Bus usage example:

```terraform
module "service_bus" {
  source              = "../../modules/providers/azure/service-bus"
  namespace_name      = "sb-namespace"
  resource_group_name = "rg"
  sku                 = "Standard"
  tags                = { source = "terraform" }
  namespace_authorization_rules = [
    {
      policy_name = "rules"
      claims = {
        listen = true
        send   = true
        manage = false
      }
    }
  ]
  topics = [
    {
      name                       = "topic_test"
      default_message_ttl        = "PT30M" //ISO 8601 format
      enable_partitioning        = true
      requires_duplicate_detection = true
      support_ordering           = true
      authorization_rules = [
        {
          policy_name = "policy"
          claims = {
            listen = true
            send   = true
            manage = false
          }
        }
      ]
      subscriptions = [
        {
          name                                 = "sub_test"
          max_delivery_count                   = 1
          lock_duration                        = "PT5M" //ISO 8601 format
          forward_to                           = ""     //set with the topic name that will be used for forwarding. Otherwise, set to ""
          dead_lettering_on_message_expiration = true
          filter_type                          = "SqlFilter"     // SqlFilter is the only supported type now.
          sql_filter                           = "color = 'red'" //Required when filter_type is set to SqlFilter
          action                               = ""
        }
      ]
    }
  ]
}
```

## Outputs

The value will have the following schema:

```terraform
output "namespace_name" {
  value       = azurerm_servicebus_namespace.servicebus.name
  description = "The namespace name."
}

output "resource_group" {
  value = data.azurerm_resource_group.resourcegroup.name
}

output "namespace_id" {
  value       = azurerm_servicebus_namespace.servicebus.id
  description = "The namespace ID."
}

output "namespace_authorization_rules"{
  value       = {
    for auth in azurerm_servicebus_namespace_authorization_rule.sbnamespaceauth :
    auth.name => {
      listen = auth.listen
      send   = auth.send
      manage = auth.manage
    } 
  }
  description = "List of namespace authorization rules."
}

output "service_bus_namespace_default_primary_key" {
  value = azurerm_servicebus_namespace.servicebus.default_primary_key
  description = "The primary access key for the authorization rule RootManageSharedAccessKey."
}

output "service_bus_namespace_default_connection_string" {
  value = azurerm_servicebus_namespace.servicebus.default_primary_connection_string
  description = "The primary connection string for the authorization rule RootManageSharedAccessKey which is created automatically by Azure."
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
        } if  topic.name == auth.topic_name
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

```

## Argument Reference

Supported arguments for this module are available in [variables.tf](variables.tf)

## Attributes Reference

- `name`                          : The namespace name.
- `id`                            : The namespace ID.
- `namespace_authorization_rules` : The authorization rules for the namespace
- `topics`                        : All topics with the corresponding subscriptions

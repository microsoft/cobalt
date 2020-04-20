module "azure-provider" {
  source = "../provider"
}
locals {
  topic_authorization_rules = flatten([
    for topic in var.topics : [
      for rule in topic.authorization_rules :
      merge(
        rule, {
          topic_name = topic.name
      })
    ]
  ])

  topic_subscriptions = flatten([
    for topic in var.topics : [
      for subscription in topic.subscriptions :
      merge(
        subscription, {
          topic_name = topic.name
      })
    ]
  ])

  topic_subscription_rules = flatten([
    for subscription in local.topic_subscriptions :
    merge({
      filter_type = ""
      sql_filter  = ""
      action      = ""
      }, subscription, {
      topic_name        = subscription.topic_name
      subscription_name = subscription.name
    })
    if subscription.filter_type != null
  ])
}

## define resource group
data "azurerm_resource_group" "resourcegroup" {
  name = var.resource_group_name
}

## define service bus namespace
resource "azurerm_servicebus_namespace" "servicebus" {
  name                = var.namespace_name
  location            = data.azurerm_resource_group.resourcegroup.location
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  sku                 = var.sku
  tags                = var.tags
}

resource "azurerm_servicebus_namespace_authorization_rule" "sbnamespaceauth" {
  count = length(var.namespace_authorization_rules)

  name                = var.namespace_authorization_rules[count.index].policy_name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name
  resource_group_name = data.azurerm_resource_group.resourcegroup.name

  listen = var.namespace_authorization_rules[count.index].claims.listen
  send   = var.namespace_authorization_rules[count.index].claims.send
  manage = var.namespace_authorization_rules[count.index].claims.manage
}

resource "azurerm_servicebus_topic" "sptopic" {
  count = length(var.topics)

  name                = var.topics[count.index].name
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name

  requires_duplicate_detection = var.topics[count.index].requires_duplicate_detection
  default_message_ttl          = var.topics[count.index].default_message_ttl
  enable_partitioning          = var.topics[count.index].enable_partitioning
  support_ordering             = var.topics[count.index].support_ordering
}

resource "azurerm_servicebus_topic_authorization_rule" "topicaauth" {
  count = length(local.topic_authorization_rules)

  name                = local.topic_authorization_rules[count.index].policy_name
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name
  topic_name          = local.topic_authorization_rules[count.index].topic_name

  listen = local.topic_authorization_rules[count.index].claims.listen
  send   = local.topic_authorization_rules[count.index].claims.send
  manage = local.topic_authorization_rules[count.index].claims.manage

  depends_on = [azurerm_servicebus_topic.sptopic]
}

resource "azurerm_servicebus_subscription" "subscription" {
  count = length(local.topic_subscriptions)

  name                = local.topic_subscriptions[count.index].name
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name
  topic_name          = local.topic_subscriptions[count.index].topic_name

  max_delivery_count                   = local.topic_subscriptions[count.index].max_delivery_count
  lock_duration                        = local.topic_subscriptions[count.index].lock_duration
  forward_to                           = local.topic_subscriptions[count.index].forward_to
  dead_lettering_on_message_expiration = local.topic_subscriptions[count.index].dead_lettering_on_message_expiration

  depends_on = [azurerm_servicebus_topic.sptopic]
}

resource "azurerm_servicebus_subscription_rule" "subrules" {
  count = length(local.topic_subscription_rules)

  name                = local.topic_subscription_rules[count.index].name
  resource_group_name = data.azurerm_resource_group.resourcegroup.name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name
  topic_name          = local.topic_subscription_rules[count.index].topic_name
  subscription_name   = local.topic_subscription_rules[count.index].subscription_name
  filter_type         = local.topic_subscription_rules[count.index].filter_type != "" ? "SqlFilter" : null
  sql_filter          = local.topic_subscription_rules[count.index].sql_filter
  action              = local.topic_subscription_rules[count.index].action

  depends_on = [azurerm_servicebus_subscription.subscription]
}
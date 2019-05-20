# Azure Monitor

Azure Monitor maximizes the availability and performance of your applications by delivering a comprehensive solution for collecting, analyzing, and acting on telemetry from your cloud and on-premises environments. All data collected by Azure Monitor fits into one of two fundamental types, metrics and logs. Metrics are numerical values that describe some aspect of a system at a particular point in time. They are lightweight and capable of supporting near real-time scenarios. Logs contain different kinds of data organized into records with different sets of properties for each type.

More information for Azure Monitor can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)

A terraform module in Cobalt to provide Azure Monitor with the following characteristics:

- Ability to deploy Azure Monitor in the same resource group as the Service Plan.

- Ability to deploy Azure Monitor with custom defined criteria metrics scoped to target growing Azure resources.

- Ability to deploy Azure Monitor with custom defined criteria metrics all paired to a single action group.

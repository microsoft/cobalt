resource_group_name                       = "adftest"
data_factory_name                         = "adftest"
data_factory_runtime_name                 = "adfrttest"
data_factory_pipeline_name                = "testpipeline"
data_factory_trigger_name                 = "testtrigger"
data_factory_dataset_sql_name             = "testsql"
data_factory_dataset_sql_table_name       = "adfsqltableheba"
data_factory_linked_sql_name              = "testlinkedsql"
data_factory_linked_sql_connection_string = "connectionstring"
vnet_integration = {
  vnet_id     = "/subscriptions/resourceGroups/providers/Microsoft.Network/virtualNetworks/testvnet"
  subnet_name = "default"
}

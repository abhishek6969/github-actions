resource "azurerm_resource_group" "azureInfra" {
  name     = "azureInfra"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test-law-lirook" {
  name                = "test-law-lirook"
  location            = azurerm_resource_group.azureInfra.location
  resource_group_name = azurerm_resource_group.azureInfra.name
  retention_in_days   = 30
}

resource "azurerm_monitor_data_collection_rule" "example" {
  name                = "example-dcr"
  resource_group_name = azurerm_resource_group.azureInfra.name
  location            = azurerm_resource_group.azureInfra.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.test-law-lirook.id
      name                  = "example-log-analytics"
    }

    azure_monitor_metrics {
      name = "example-metrics"
    }
  }

  data_sources {
    performance_counter {
      name                          = "example-perf-counter"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",   # % CPU consumed
        "\\Memory\\% Committed Bytes In Use",      # % Memory used (Windows)
        "\\LogicalDisk(_Total)\\% Free Space",     # % Free Space of Disk
        "\\System\\System Up Time",                # System Uptime
        "Processor\\% Processor Time",             # % CPU consumed (Linux)
        "Memory\\% Used Memory",                   # % Memory used (Linux)
        "Disk\\% Free Space",                      # % Free Space of Disk (Linux)
        "System\\System Up Time"                   # System Uptime (Linux)
      ]
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["example-log-analytics", "example-metrics"]
  }

  description = "Data collection rule for performance counters"
}

resource "azurerm_automation_account" "lirookAutomation" {
  name                = "lirookAutomation"
  resource_group_name = azurerm_resource_group.azureInfra.name
  location            = azurerm_resource_group.azureInfra.location
  sku_name            = "Free"
}


resource "azurerm_log_analytics_linked_service" "example" {
  resource_group_name = azurerm_resource_group.azureInfra.name
  workspace_id = azurerm_log_analytics_workspace.test-law-lirook.id
  read_access_id = azurerm_automation_account.lirookAutomation.id
}

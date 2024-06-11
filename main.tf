terraform {    
  required_providers {    
    azurerm = {    
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }    
  }    
} 
   
provider "azurerm" {    
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "webapp-project"
  location = "East US"
}

resource "azurerm_app_service_plan" "main" {
  name                = "webapp-serviceplan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "webbapp-v1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "webapp-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "webapp_subnet" {
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "integration_subnet" {
  name                 = "integration-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id    = azurerm_app_service.app_service.id
  subnet_id         = azurerm_subnet.integration_subnet.id
  depends_on        = [azurerm_subnet.integration_subnet]
}


resource "azurerm_monitor_autoscale_setting" "test" {
  name                = "AutoscaleSetting"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_app_service_plan.main.id

 profile {
name = "defaultProfile"

capacity {
  default = 1
  minimum = 1
  maximum = 10
}

rule {
  metric_trigger {
    metric_name        = "CpuPercentage"
    metric_resource_id = azurerm_app_service_plan.main.id
    time_grain         = "PT1M"
    statistic          = "Average"
    time_window        = "PT5M"
    time_aggregation   = "Average"
    operator           = "GreaterThan"
    threshold          = 80
  }

  scale_action {
    direction = "Increase"
    type      = "ChangeCount"
    value     = "1"
    cooldown  = "PT1M"
  }
}

rule {
  metric_trigger {
    metric_name        = "CpuPercentage"
    metric_resource_id = azurerm_app_service_plan.main.id
    time_grain         = "PT1M"
    statistic          = "Average"
    time_window        = "PT5M"
    time_aggregation   = "Average"
    operator           = "LessThan"
    threshold          = 25
  }

  scale_action {
    direction = "Decrease"
    type      = "ChangeCount"
    value     = "1"
    cooldown  = "PT1M"
  }
} 
}
}
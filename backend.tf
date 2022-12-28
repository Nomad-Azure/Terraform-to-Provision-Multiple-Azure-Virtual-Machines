terraform {
  backend "azurerm" {
    resource_group_name   = "monitoring-lab"
    storage_account_name  = "monitoringlab8167"
    container_name        = "terraformstate"
    key                   = "Z7AOcVVpfd8AL6EY9WEV/wHLriCLGmF5GUwRY9AtdGI/o+fNdrHjs76s5DVXdfko8d7E/t3Uja4GsArDb6cohQ=="
  }
}
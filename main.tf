# Terraform Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# To get existing Resource Group
data "azurerm_resource_group" "rg" {
  name = var.rgname
}

# To get existing Virtual Network Details
data "azurerm_subnet" "subnet" {
  name                 = var.subnetname
  virtual_network_name = var.vnetname
  resource_group_name  = var.vnetrgname
}

# Create NIC 
resource "azurerm_network_interface" "nic"  {
  for_each            = var.vm_name
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = "${data.azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = var.vm_name  
  name                = each.key
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  size                = each.value
  location            = var.location
  admin_username      = "azureuser"
  admin_password      = "azuresuer@123"


  os_disk {
    name                 = "${each.key}-osdisk" 
    caching              = "ReadWrite"
    storage_account_type    = "Premium_LRS"
  }


   source_image_id = "/subscriptions/<subscription id>/resourceGroups/<resourcegroup name>/providers/Microsoft.Compute/galleries/gallery_name/images/<image_name>"
 
}

 resource "azurerm_managed_disk" "managed_disk" {
  for_each             = var.vm_name
  name                 = "${each.key}-datadisk" 
  location             = var.location
  resource_group_name  = "${data.azurerm_resource_group.rg.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disksize
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach" {
  for_each           = var.vm_name  
  managed_disk_id    = "${azurerm_managed_disk.managed_disk[each.key].id}"
  virtual_machine_id = "${azurerm_windows_virtual_machine.vm[each.key].id}"
  lun                = 0
  caching            = "ReadWrite"
}
  
resource "azurerm_virtual_machine_extension" "vm_extension" {
  for_each             = var.vm_name 
  name                 = each.key
  virtual_machine_id   = "${azurerm_windows_virtual_machine.vm[each.key].id}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

   settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File setup_v01.ps1",
        "fileUris": ["https://storageaccount.blob.core.windows.net/scripts/setup_v01.ps1"] 
    }
SETTINGS
}
 

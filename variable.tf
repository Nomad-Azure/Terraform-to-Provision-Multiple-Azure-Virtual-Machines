variable "vm_name" {
  type = map(string)
}


variable "location" {
    description = "Region of VM"

}


variable "rgname" {
  type = string
  description = "Name of the Resource Group"
}

variable "subnetname" {
  type = string
  description = "Name of Subnet"
}

variable "vnetname" {
  type = string
  description = "Name of the Vnet"
}

variable "vnetrgname" {
  type = string
  description = "Name of the Vnet Resource Group"
}

variable "disksize" {
  type = string
  description = "Name of the Vnet Resource Group"
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "az-StorageRg"
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default     = "West US"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "monitoring-vnet"
}

variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = "monitoring-ip"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "monitoring-vm"
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
  sensitive   = true
}

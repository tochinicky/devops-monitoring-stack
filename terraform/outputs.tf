output "monitoring_vm_public_ip" {
  value       = azurerm_public_ip.monitoring.ip_address
  description = "The public IP address of the monitoring server"
}

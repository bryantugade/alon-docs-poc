output "static_web_app_url" {
  description = "Default URL of the Static Web App"
  value       = azurerm_static_web_app.this.default_host_name
}


resource "azurerm_application_insights" "this" {
  name                = local.app_insight_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  application_type    = "web"
}

resource "azurerm_static_web_app" "this" {
  name                = local.static_app_name
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  sku_size            = "Standard"
  sku_tier            = "Standard"

  depends_on = [azurerm_application_insights.this]

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
    "ENVIRONMENT"                           = var.environment_name
  }
}
# resource "azurerm_static_site_custom_domain" "this" {
#   static_site_id = azurerm_static_site.this.id
#   domain_name    = "${var.app_name}.example.com"
# }
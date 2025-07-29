
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

locals {
  location_map = jsondecode(file("${path.root}/location.json"))
  abbreviation_map = jsondecode(file("${path.root}/abbreviations.json"))

  name_with_dashes    = "${var.app_name}-${local.location_map["${data.azurerm_resource_group.existing.location}"].alias}-${lower(substr(var.environment_name, 0, 1))}-"
  name_without_dashes = "${var.app_name}${local.location_map["${data.azurerm_resource_group.existing.location}"].alias}${lower(substr(var.environment_name, 0, 1))}"

  static_app_name                 = "${local.name_with_dashes}${local.abbreviation_map.webStaticSites}"
  app_insight_name               = "${local.name_with_dashes}${local.abbreviation_map.insightsComponents}"
  log_analytics_workspace_name   = "${local.name_with_dashes}${local.abbreviation_map.operationalInsightsWorkspaces}"
  app_insights_endpoint          = local.location_map[data.azurerm_resource_group.existing.location].appinsights_endpoint
}

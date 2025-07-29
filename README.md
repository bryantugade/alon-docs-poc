# alon-docs-site

A structured documentation and knowledge base site built for Alon. Designed to support teams and developers with clear technical guides, architecture references, and best practices.

  

## Architecture Design Overview

  

We'll design our architecture using the [C4 Model](https://c4model.com/) — specifically at the System and Container levels.

  

### 📊 C4 Diagram (System + Container Level)

  

![Design Architecture](https://github.com/bryantugade/alon-docs-poc/blob/main/images/design-infrastructure-alon-docs.png)

  

### Technologies Used

  

-  **Hugo**: Static site generator

-  **Azure Static Web Apps**: Deployment target

-  **Terraform**: Infrastructure as Code

-  **App Insights**: Monitoring

-  **GitHub Actions**: CI/CD automation

-  **OIDC Federated Credential**: Secure GitHub-to-Azure auth

---

## 🪜 Step-by-Step guides

  

### 1. 🔐 Create Azure Service Principal with Federated Credential

  

#### a. Register Azure AD App

  

```bash

az  ad  app  create  --display-name  "hugo-staticwebapp-sp"

  

```

  

#### b. Create Federated Credential (for GitHub OIDC)

  

```bash

az  ad  app  federated-credential  create  --id  <APP_ID>  \

--parameters '{

"name":  "github-oidc-env",

"issuer":  "https://token.actions.githubusercontent.com",

"subject":  "repo:<GITHUB_USERNAME>/<REPO>:environment:<ENVIRONMENT_NAME>",

"description":  "GitHub Actions OIDC using environment"

}'

  
  

```

  

#### c. Assign Role to SP

  

```bash

az  role  assignment  create  --assignee-object-id  <APP_OBJECT_ID>  \

--role "Contributor" --scope /subscriptions/<SUBSCRIPTION_ID>

```

  

----------

  

### 2. Prepare Environment Variables and Secrets

  

**Environment Secrets & Variables:**

  

***Secrets***

|Name|Description |

|--|--|

| AZURE_CLIENT_ID| App Id |

|AZURE_SUBSCRIPTION_ID|Subscription Id where Azure function will be deployed|

|AZURE_TENANT_ID| Tenant Id|

  

***Variables***

|Name | Description |

|--|--|

|APP_NAME | Application name. A prefix for all resources that will be deployed |

|ENVIRONMENT_NAME| Environment name e.g. Staging, Dev, Production|

|RESOURCE_GROUP_NAME| The existing resourcegroup name where resource will be deployed|

  

----------
### 3. Terraform for Infrastructure

#### 📄 `provider.tf`
```hcl
provider  "azurerm" {
features {}
}
terraform {
required_providers {
azurerm  = {
source  =  "hashicorp/azurerm"
version  =  "~> 3.80"
}
}
}
```

#### 📄 `variables.tf`
```hcl
variable  "resource_group_name" {
description  =  "Existing Resource Group name"
type  =  string
default  =  "alonwork-way-d-rg"
}

variable  "environment_name" {
type  =  string
default  =  "Development"
}

variable  "app_name" {
type  =  string
default  =  "alon-docs"
}
```


```hcl
  
data  "azurerm_resource_group"  "existing" {
name  =  var.resource_group_name
}

#### 📄 `main.tf`  

locals {
location_map  =  jsondecode(file("${path.root}/location.json"))
abbreviation_map  =  jsondecode(file("${path.root}/abbreviations.json"))

name_with_dashes  =  "${var.app_name}-${local.location_map["${data.azurerm_resource_group.existing.location}"].alias}-${lower(substr(var.environment_name, 0, 1))}-"

name_without_dashes  =  "${var.app_name}${local.location_map["${data.azurerm_resource_group.existing.location}"].alias}${lower(substr(var.environment_name, 0, 1))}"

static_app_name  =  "${local.name_with_dashes}${local.abbreviation_map.webStaticSites}"

app_insight_name  =  "${local.name_with_dashes}${local.abbreviation_map.insightsComponents}"

log_analytics_workspace_name  =  "${local.name_with_dashes}${local.abbreviation_map.operationalInsightsWorkspaces}"

app_insights_endpoint  =  local.location_map[data.azurerm_resource_group.existing.location].appinsights_endpoint

}
```

#### 📄 `resources.tf`

```hcl
resource  "azurerm_application_insights"  "this" {
name  =  local.app_insight_name
location  =  data.azurerm_resource_group.existing.location
resource_group_name  =  data.azurerm_resource_group.existing.name
application_type  =  "web"
}

resource  "azurerm_static_web_app"  "this" {
name  =  local.static_app_name
location  =  data.azurerm_resource_group.existing.location
resource_group_name  =  data.azurerm_resource_group.existing.name
sku_size  =  "Standard"
sku_tier  =  "Standard"

depends_on  = [azurerm_application_insights.this]

app_settings  = {
"APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.this.instrumentation_key
"APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
"ENVIRONMENT" = var.environment_name
}
}
```
#### 📄 `output.tf`

```hcl
output  "static_web_app_url" {
description  =  "Default URL of the Static Web App"
value  =  azurerm_static_web_app.this.default_host_name
}
```


# alon-docs-site
A structured documentation and knowledge base site built for Alon. Designed to support teams and developers with clear technical guides, architecture references, and best practices.

## Architecture Design Overview

We'll design our architecture using the [C4 Model](https://c4model.com/) — specifically at the System and Container levels.

### 📊 C4 Diagram (System + Container Level)

![Design Architecture](https://github.com/bryantugade/alon-docs-poc/blob/main/images/design-infrastructure-alon-docs.png)

### Technologies Used

-   **Hugo**: Static site generator
    
-   **Azure Static Web Apps**: Deployment target
    
-   **Terraform**: Infrastructure as Code
    
-   **App Insights**: Monitoring
    
-   **GitHub Actions**: CI/CD automation
    
-   **OIDC Federated Credential**: Secure GitHub-to-Azure auth
---
## 🪜 Step-by-Step guides

### 1. 🔐 Create Azure Service Principal with Federated Credential

#### a. Register Azure AD App

```bash
az ad app create --display-name "hugo-staticwebapp-sp"

```

#### b. Create Federated Credential (for GitHub OIDC)

```bash
az ad app federated-credential create --id <APP_ID> \
  --parameters '{
    "name": "github-oidc-env",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:<GITHUB_USERNAME>/<REPO>:environment:<ENVIRONMENT_NAME>",
    "description": "GitHub Actions OIDC using environment"
  }'


```

#### c. Assign Role to SP

```bash
az role assignment create --assignee-object-id <APP_OBJECT_ID> \
  --role "Contributor" --scope /subscriptions/<SUBSCRIPTION_ID>
```

----------

### 2. Prepare Environment Variables and Secrets

**Environment Secrets & Variables:** 

***Secrets***
|Name|Description  |
|--|--|
| AZURE_CLIENT_ID| App Id |
|AZURE_SUBSCRIPTION_ID|Subscription Id where Azure function will be deployed|
|AZURE_TENANT_ID| Tenant Id|

***Variables***
|Name | Description |
|--|--|
|APP_NAME   | Application name. A prefix for all resources that will be deployed |
|ENVIRONMENT_NAME| Environment name e.g. Staging, Dev, Production|
|RESOURCE_GROUP_NAME| The existing resourcegroup name where resource will be deployed|

----------
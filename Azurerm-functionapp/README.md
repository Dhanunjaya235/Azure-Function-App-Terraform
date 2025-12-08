# Azure Function App Module

This module deploys an Azure Function App with optional App Service Plan support. By default it deploys to the **Consumption (Dynamic/Y1)** plan without creating an App Service Plan. When you are ready to move to **Premium/Dedicated** plans, set `use_service_plan = true` to enable the full networking and private endpoint experience.

## Inputs

- `use_service_plan` (bool, default `false`): Toggle between Consumption (false) and Premium/Dedicated (true).
- `function_package_url`: Optional ZIP package URL; keeps `WEBSITE_RUN_FROM_PACKAGE` active in both modes.
- `spfunc_name`: Name for the App Service Plan (used only when `use_service_plan = true`).
- Networking inputs (`subnet_id`, `subnet_pe_id`) are only used when `use_service_plan = true`.
- Application Insights, Storage Account, and managed identity inputs remain required/usable in both modes.

## Behaviors

### Consumption mode (default)
- No App Service Plan created; Function App runs on Consumption (Dynamic/Y1).
- No VNet integration, no private endpoint/DNS.
- Minimal site config (Python runtime + required settings).
- Public access enabled.
- Application Insights and Storage Account integrations still configured; `WEBSITE_RUN_FROM_PACKAGE` remains supported.

### Premium/Dedicated mode
- Creates the App Service Plan and wires `serverFarmId`.
- Restores VNet integration, route all, IP restrictions, and private endpoint.
- Advanced site config retained (alwaysOn, ipRestrictions, etc.) for Premium/Dedicated scenarios.

## Quick Usage

### Free trial / Consumption deployment
```hcl
use_service_plan    = false
function_package_url = "https://<storage>.blob.core.windows.net/function-packages/function-app.zip"
```

### Premium deployment (once quotas/permissions are available)
```hcl
use_service_plan = true
spfunc_name      = "my-func-plan" # name of the App Service Plan
```

## Outputs

- `service_plan_id`: The App Service Plan ID when `use_service_plan = true`; `null` otherwise.


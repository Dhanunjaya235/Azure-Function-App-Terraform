# Quick Upload Guide - Function App Package

## Step-by-Step Instructions

### 1. Create the ZIP File

**Using PowerShell:**
```powershell
cd "C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code"
Compress-Archive -Path function_app.py,host.json,requirements.txt -DestinationPath function-app.zip -Force
```

**Or manually:**
- Select `function_app.py`, `host.json`, and `requirements.txt`
- Right-click → Send to → Compressed (zipped) folder
- Rename to `function-app.zip`

### 2. Upload to Azure Blob Storage

#### Method A: Using Azure CLI (Recommended)

```bash
# Login to Azure
az login

# Set your values
STORAGE_ACCOUNT="yourstorageaccountname"
CONTAINER="function-packages"
ZIP_FILE="C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code\function-app.zip"

# Create container (if needed)
az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

# Upload the ZIP
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name function-app.zip \
  --file "$ZIP_FILE" \
  --auth-mode login \
  --overwrite

# Get the URL
az storage blob url \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name function-app.zip \
  --auth-mode login
```

**Copy the URL that's displayed** - it will look like:
```
https://yourstorageaccount.blob.core.windows.net/function-packages/function-app.zip
```

#### Method B: Using Azure Portal

1. **Go to Azure Portal** → Search for your Storage Account
2. **Click "Containers"** in the left menu
3. **Create a container** (if you don't have one):
   - Click "+ Container"
   - Name: `function-packages` (or any name)
   - Public access level: **Private** (important!)
   - Click "Create"
4. **Upload the ZIP**:
   - Click on your container
   - Click "Upload"
   - Click the folder icon and select `function-app.zip`
   - Click "Upload"
5. **Get the URL**:
   - Click on the uploaded `function-app.zip` file
   - Click "Copy URL" button
   - The URL will be in your clipboard

### 3. Ensure Managed Identity Access

The Function App's managed identity needs access to read the blob:

```bash
# Get your UMI Client ID (from Terraform variables or Azure Portal)
UMI_CLIENT_ID="your-umi-client-id"
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="your-resource-group"
STORAGE_ACCOUNT="yourstorageaccountname"

# Assign Storage Blob Data Reader role
az role assignment create \
  --assignee $UMI_CLIENT_ID \
  --role "Storage Blob Data Reader" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT
```

**Or via Azure Portal:**
1. Go to Storage Account → Access Control (IAM)
2. Click "+ Add" → "Add role assignment"
3. Role: **Storage Blob Data Reader**
4. Assign access to: **Managed identity**
5. Select your User-Assigned Managed Identity
6. Click "Save"

### 4. Use the URL in Terraform

Add the URL to your `terraform.tfvars`:

```hcl
function_package_url = "https://yourstorageaccount.blob.core.windows.net/function-packages/function-app.zip"
```

Then run:
```bash
terraform plan
terraform apply
```

### 5. Verify Deployment

After Terraform applies, check your Function App:

```bash
# Check function app status
az functionapp show \
  --name <your-function-app-name> \
  --resource-group <your-resource-group> \
  --query state

# View function app logs
az functionapp log tail \
  --name <your-function-app-name> \
  --resource-group <your-resource-group>
```

## Troubleshooting

### Issue: Function App can't access the blob
- **Solution**: Ensure UMI has "Storage Blob Data Reader" role on the storage account

### Issue: ZIP file not found
- **Solution**: Verify the URL is correct and the blob exists in the container

### Issue: Function code not updating
- **Solution**: After uploading a new ZIP, restart the Function App:
  ```bash
  az functionapp restart \
    --name <function-app-name> \
    --resource-group <resource-group>
  ```

### Issue: Dependencies not installing
- **Solution**: Check `requirements.txt` is in the ZIP root and contains valid packages

## File Structure in ZIP

The ZIP file should have this structure:
```
function-app.zip
├── function_app.py
├── host.json
└── requirements.txt
```

**Important**: Files should be at the root of the ZIP, not in a subfolder!


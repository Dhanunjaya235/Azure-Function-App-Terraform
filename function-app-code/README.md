# Azure Function App - Python Code

This is a simple Python Azure Function App with two functions:
1. **HTTP Trigger** - Responds to HTTP requests
2. **Timer Trigger** - Runs on a schedule (every 5 minutes)

## File Structure

```
function-app-code/
├── function_app.py      # Main function code
├── host.json            # Function App host configuration
├── requirements.txt     # Python dependencies
└── README.md           # This file
```

## Packaging Instructions

### Option 1: Using PowerShell (Windows)

1. **Navigate to the function-app-code directory**:
   ```powershell
   cd "C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code"
   ```

2. **Create a ZIP file**:
   ```powershell
   Compress-Archive -Path function_app.py,host.json,requirements.txt -DestinationPath function-app.zip -Force
   ```

### Option 2: Using Command Prompt (Windows)

1. **Navigate to the function-app-code directory**:
   ```cmd
   cd "C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code"
   ```

2. **Create a ZIP file** (if you have 7-Zip or WinRAR):
   ```cmd
   # Using built-in PowerShell
   powershell Compress-Archive -Path function_app.py,host.json,requirements.txt -DestinationPath function-app.zip -Force
   ```

### Option 3: Manual ZIP Creation

1. Select all three files: `function_app.py`, `host.json`, `requirements.txt`
2. Right-click → Send to → Compressed (zipped) folder
3. Rename to `function-app.zip`

## Uploading to Azure Blob Storage

### Prerequisites
- Azure CLI installed and logged in
- Storage account created
- Container created in the storage account

### Step 1: Login to Azure
```bash
az login
```

### Step 2: Set Variables
```bash
# Replace with your values
STORAGE_ACCOUNT_NAME="yourstorageaccountname"
RESOURCE_GROUP="your-resource-group"
CONTAINER_NAME="function-packages"  # or any container name
ZIP_FILE_PATH="C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code\function-app.zip"
```

### Step 3: Create Container (if it doesn't exist)
```bash
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode login
```

### Step 4: Upload ZIP File
```bash
az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name $CONTAINER_NAME \
  --name function-app.zip \
  --file "$ZIP_FILE_PATH" \
  --auth-mode login \
  --overwrite
```

### Step 5: Get the Blob URL
```bash
az storage blob url \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name $CONTAINER_NAME \
  --name function-app.zip \
  --auth-mode login
```

This will output a URL like:
```
https://yourstorageaccountname.blob.core.windows.net/function-packages/function-app.zip
```

### Step 6: Make Blob Accessible via Managed Identity

The blob needs to be accessible by the Function App's managed identity. Ensure:
1. The User-Assigned Managed Identity (UMI) has "Storage Blob Data Reader" role on the storage account
2. The blob container allows access via managed identity

```bash
# Assign role to UMI (if not already done)
az role assignment create \
  --assignee <UMI_CLIENT_ID> \
  --role "Storage Blob Data Reader" \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>
```

## Using the URL in Terraform

Once you have the blob URL, add it to your `terraform.tfvars`:

```hcl
function_package_url = "https://yourstorageaccountname.blob.core.windows.net/function-packages/function-app.zip"
```

## Testing the Function

After deployment, test your function:

1. **HTTP Trigger**:
   ```bash
   # Get function URL (replace with your function app name)
   FUNCTION_URL="https://<your-function-app-name>.azurewebsites.net/api/hello"
   
   # Test with query parameter
   curl "$FUNCTION_URL?name=World"
   
   # Or test with JSON body
   curl -X POST "$FUNCTION_URL" \
     -H "Content-Type: application/json" \
     -d '{"name": "Azure"}'
   ```

2. **Timer Trigger**: Check Application Insights logs to see timer executions

## Alternative: Upload via Azure Portal

1. Go to Azure Portal → Storage Accounts → Your Storage Account
2. Click on "Containers" → Create container (if needed) → Select container
3. Click "Upload" → Select your `function-app.zip` file
4. After upload, click on the blob → Copy the "URL" value
5. Use this URL in your Terraform configuration

## Notes

- The ZIP file should contain files at the root level (not in a subfolder)
- Ensure `host.json` and `function_app.py` are in the root of the ZIP
- The function app will automatically install dependencies from `requirements.txt` on first run
- If you update the code, create a new ZIP and upload it (overwrite the existing blob)


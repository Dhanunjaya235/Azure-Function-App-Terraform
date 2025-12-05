# Quick Start Guide - Function App Package

## 🚀 Fastest Way to Package and Upload

### Option 1: Use the PowerShell Script (Easiest)

1. **Open PowerShell** in the `function-app-code` folder
2. **Run the script**:
   ```powershell
   .\package-and-upload.ps1 -StorageAccountName "yourstorageaccount" -ContainerName "function-packages"
   ```
3. **Copy the URL** that's displayed
4. **Add to terraform.tfvars**:
   ```hcl
   function_package_url = "https://yourstorageaccount.blob.core.windows.net/function-packages/function-app.zip"
   ```

### Option 2: Manual Steps

#### Step 1: Create ZIP File

**PowerShell:**
```powershell
cd "C:\Users\Dhanunjaya A\Downloads\Azure Guardian\function-app-code"
Compress-Archive -Path function_app.py,host.json,requirements.txt -DestinationPath function-app.zip -Force
```

**Or manually:**
- Select `function_app.py`, `host.json`, `requirements.txt`
- Right-click → Send to → Compressed (zipped) folder
- Rename to `function-app.zip`

#### Step 2: Upload via Azure Portal

1. Go to **Azure Portal** → Your **Storage Account**
2. Click **"Containers"** → **"+ Container"**
   - Name: `function-packages`
   - Access level: **Private**
   - Click **Create**
3. Click on the container → **Upload**
4. Select `function-app.zip` → **Upload**
5. Click on the uploaded file → **Copy URL**

#### Step 3: Use the URL

Add to `terraform.tfvars`:
```hcl
function_package_url = "https://yourstorageaccount.blob.core.windows.net/function-packages/function-app.zip"
```

## 📁 Files Included

- **function_app.py** - Contains 2 functions:
  - HTTP Trigger (responds to web requests)
  - Timer Trigger (runs every 5 minutes)
- **host.json** - Function App configuration
- **requirements.txt** - Python dependencies

## ✅ What the Function Does

### HTTP Trigger
- **URL**: `https://<your-function-app>.azurewebsites.net/api/hello`
- **Test**: 
  - `https://<your-function-app>.azurewebsites.net/api/hello?name=World`
  - Returns: "Hello, World! This is your Azure Function App running successfully!"

### Timer Trigger
- Runs automatically every 5 minutes
- Logs execution time to Application Insights

## 🔐 Important: Set Up Managed Identity Access

Before deploying, ensure your UMI can read the blob:

```bash
az role assignment create \
  --assignee <UMI_CLIENT_ID> \
  --role "Storage Blob Data Reader" \
  --scope /subscriptions/<SUB_ID>/resourceGroups/<RG>/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT>
```

## 📝 ZIP File Structure

```
function-app.zip
├── function_app.py    (root level)
├── host.json          (root level)
└── requirements.txt   (root level)
```

**Important**: Files must be at the root, NOT in a subfolder!

## 🧪 Test After Deployment

```bash
# Test HTTP function
curl "https://<your-function-app>.azurewebsites.net/api/hello?name=Azure"

# View logs
az functionapp log tail --name <function-app-name> --resource-group <rg-name>
```


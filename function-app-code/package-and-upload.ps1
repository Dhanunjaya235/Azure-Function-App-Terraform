# PowerShell Script to Package and Upload Function App
# Make sure you're logged into Azure CLI: az login

param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ContainerName,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$false)]
    [string]$ZipFileName = "function-app.zip"
)

Write-Host "=== Azure Function App Package & Upload Script ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create ZIP file
Write-Host "Step 1: Creating ZIP package..." -ForegroundColor Yellow
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$zipPath = Join-Path $scriptPath $ZipFileName

# Remove existing ZIP if it exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
    Write-Host "  Removed existing ZIP file" -ForegroundColor Gray
}

# Create ZIP with required files
$filesToZip = @(
    (Join-Path $scriptPath "function_app.py"),
    (Join-Path $scriptPath "host.json"),
    (Join-Path $scriptPath "requirements.txt")
)

$missingFiles = $filesToZip | Where-Object { -not (Test-Path $_) }
if ($missingFiles) {
    Write-Host "ERROR: Missing required files:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Compress-Archive -Path $filesToZip -DestinationPath $zipPath -Force
Write-Host "  ✓ Created ZIP file: $zipPath" -ForegroundColor Green
Write-Host ""

# Step 2: Check Azure CLI
Write-Host "Step 2: Checking Azure CLI..." -ForegroundColor Yellow
$azVersion = az version --query '"azure-cli"' -o tsv 2>$null
if (-not $azVersion) {
    Write-Host "  ERROR: Azure CLI not found. Please install it from https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Azure CLI version: $azVersion" -ForegroundColor Green

# Check if logged in
$account = az account show 2>$null
if (-not $account) {
    Write-Host "  Please login to Azure..." -ForegroundColor Yellow
    az login
}
Write-Host ""

# Step 3: Create container if it doesn't exist
Write-Host "Step 3: Checking/creating container..." -ForegroundColor Yellow
$containerExists = az storage container exists --name $ContainerName --account-name $StorageAccountName --auth-mode login --query exists -o tsv 2>$null

if ($containerExists -eq "false") {
    Write-Host "  Creating container: $ContainerName" -ForegroundColor Gray
    az storage container create `
        --name $ContainerName `
        --account-name $StorageAccountName `
        --auth-mode login `
        --output none
    Write-Host "  ✓ Container created" -ForegroundColor Green
} else {
    Write-Host "  ✓ Container already exists" -ForegroundColor Green
}
Write-Host ""

# Step 4: Upload ZIP file
Write-Host "Step 4: Uploading ZIP file to blob storage..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccountName `
    --container-name $ContainerName `
    --name $ZipFileName `
    --file $zipPath `
    --auth-mode login `
    --overwrite `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ File uploaded successfully" -ForegroundColor Green
} else {
    Write-Host "  ✗ Upload failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 5: Get the blob URL
Write-Host "Step 5: Getting blob URL..." -ForegroundColor Yellow
$blobUrl = az storage blob url `
    --account-name $StorageAccountName `
    --container-name $ContainerName `
    --name $ZipFileName `
    --auth-mode login `
    --output tsv

Write-Host ""
Write-Host "=== SUCCESS ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your function package URL is:" -ForegroundColor Cyan
Write-Host $blobUrl -ForegroundColor White
Write-Host ""
Write-Host "Add this to your terraform.tfvars:" -ForegroundColor Yellow
Write-Host "function_package_url = `"$blobUrl`"" -ForegroundColor White
Write-Host ""
Write-Host "Don't forget to ensure your UMI has 'Storage Blob Data Reader' role on the storage account!" -ForegroundColor Yellow


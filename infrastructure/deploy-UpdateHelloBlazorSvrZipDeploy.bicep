/*
   From a (cygwin) bash prompt, use this perl one-liner to extract the powershell script fragments and exeucte them. This example shows how to execute steps 2 (shutdown) and steps 4-13 and skipping steps 7,8,9 because they don't work (yet). Adjust that list of steps according to your needs.

  See https://learn.microsoft.com/en-us/answers/questions/1689513/msdeploy-causes-error-failed-to-download-package-s
    Also: https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps (this does not work)
    Also: https://azure.github.io/AppService/2021/03/01/deploying-to-network-secured-sites-2.html (try this for web app)
    Also: https://learn.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-deploy (try this for function app)


   powershell -executionPolicy unrestricted -Command - <<EOF
   `perl -lne 'sub range {$b=shift; $e=shift; $r=""; for(($b..$e)){ $r=$r."," if $r; $r=$r.$_;} $r } BEGIN {  $_ = shift; s/([0-9]+)-([0-9]+)/range($1,$2)/e; @idx=split ","; $c=0; $x=0; $f=0; $s=[] } $c++ if /^\s*Begin/; if (/^\s*End/) {$c--;$s[$f++]=""}; if ($x+$c>1) { $s->[$f]=$s->[$f].$_."\n"  } $x=$c; END { push(@idx, $#s); unshift @idx,0; for (@idx) { $p=$s->[$_]; chomp $p; print $p } }' "2,4-6,10-13" < "Az CLI commands for deployment using ARM Template.bicep"  `
EOF

   Begin common prolog commands
   $env:subscriptionId=(az account show --query id --output tsv | ForEach-Object { $_ -replace "`r", ""})
   If ($env:USERNAME -eq "shein") { $env:name="UpdateHelloBlazorSvrZipDeploy" } Else { $env:name="UpdateHelloBlazorSvrZipDeploy_$($env:USERNAME)" }
   $env:rg="rg_$($env:name)"
   $env:location=If ($env:AZ_DEFAULT_LOC) { $env:AZ_DEFAULT_LOC} Else {'eastus2'}
   $env:uniquePrefix="$(If ($env:USERNAME -eq "v-richardsi") {"dxwqf"} ElseIf ($env:USERNAME -eq "v-paperry") { "fgtxv" } ElseIf ($env:USERNAME -eq "hein") {"wbvlu"} Else { "ilmqt" } )"
   $env:webAppName="$($env:uniquePrefix)-webapp"
   $env:sp=$env:webAppName
   $env:storageAccountName="$($env:uniquePrefix)webstg"
   $env:blobstg="$($env:uniquePrefix)blobstg"
   $env:stgContainer="mycontainer"
   $env:package_zip="package.zip"
   End common prolog commands

   emacs F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "start with step 3."
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 2 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "begin shutdown $env:rg $(Get-Date)"
   az deployment group create --mode complete --template-file ./clear-resources.json --resource-group $env:rg  | ForEach-Object { $_ -replace "`r", ""}
   write-output "showdown is complete $env:rg $(Get-Date)" 
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 3 F10
   Begin commands for one time initializations using Azure CLI with PowerShell
   write-output "az group create -l $env:location -n $env:rg"
   az group create -l $env:location -n $env:rg
   write-output "{`n`"`$schema`": `"https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`",`n `"contentVersion`": `"1.0.0.0`",`n `"resources`": [] `n}" | Out-File -FilePath clear-resources.json
   End commands for one time initializations using Azure CLI with PowerShell

   emacs ESC 4 F10
   Begin commands to shut down this deployment using Azure CLI with PowerShell
   write-output "step 4 delete resource group"
   write-output "az group delete -n $env:rg --yes"
   az group delete  -n $env:rg --yes
   End commands to shut down this deployment using Azure CLI with PowerShell

   emacs ESC 5 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 5 Publish"
   write-output "dotnet publish '../HelloBlazorSvr.csproj'  --configuration Release   --self-contained --output ./publish-webapp"
   dotnet publish "../HelloBlazorSvr.csproj"  --configuration Release  --self-contained --output ./publish-webapp
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 6 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 6 zip"
   pushd ./publish-webapp
   write-output "Compress-Archive -Path .\* -DestinationPath ../publish-webapp.zip -Force"
   Compress-Archive -Path .\* -DestinationPath ../publish-webapp.zip -Force
   popd
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 7 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 7 Create Storage Account for WebApp"
   write-output "az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:location --sku Standard_LRS --access-tier Cool"
   az storage account create --name $env:storageAccountName  --resource-group $env:rg --location $env:location --sku Standard_LRS --access-tier Cool
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 8 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 8 Show Connection strings for storage Storage Account for Web App"
   write-output "az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV"
   az storage account show-connection-string --resource-group $env:rg --name $env:storageAccountName --output TSV
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 9 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 9 create storage account from which to upload the zipped and compiled C# webapp code"
   write-output "az storage account create -n $($env:blobstg) -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n $env:blobstg -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 10 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 10 create storage container blob for compiled C# code"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name $($env:blobstg)"
   az storage container create -n $env:stgContainer --account-name $env:blobstg  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 11 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 11 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-webapp.zip --account-name $($env:blobstg)  -c $env:stgContainer -n $($env:package_zip) --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-webapp.zip --account-name $env:blobstg  -c $env:stgContainer -n $env:package_zip --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   Output from Step 11 upload zip to blob
   az storage blob upload -f publish-webapp.zip --account-name   -c mycontainer -n package.zip --overwrite true  --connection-string "REDACTED"
   Alive[################################################################]  100.0000%
   Finished[#############################################################]  100.0000%
   {
     "client_request_id": "60334ead-438c-11ef-91d3-010101010000",
     "content_md5": "QxFAj2X9Bq7zYERcXV3ePQ==",
     "date": "2024-07-16T15:59:59+00:00",
     "encryption_key_sha256": null,
     "encryption_scope": null,
     "etag": "\"0x8DCA5B058AB6620\"",
     "lastModified": "2024-07-16T16:00:00+00:00",
     "request_id": "2dc6de16-101e-006d-1999-d7417f000000",
     "request_server_encrypted": true,
     "version": "2022-11-02",
     "version_id": null
   }
   resource group rg_UpdateHelloBlazorSvrZipDeploy
   Name          Flavor     ResourceType                       Region
   ------------  ---------  ---------------------------------  --------
   ilmqtblobstg  StorageV2  Microsoft.Storage/storageAccounts  westus2
   ilmqtwebstg   StorageV2  Microsoft.Storage/storageAccounts  westus2
   all done 07/16/2024 09:00:02

   emacs ESC 12 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 12 deploy plan for helloworld .. this is redundant with the bicep code"
   write-output "az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku F1 -l $env:location"
   az appservice plan create -g $env:rg -n $env:uniquePrefix-plan-webapp --sku F1 -l $env:location
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 13 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 13 create webapp helloworld .. this is redundant with the bicep code"
   write-output "az webapp create --name '$($env:webAppName)' --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp --runtime `"dotnet:8`""
   az webapp create --name $env:webAppName --resource-group $env:rg --plan $env:uniquePrefix-plan-webapp --runtime "dotnet:8"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 14 F10 uploaod using "az webapp deploy": this is broken
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 14 generate blob SAS and deploy using using az webapp deploy"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $($env:blobstg) -c $env:stgContainer -n $($env:package_zip) --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:blobstg -c $env:stgContainer -n $env:package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "az webapp deploy --async false --clean true --name $($env:webAppName) --resource-group $($env:rg) --restart true --src-url env:sasUrl --type zip"
   az webapp deploy --async false --clean true --name $env:webAppName --resource-group $env:rg --restart true --src-url '$env:sasUrl' --type zip
   End commands to deploy this file using Azure CLI with PowerShell

   Output: Step 14 generate blob SAS and deploy using using az webapp deploy
   az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name ilmqtblobstg -c mycontainer -n package.zip --https-only --output tsv
   az webapp deploy --async false --clean true --name ilmqt-webapp --resource-group rg_UpdateHelloBlazorSvrZipDeploy --restart true --src-url env:sasUrl --type zip
   WARNING: Initiating deployment
   WARNING: Deploying from URL: $env:sasUrl
   ERROR: Bad Request({"error":{"code":"BadRequest","message":"System.ArgumentException: Invalid '$env:sasUrl' packageUri in the JSON request\r\n   at Kudu.Services.Deployment.PushDeploymentController.<PushDeployAsync>d__16.MoveNext() in C:\\__w\\1\\s\\Kudu.Services\\Deployment\\PushDeploymentController.cs:line 474"}})
   resource group rg_UpdateHelloBlazorSvrZipDeploy
   Name               Flavor     ResourceType                       Region
   -----------------  ---------  ---------------------------------  --------
   ilmqtblobstg       StorageV2  Microsoft.Storage/storageAccounts  westus2
   ilmqtwebstg        StorageV2  Microsoft.Storage/storageAccounts  westus2
   ilmqt-plan-webapp  app        Microsoft.Web/serverFarms          westus2
   ilmqt-webapp       app        Microsoft.Web/sites                westus2
   all done 07/18/2024 04:50:56
   
   Process compilation finished

   emacs ESC 15 F10 upload using bicep zipdeploy: this is  broken
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 15 generate blob SAS and deploy using bicep. Skip this for now it does not work"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $($env:blobstg) -c $env:stgContainer -n $($env:package_zip) --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:blobstg -c $env:stgContainer -n $env:package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $env:sasUrl =  $env:sasUrl -replace '&', '%26'
   write-output "escaped sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateFunctionZipDeploy.bicep" --parameters "{'packageUri': {'value': '$env:sasUrl'}}" "{'functionAppName': {'value': '$env:functionAppName'}}" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 16 F10 upload with az webapp deployment source config-zip: this is broken
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 16 use `"az webapp deployment source config-zip`" to deploy compiled #C code deployment to azure resource (skip this and do with with the zip deploy instead)"
   write-output "az functionapp deployment source config-zip -g $env:rg -n $env:webAppName --src ./publish-webapp.zip"
   az webapp deployment source config-zip -g $env:rg -n $env:webAppName --src ./publish-webapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   Output: step 16 us "az webapp deployment source config-zipg" to deploy compiled #C code deployment to azure resource (skip this and do with with the zip deploy instead)
   az functionapp deployment source config-zip -g rg_UpdateHelloBlazorSvrZipDeploy -n ilmqt-webapp --src ./publish-webapp.zip
   WARNING: This command has been deprecated and will be removed in a future release. Use 'az webapp deploy' instead.
   WARNING: Getting scm site credentials for zip deployment
   WARNING: Starting zip deployment. This operation can take a while to complete ...
   WARNING: Deployment endpoint responded with status code 202
   {
     "active": true,
     "author": "N/A",
     "author_email": "N/A",
     "complete": true,
     "deployer": "ZipDeploy",
     "end_time": "2024-07-18T11:58:10.1536103Z",
     "id": "3d82781425074ebca44228ab710581b0",
     "is_readonly": true,
     "is_temp": false,
     "last_success_end_time": "2024-07-18T11:58:10.1536103Z",
     "log_url": "https://ilmqt-webapp.scm.azurewebsites.net/api/deployments/latest/log",
     "message": "Created via a push deployment",
     "progress": "",
     "provisioningState": "Succeeded",
     "received_time": "2024-07-18T11:58:06.8648658Z",
     "site_name": "ilmqt-webapp",
     "start_time": "2024-07-18T11:58:06.9586203Z",
     "status": 4,
     "status_text": "",
     "url": "https://ilmqt-webapp.scm.azurewebsites.net/api/deployments/latest"
   }
   resource group rg_UpdateHelloBlazorSvrZipDeploy
   Name               Flavor     ResourceType                       Region
   -----------------  ---------  ---------------------------------  --------
   ilmqtblobstg       StorageV2  Microsoft.Storage/storageAccounts  westus2
   ilmqtwebstg        StorageV2  Microsoft.Storage/storageAccounts  westus2
   ilmqt-plan-webapp  app        Microsoft.Web/serverFarms          westus2
   ilmqt-webapp       app        Microsoft.Web/sites                westus2
   all done 07/18/2024 04:58:14


   HTTP Error 500.32 - ANCM Failed to Load dll
   Common solutions to this issue:
   The application was likely published for a different bitness than w3wp.exe/iisexpress.exe is running as.
   Troubleshooting steps:
   Check the system event log for error messages
   Enable logging the application process' stdout messages
   Attach a debugger to the application process and inspect
   For more information visit: https://go.microsoft.com/fwlink/?LinkID=2028526   


   see also: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-service-bus-data-receiver

   emacs ESC 17 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 17: Upddate the built at timestamp in the source code (ala ChatGPT)"
   # Path to your C# source file
   $filePath = "..\zipdeployhttpfunc.cs"
   # Read the contents of the file
   $content = Get-Content -Path $filePath -Raw
   # Regular expression to match the version number in the format "Version 000000000"
   $versionRegex = 'Version [0-9]+'
   # Regular expression to match the date-time string
   $regex = 'Built at [A-Za-z]{3} +[A-Za-z]{3} +[0-9]{1,2} +[0-9]{1,2}:+[0-9]{1,2}:+[0-9]{1,2} +[0-9]{4}'
   # Initialize flags to check if replacements were made
   $dateUpdated = $false
   $versionUpdated = $false
   if ($content -match $regex) {
     # Get the current date-time in the same format
     $currentDateTime = Get-Date -Format "ddd MMM dd HH:mm:ss yyyy"
     write-output "Replace the old date-time with the current date-time $currentDateTime"
     $updatedContent = [regex]::Replace($content, $regex, "Built at $currentDateTime")
     $dateUpdated = $true
     Write-Output "Date-time string updated successfully."
   } else {
     write-output "Built At timestamp not found"
   }
   # Check if the version regex finds a match
   if ($content -match $versionRegex) {
       # Extract the current version number
       $currentVersion = [regex]::Match($content, $versionRegex).Value
       # Increment the version number by 1
       $versionNumber = [int]($currentVersion -replace '[^0-9]', '')
       write-output "found version $versionNumber"
       $newVersionNumber = $versionNumber + 1
       write-output "increment version $versionNumber"
       $newVersionString = "Version " + $newVersionNumber.ToString("D5")
       write-output "new version string= $newVersionString"
       # Replace the old version number with the new version number
       $content = $content -replace $versionRegex, $newVersionString
       $versionUpdated = $true
   } else {
       Write-Output "No version number found matching the pattern."
   }
   if ($dateUpdated -or $versionUpdated) {
       Set-Content -Path $filePath -Value $content
       Write-Output "File updated successfully in $filePath."
   } else {
      Write-Output "No updates made to the file."
   }   
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 18 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 18 create service principal"
   write-output "az ad sp create-for-rbac --name $env:webAppName --role contributor --scopes '/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg' --sdk-auth"
   az ad sp create-for-rbac --name $env:webAppName --role contributor --scopes "/subscriptions/$($env:subscriptionId)/resourceGroups/$env:rg" --sdk-auth  
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 19 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 19 create storage account from which to upload the zipped and compiled C# function code"
   write-output "az storage account create -n $($env:blobstg) -g $env:rg --access-tier cool --sku Standard_LRS"
   az storage account create -n $env:blobstg -g $env:rg   --access-tier cool --sku Standard_LRS
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 20 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 20 create storage container"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container create -n $env:stgContainer --account-name $($env:blobstg)"
   az storage container create -n $env:stgContainer --account-name $env:blobstg  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 21 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 21 upload zip to blob"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "conn=$($env:conn)"
   write-output "az storage blob upload -f publish-webapp.zip --account-name $($env:blobstg)  -c $env:stgContainer -n $($env:package_zip) --overwrite true  --connection-string $env:conn"
   az storage blob upload -f publish-webapp.zip --account-name $env:blobstg  -c $env:stgContainer -n $env:package_zip --overwrite true  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 22 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "step 22 configure function app WEBSITE_RUN_FROM_PACKAGE=1 after uploading initial deployment"
   write-output "az functionapp config appsettings set -g $env:rg -n $env:webAppName --settings WEBSITE_RUN_FROM_PACKAGE=1"
   az functionapp config appsettings set -g $env:rg -n $env:webAppName --settings "WEBSITE_RUN_FROM_PACKAGE=1"
   write-output "az functionapp config appsettings list -n $env:webAppName -g $env:rg"
   az functionapp config appsettings list -n $env:webAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 23 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 23 generate blob SAS and deploy"
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString('yyyy-MM-ddTHH:mm:ssZ') --account-name $($env:blobstg) -c $env:stgContainer -n $($env:package_zip) --https-only --output tsv"
   $env:sasUrl=(az storage blob generate-sas --full-uri --permissions acdeimrtwx --expiry (get-date).AddMinutes(60).ToString("yyyy-MM-ddTHH:mm:ssZ") --account-name $env:blobstg -c $env:stgContainer -n $env:package_zip  --connection-string $env:conn --https-only --output tsv)
   write-output "sasUrl=$($env:sasUrl)"
   $env:sasUrl =  $env:sasUrl -replace '&', '%26'
   write-output "escaped sasUrl=$($env:sasUrl)"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateHelloBlazorSvrZipDeploy.bicep" --parameters "{'packageUri': {'value': '$env:sasUrl'}}" "{'webAppName': {'value': '$env:webAppName'}}" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 24 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 24 deploy using parameters file deploy-UpdateHelloBlazorSvrZipDeploy.parameters.json"
   az deployment group create --name $env:name --resource-group $env:rg --mode Incremental --template-file  "deploy-UpdateHelloBlazorSvrZipDeploy.bicep" --parameters "@deploy-UpdateHelloBlazorSvrZipDeploy.parameters.json" | ForEach-Object { $_ -replace "`r", ""}
   End commands to deploy this file using Azure CLI with PowerShell


   ERROR: {
     "status": "Failed",
     "error": {
       "code": "DeploymentFailed",
       "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateHelloBlazorSvrZipDeploy_shein/providers/Microsoft.Resources/deployments/UpdateHelloBlazorSvrZipDeploy_shein",
       "message": "At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.",
       "details": [
         {
           "code": "ResourceDeploymentFailure",
           "target": "/subscriptions/acc26051-92a5-4ed1-a226-64a187bc27db/resourceGroups/rg_UpdateHelloBlazorSvrZipDeploy_shein/providers/Microsoft.Web/sites/zipdeployhttpfunc20240529150920/extensions/ZipDeploy",
           "message": "The resource write operation failed to complete successfully, because it reached terminal provisioning state 'Failed'."
         }
       ]
     }
   }


   emacs ESC 25 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 25 confirm containers."
   $env:conn=(az storage account show-connection-string --name $env:blobstg --resource-group $env:rg | jq '.connectionString')
   write-output "az storage container list  --account-name $($env:blobstg)"
   az storage container list --account-name $($env:blobstg)  --connection-string $env:conn
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 26 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 26 manual deploy, this prompts for a passwoprd and does not work."
   write-output "curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-webapp.zip"
   curl -X POST -u sheintze https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/api/zipdeploy -T publish-webapp.zip
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 27 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 27 manual deploy"
   $publishUrl = "https://zipdeployhttpfunc20240529150920.scm.azurewebsites.net/msdeploy.axd?site=<yourappname>"
   $zipPath = "publish-webapp.zip"
   $deployUser = "sheintze@hotmail.com"
   $deployPassword = "\"
   "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:package="$zipPath" -dest:auto,computerName="$publishUrl",userName="$deployUser",password="$deployPassword",authtype="Basic"
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 28 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "curl -X GET 'https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried'"
   curl -X GET "https://zipdeployhttpfunc20240529150920.azurewebsites.net/api/zipdeployhttpfunc?code=n4uvzuVpQ5iOuEMSSROOSKMD-oW7wBPKfYoEMdA9TQh5AzFuvby8Bg%3D%3D&name=siegfried"
   write-output "Built at Fri May 31 05:52:32 2024 Hello, siegfried. This HTTP triggered function executed successfully.2024 Jun 03 12:45:03.216 AM (+00:00)Name   "
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 29 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 29 delete storage account"
   write-output "az storage account delete -n $($env:blobstg) -g $env:rg --yes"
   az storage account delete -n $env:blobstg -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 30 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 30 delete storage account"
   write-output "az storage account delete -n $($env:storageAccountName) -g $env:rg --yes"
   az storage account delete -n $env:storageAccountName -g $env:rg --yes
   End commands to deploy this file using Azure CLI with PowerShell

   emacs ESC 31 F10
   Begin commands to deploy this file using Azure CLI with PowerShell
   write-output "Step 31 delete storage account"
   write-output "az webapp delete -n $($env:webAppName) -g $($env:rg)"
   az webapp delete -n $env:webAppName -g $env:rg
   End commands to deploy this file using Azure CLI with PowerShell

   Begin common epilog commands
   write-output "resource group $($env:rg)"
   az resource list -g $env:rg --query "[?resourceGroup=='$env:rg'].{ name: name, flavor: kind, resourceType: type, region: location }" --output table  | ForEach-Object { $_ -replace "`r", ""}
   write-output "all done $(Get-Date)"
   End common epilog commands

 */


//    See https://github.com/Azure-Samples/function-app-arm-templates/blob/main/zip-deploy-arm-az-cli/README.md#steps
// see zip-deploy-arm-az-cli/README.md


@description('The name of the Azure Function app.')
param webAppName string 

@description('The zip content url.')
param packageUri string 

output outpackageUri string = packageUri
output outwebAppName string = webAppName

// https://github.com/projectkudu/kudu/wiki/MSDeploy-VS.-ZipDeploy#zipdeploy MSDeploy does not work with WEBSITE_RUN_FROM_PACKAGE=1.
resource webAppName_ZipDeploy 'Microsoft.Web/sites/extensions@2021-02-01' = {
  name: '${webAppName}/ZipDeploy'
  properties: {
    packageUri: packageUri
  }
}

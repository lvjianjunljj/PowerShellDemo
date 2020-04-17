<#
.SYNOPSIS
    Download all Logic Apps from an Azure resource group in ARM template form.
.LINKS
    How To: Version & Deploy Onboarding Logic Apps from PPE to Prod
    https://microsoft.sharepoint.com/teams/Office365CoreSharedDataEngineeringManagers/_layouts/OneNote.aspx?id=%2Fteams%2FOffice365CoreSharedDataEngineeringManagers%2FShared%20Documents%2FOnboarding%2FDev%20Document&wd=target%28Dev%20Investigations.one%7CC5FB23FE-0F1B-488E-A43D-2C085B021779%2FHow%20To%3A%20Version%20%26%20Deploy%20Onboarding%20Logic%20Apps%20from%20PPE%7CA9FC1873-1437-4F1A-999D-FC6A7C439208%2F%29
#>
param(
    [string]$subscriptionName = "IDEAs",
    [string]$resourceGroup = "IdeasOnboarding",
    [string]$subscriptionId = "7fa7b101-ac8f-4d68-9dd9-12134cb47603",
    [string]$templateRootPath = ".\nestedtemplates"
)

### BEGIN FUNCTIONS ####################################################

function Check-AzureSession () {
    # Logged into Azure for PowerShell operations?
    if (!(Get-AzContext)) {
        Write-Host "Logging into Azure for PowerShell operations."
        Connect-AzAccount
    }

    # Logged into Azure for armclient operations?
    $noLoginToken = 'There is no login token.  Please login to acquire token.'
    if ((armclient listcache) -eq $noLoginToken) {
        Write-Host "Logging into Azure for armclient operations."
        armclient login

        # Success?
        if ((armclient listcache) -eq $noLoginToken) {
            throw "You must login to Azure for armclient operations!"
        }
    }
}

function DownloadLogicAppARMTemplate
{
    Param(
        [parameter(Mandatory=$true)][String] $subscriptionId, 
        [parameter(Mandatory=$true)][String] $resourceGroup, 
        [parameter(Mandatory=$true)][String] $logicApp, 
        [parameter(Mandatory=$true)][String] $templatePath
    )
    
    $templateFile = "$templatePath\$logicApp.json"
    $paramFile = "$templatePath\$logicApp.parameters.json"

    New-Item -ItemType directory -Path $templatePath -Force

    Write-Host "Fetching... $($logicApp) => $($templateFile)"
    
    armclient token $subscriptionId | Get-LogicAppTemplate -LogicApp $logicApp -ResourceGroup $resourceGroup -SubscriptionId $subscriptionId -Verbose | Out-File $templateFile
    
    Get-ParameterTemplate -TemplateFile $templateFile | Out-File $paramFile
}

### END FUNCTIONS ####################################################

if (!(Test-Path -Path $templateRootPath)) {
    throw "The templateRootPath cannot be found: $templateRootPath"
}

$templateRootPath = Resolve-Path $templateRootPath

Check-AzureSession

Select-AzSubscription -SubscriptionName $subscriptionName

# Get LogicApps to download from resource group
$logicApps = Get-AzResource -ResourceGroupName $resourceGroup -ResourceType "Microsoft.Logic/workflows" | select -ExpandProperty Name

<#
TESTING: Get LogicApps ordered by ChangedTime. Useful to see which ones have changed recently

$logicApps | ForEach-Object{ Get-AzLogicApp -ResourceGroupName $resourceGroup -Name $_ | select Name, ChangedTime } | Sort-Object -Property ChangedTime -Descending
Get-AzResource -ResourceGroupName $resourceGroup -ResourceType "Microsoft.Logic/workflows" | ForEach-Object{ Get-AzLogicApp -ResourceGroupName $resourceGroup -Name $_.Name | select Name, ChangedTime } | Sort-Object -Property ChangedTime -Descending
#>

$logicApps = "MetagraphOnboardRequestResponse"

# Download logic apps
$logicApps | ForEach-Object{ DownloadLogicAppARMTemplate $subscriptionId $resourceGroup $_ $templateRootPath }


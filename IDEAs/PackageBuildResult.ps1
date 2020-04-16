<#
.SYNOPSIS
    Package the IDEAs project build reuslt by power shell.
#>
param(
    [string]$ServiceFilesPrefix = "D:\IDEAs\Ibiza\Source\Services\DataCop\",
    [string]$ServiceFilesSuffix = "\bin\Release\*",
    [string]$TargetZipFilePrefix = "D:\IDEAs\Build\DeployZip\",
    [string]$TargetZipFileSuffix = ".zip"
)

### BEGIN FUNCTIONS ####################################################

function PackageAllFile ([string]$souceFile, [string]$targetZipFile) {
    # Will throw exception when file not existing
    # Remove-Item -Path $targetZipFile -Recurse -Force
    Compress-Archive -Path $souceFile -DestinationPath $targetZipFile
}

function DelAllFileInOrder ([string]$targetFolder) {
    $Files = get-childitem $targetFolder -force
    Foreach ($File in $Files)
    {
        $FilePath=$File.FullName
        Remove-Item -Path $FilePath -Recurse -Force
    }
}

DelAllFileInOrder $TargetZipFilePrefix
PackageAllFile $ServiceFilesPrefix"AdlsMetadataCacher"$ServiceFilesSuffix $TargetZipFilePrefix"AdlsMetadataCacher"$TargetZipFileSuffix
PackageAllFile $ServiceFilesPrefix"AdlsWorker"$ServiceFilesSuffix $TargetZipFilePrefix"AdlsWorker"$TargetZipFileSuffix
PackageAllFile $ServiceFilesPrefix"CosmosWorker"$ServiceFilesSuffix $TargetZipFilePrefix"CosmosWorker"$TargetZipFileSuffix
PackageAllFile $ServiceFilesPrefix"OndemandDataCopService"$ServiceFilesSuffix $TargetZipFilePrefix"OndemandDataCopService"$TargetZipFileSuffix
PackageAllFile $ServiceFilesPrefix"Orchestrator"$ServiceFilesSuffix $TargetZipFilePrefix"Orchestrator"$TargetZipFileSuffix
PackageAllFile $ServiceFilesPrefix"DataCopIcMAlertSync"$ServiceFilesSuffix $TargetZipFilePrefix"DataCopIcMAlertSync"$TargetZipFileSuffix
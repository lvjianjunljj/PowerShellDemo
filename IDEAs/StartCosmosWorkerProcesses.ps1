### Stop all the cosmos worker processes before starting this power shell script
<#
.SYNOPSIS
    Package the IDEAs project build reuslt by power shell.
#>
param(
    [int]$processCount = 2,
    [string]$BuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
    [string]$RepoFolder = "D:\IDEAs\repos\Ibiza\",
    [string]$ReleaseFolderRelativePath = "Source\Services\DataCop\CosmosWorker\bin\Release\",
    [string]$CsprojFileRelativePath = "Source\Services\DataCop\CosmosWorker\CosmosWorker.csproj",
    [string]$WorkerFolderPrefix = "D:\test_",
    [string]$AppId = "",
    [string]$AppKey = ""
)

set-alias MSBuild $BuildPath
Push-Location $RepoFolder
git pull
MSBuild $RepoFolder$CsprojFileRelativePath -t:rebuild /p:Configuration=Release

for ($index = 0; $index -lt $processCount; $index++)
{
    $WorkerFolder = "$WorkerFolderPrefix$index"
    Remove-Item $WorkerFolder -Recurse -Force -Confirm:$false
    Mkdir $WorkerFolder
    Copy-Item -Path $RepoFolder$ReleaseFolderRelativePath"*" -Destination $WorkerFolder -Recurse
    Start-Process -FilePath $WorkerFolder"\CosmosWorker.exe" -ArgumentList "--appid $AppId --appkey $AppKey"
}
<#
.SYNOPSIS
    Checkout and pull code for all repos in the root folder.
#>
param(
    [string]$RootFolder = "D:\IDEAs\pls_repos\"
)

### BEGIN FUNCTIONS ####################################################
$Repos = get-childitem $RootFolder -Directory
cd $RootFolder
Foreach ($Repo in $Repos)
{
    $RepoPath=$Repo.FullName
    cd $RepoPath
    git checkout .
    git clean -df
    git pull
    cd ..
}

# ---------------------------------------------------------------------------------- 
    # Copyright (c) Microsoft Corporation. All rights reserved.
    # Licensed under the MIT License. See License.txt in the project root for
    # license information.
# ---------------------------------------------------------------------------------- 

<#

.SYNOPSIS
    Powershell script that copies newly recorded session records from source to destination

.DESCRIPTION
    This script copies newly recorded session records from source to destination

.PARAMETER SourceRootDirectory
    Full path to directory where session records are (usually the bin directory of recorded test)

.PARAMETER DestinationRootDirectory
    Location where to copy the files
#>

[cmdletbinding(SupportsShouldProcess=$True)]
Param(
    [Parameter(Mandatory = $true, HelpMessage="The source directory; usually under bin/ where tests are recorded")]
    [string] $SourceRootDirectory,
    [Parameter(Mandatory = $true, HelpMessage="The destination directory; usually where the committed session records files are")]
    [string] $DestinationRootDirectory
)

$srcFiles = (Get-ChildItem -Path $SourceRootDirectory -Recurse) | Where-Object {$_ -is [System.IO.FileInfo]}
if($srcFiles.Count -eq 0)
{
    Write-Host "No json files found under $SourceRootDirectory. Skipping Copy"
}

$destFiles = (Get-ChildItem -Path $DestinationRootDirectory -Recurse) | Where-Object {$_ -is [System.IO.FileInfo]}
if($destFiles.Count -eq 0)
{
    Write-Host "No json files found under $DestinationRootDirectory. Skipping Copy"
}

Write-Host "Script decides what files to copy based on the LastWriteTime timestamp."

foreach($srcFile in $srcFiles)
{
    foreach($destFile in $destFiles)
    {
        if($srcFile.Name -eq $destFile.Name)
        {
            if($srcFile.LastWriteTime -gt $destFile.LastWriteTime)
            {
                Write-Host "Source file last modified:"
                Write-Host "$($srcFile.LastWriteTime)" -ForegroundColor Green -BackgroundColor Yellow
                Write-Host "Destination file last modified:"
                Write-Host "$($destFile.LastWriteTime)" -ForegroundColor Green -BackgroundColor Yellow

                if ($PSBoundParameters.ContainsKey('WhatIf'))
                {
                    Copy-item -Path $srcFile.FullName -Destination $destFile.FullName -WhatIf
                } 
                elseif ($PSBoundParameters.ContainsKey('Confirm'))
                {
                    Copy-item -Path $srcFile.FullName -Destination $destFile.FullName -Confirm
                }
                else
                {
                    Write-Host "Copying source file:" 
                    Write-Host "$($srcFile.FullName)" -ForegroundColor Green
                    Write-Host "To destination:"
                    Write-Host "$($destFile.FullName)" -ForegroundColor Green
                    Copy-item -Path $srcFile.FullName -Destination $destFile.FullName -Force
                }
            }
            elseif($srcFile.LastWriteTime -lt $destFile.LastWriteTime)
            {
                Write-Host "Source File:"
                Write-Host "$($srcFile.FullName)" -ForegroundColor Red
                Write-Host "has a last write time of"
                Write-Host "$($srcFile.LastWriteTime)" -ForegroundColor Red
                Write-Host "which is less than"
                Write-Host "Destination File:"
                Write-Host "$($destFile.FullName)" -ForegroundColor Red
                Write-Host "has a last write time of"
                Write-Host "$($destFile.LastWriteTime)" -ForegroundColor Red
                Write-Host "Skipping copy"
            }
        }
    }
}
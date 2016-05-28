# Requirements
. "$PSScriptRoot\New-TempFolder.ps1"

Function Get-GitHubRepo
{
    <#
    .SYNOPSIS
        Downloads the files from a GitHub Responsitory without the .git directory.
    .EXAMPLE
        Get-GitHubRepo "https://github.com/LacledesLAN/gameserver_common" "C:\repo"
    .PARAMETER url
        The GitHub repository to download.
    .PARAMETER destinationPath
        The destination directory for the downloaded repository.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage='Enter the URI of the GITHub repo you would like to download.')]
        [ValidateScript({((Invoke-WebRequest -uri $_.ToString()).StatusCode -eq 200)})]
        [ValidateLength(8,172)]
        [string]$url,

        [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage='What destination would you like the repo download into?')]
        [ValidateScript({Test-Path $_ -PathType 'Container'})] 
        [string]$destinationPath = $null
    )

    Begin
    {
        # Find location of GIT executable
        if ($env:GitExe -eq $null)
        {
            If (Test-Path ${env:ProgramFiles}\Git\cmd\git.exe)
            {
                $env:GitExe = "${env:ProgramFiles}\Git\cmd\git.exe"
            }
            ElseIf (Test-Path ${env:ProgramFiles(x86)}\Git\cmd\git.exe)
            {
                $env:GitExe = "${env:ProgramFiles(x86)}\Git\cmd\git.exe"
            }
            Else
            {
                $env:GitExe = $null
                Write-Error "GIT executable not found. Aborting!"
                Exit 1
            }
        }
    }

    Process
    {
        $startTime = Get-Date

        # Create temporary folder
        $tempFolder = New-TempFolder

        #region Download to temporary folder

            $timerun = Measure-Command { $process = Start-Process -FilePath $env:GitExe -ArgumentList "clone $url $tempFolder" -Wait -NoNewWindow -PassThru }
            Write-Verbose "Downloaded GitHub repo `$url` in $timerun"

            if ($process.ExitCode -ne 0) {
                Write-Error "Could not download GitHub respository."
                exit 1
            }

            # Remove GIT repo specific files
            Remove-Item -Path ("$tempFolder" + [System.IO.Path]::DirectorySeparatorChar + ".git") -Force -Recurse
            Remove-Item -Path ("$tempFolder" + [System.IO.Path]::DirectorySeparatorChar + "readme.md") -Force

        #endregion

        #region Copy from temporary folder to destination

            $argumentList = "$tempFolder\ $destinationPath /MIR /S"
            $timerun = Measure-Command { $process = Start-Process robocopy -ArgumentList $argumentList -Wait -NoNewWindow -PassThru }
            Write-Verbose "Relevant repo files copied from temporary folder to destination in $timerun"

            # Remove temporary folder
            Remove-Item -Path $tempFolder -Force -Recurse

        #endregion

        # Display appropriate exit message
        switch ($process.ExitCode)
        {
            0 { Write-Host "Successful. Up to date files already existed in the destination directory. Completed in $timerun" }
            1 { Write-Host "Successful. Repo download completed in $timerun" }
            2 { Write-Host "Successful. There are some additional files in the destination directory that are not present in the repo. No new were copied. Completed in $timerun" }
            3 { Write-Host "Successful. Some files were copied others were already present. No failure was encountered. Completed in $timerun" }
            5 { Write-Host "Successful. Some files were copied while others were updated. No failure was encountered. Completed in $timerun" }
            6 { Write-Host "Successful. The files already exist in the destination directory. Completed in $timerun" }
            7 { Write-Host "Successful. Files were copied, a file mismatch was present, and additional files were present. Completed in $timerun" }
            8 { Write-Warning "Warning. Several files did not copy. Completed in $timerun" }
            default {  
                Write-Error "Error. Files did not complete successfully."
                Exit 1
            }
        }
    }

    End
    {
        Remove-Variable argumentList
        Remove-Variable process -Force
        Remove-Variable startTime
        Remove-Variable tempFolder
        Remove-Variable timerun
    }
}
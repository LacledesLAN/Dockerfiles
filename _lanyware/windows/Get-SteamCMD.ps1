# Requirements
. "$PSScriptRoot\New-TempFolder.ps1"

Function Get-SteamCMD
{
    <#
    .SYNOPSIS
        Downloads SteamCMD to the specified destination
    .EXAMPLE
        Get-GitHubRepo "C:\steamcmd"
    .PARAMETER destinationPath
        The destination directory for SteamCMD.
    .PARAMETER CreateDirectory
        Create the destination directory if the leaf does not exist in the file system
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$False, HelpMessage='What destination would you like SteamCMD download into?')]
        [string[]]$destinationDirectory = $null,
        
        [Parameter(Mandatory=$False, HelpMessage='aa')]
        [switch]$CreateDirectory=$false,

        [Parameter(Mandatory=$False, HelpMessage='abc')]
        [switch]$OverwriteExisting=$false,

        [Parameter(Mandatory=$False, HelpMessage='Allows the cmdlet to overwrite read-only items.')]
        [switch]$Force=$false
    )

    Begin
    {
        #Get date-time SteamCMD was last modified by Valve
        $SteamCMDModfieid = (Invoke-WebRequest -Method HEAD -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip").Headers."Last-Modified"
    }

    Process
    {
        #region Validate destination directory
            if (!(Test-Path $destinationDirectory -PathType 'Container'))
            {
                if (Test-Path $destinationDirectory -PathType 'Leaf')
                {
                    Throw "Cannot download SteamCMD. ""$destinationDirectory"" is a file, not a folder."
                }

                if ($CreateDirectory)
                {
                    Try
                    {
                        New-Item -ItemType directory -Path $destinationDirectory -Force:$Force
                    }
                    Catch
                    {
                        Throw "Could not create directory ""$destinationDirectory"". => $_.Exception.Message"
                    }
                }
                else
                {
                    Throw "Cannot download SteamCMD. ""$destinationDirectory"" does not exist. Use the -CreateDirectory switch to create it."
                }
            }

            $destinationDirectory = $destinationDirectory + [System.IO.Path]::DirectorySeparatorChar
            $destinationDirectory = $destinationDirectory.Replace([System.IO.Path]::DirectorySeparatorChar + [System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)
        #endregion

        #region Check if SteamCMD already exists in the destination and is relatively new
        
            
            

        #endregion



        $zipFile = $destinationDirectory + "steamcmd.zip"

        if (Test-Path $zipFile)
        {
            Remove-Item -Path $zipFile -Force:$Force | Out-Null
        }

        #Download
        Invoke-WebRequest -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile $zipFile

        #Extract zipped contents
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($zipFile)

        foreach($item in $zip.items())
        {
            $destinationFile = $destinationDirectory + $item.Name

            if (Test-Path $destinationFile)
            {
                Remove-Item -Path $destinationFile -Force | Out-Null
            }

            $shell.Namespace($destinationDirectory).copyhere($item)
        }

        Remove-Item -Path $zipFile -Force | Out-Null
    }

    End
    {
        Remove-Variable CreateDirectory
        Remove-Variable destinationFile
        Remove-Variable destinationPath
        Remove-Variable Force
        Remove-Variable item
        Remove-Variable shell
        Remove-Variable SteamCMDModfieid
        Remove-Variable zip
        Remove-Variable zipFile
    }
}

clear

Get-SteamCMD "Z:\test"

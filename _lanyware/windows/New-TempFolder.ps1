Function New-TempFolder
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$False, HelpMessage='Prefix (if any) for temporary folder.')]
        [ValidateLength(1,4)]
        [string] $prefix = "LL"
    )
    
    Process
    {
        $count = 0
        do
        {
            $count++
            $tempFolder = $env:TEMP + [System.IO.Path]::DirectorySeparatorChar + "$prefix-" + ([GUID]::NewGuid()).GUID.ToUpper()

            if ($count -gt 9)
            {
                Write-Error "Unable to create temporary folder after $count tries. Aborting!"
                exit 1
            }

        } until (!(Test-Path $tempFolder))

        return New-Item -Path $tempFolder -ItemType Directory
    }
}

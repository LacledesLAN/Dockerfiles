

$sourceDir = (Get-Item -Path ".\" -Verbose).FullName + [IO.Path]::DirectorySeparatorChar;
$sourceDrive = (Get-Item -Path $sourceDir).PSDrive.Root

##############################################################
## Verify Docker is Installed and Running
##############################################################
    $output = docker info 2>&1

    if(!$?)
    {
        $output = docker 2>&1
        if (!$?) {
            Write-Host "Docker must be installed and running!"
        }
        else
        {
            Write-Host "Docker must be running!"
        }
        
        exit;
    }

##############################################################
## Verify source drive is shared with current Windows user
## (this is how the Docker VM accesses it to mount a volume)
##############################################################
    Write-Host "";
    Write-Host "Checking that the appropriate drive is shared..."; 
    
    #This isn't a gaurnteed check; still need to verify current user can access the share
    
    if ((Get-WmiObject -Class Win32_Share | Where {$_.Path -eq "$sourceDrive"} | Where {$_.Type -eq 0 } | Measure).Count -lt 1) {
        Write-Host "Drive containing the repository ($sourceDrive) must be shared with the current user!";
        exit;
    }

##############################################################
## Launch the container
##############################################################
    if ([IO.Path]::DirectorySeparatorChar -ne "/") {
        $volDir = $sourceDir.Replace([IO.Path]::DirectorySeparatorChar, "/");
    } else {
        $volDir = $sourceDir;
    }

    $containerName = (Get-Item -Path ".\" -Verbose).Name + "-" + (Get-Date).Ticks

    Write-Host "Starting Container: '$containerName'"
    
    $command = "docker run -it --rm --name $containerName -v " + '"' + "$sourceDir" + ':' + '/LANYWARE/' + '" ' + "ubuntu:latest"
    write-host $command;

    Invoke-Expression $command;
    
    if(!$?)
    {
        Write-Host "Something went wrong"
        exit;
    }


##############################################################
## Stop the container
##############################################################

    Write-Host "Stopping container: '$containerName'"

    $command = "docker stop $containerName"
    Invoke-Expression $command | Out-Null


Write-Host "============="
Write-Host ""
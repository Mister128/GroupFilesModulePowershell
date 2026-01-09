function Group-Files {
    <#
    .SYNOPSIS
        Moving files in difference directory.
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    
    
    [CmdletBinding()]
    param (
        [string[]]$Only,
        [switch]$Force
    )
    
    begin {
        Write-Verbose "Starting sort file(s)"
    }
    
    process {
        # init config files and check their exist
        $configCreateDirs = "./ConfCreateDirectories.json"
        $configSearchDirs = "./ConfSearchDirectories.json"
        if (-not (Test-Path $configCreateDirs) -or -not (Test-Path $configSearchDirs)) {
            Write-Error "One or both config files are missing!"
            return
        } else {
            $configCreateDirs = Get-Content $configCreateDirs | ConvertFrom-Json
            $configSearchDirs = Get-Content $configSearchDirs | ConvertFrom-Json
        }

        $files = Get-ChildItem -File # all files in current location
        $directories = Get-ChildItem -Directory | Where-Object { -not $_.Name.StartsWith('.') } # all directories in current location
        foreach ($category in $configSearchDirs.SearchDirectories.PSObject.Properties) { 
            $allowedExtentions = $category.Name -split "/"
            $currentFiles = $files | Where-Object { $_.Extension -in $allowedExtentions } 
            $currentDirectory = @($directories | Where-Object { $_.Name -in $category.Value })[0]

            if (($null -eq $currentDirectory) -and $Force -and $currentFiles) {
                Write-Verbose "We have '-Force' and don't have dir for $currentFiles, so we add this dir"
                $currentDirectory = $configCreateDirs.PSObject.Properties[$category.Name].Value
                mkdir $currentDirectory
            }

            if ($currentDirectory -and $currentFiles) {
                Write-Verbose "Found directory and file(s). Processing $($currentFiles.Count) file(s)."
    
                foreach ($file in $currentFiles) {
                    $destinationPath = Join-Path -LiteralPath $currentDirectory -ChildPath $file.Name

                    if (Test-Path -LiteralPath $destinationPath) {
                        if ($Force) {
                            Write-Verbose "File '$destinationPath' exists. Overwriting."
                            Move-Item -LiteralPath $file.FullName -Destination $destinationPath -Force
                        } else {
                            Write-Verbose "File '$destinationPath' already exists. Skipping (use -Force to overwrite)."
                        }
                    } else {
                        Move-Item -LiteralPath $file.FullName -Destination $destinationPath
                    }
                }
            }
        }
    }
    
    end {
        Write-Verbose "Finish sort file(s)"
    }
}
Group-Files -Force -Verbose
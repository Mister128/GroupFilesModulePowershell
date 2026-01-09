function Group-Files {
    <#
    .SYNOPSIS
        Groups files into directories based on extension rules defined in JSON config files.

    .DESCRIPTION
        Reads ConfSearchDirectories.json to map groups of file extensions to allowed target directory names.
        When the -Force switch is used, it also reads ConfCreateDirectories.json to determine which folder to create
        if no matching directory exists. Files are moved accordingly, with overwrite controlled by -Force.

    .PARAMETER Force
        Creates a target directory if it doesn't exist (using ConfCreateDirectories.json),
        and overwrites destination files if they already exist.

    .PARAMETER Only
        Processes only those extension groups that contain at least one of the specified extensions.
        Extensions must exactly match those in ConfSearchDirectories.json (including the leading dot).
        Example: -Only ".html", ".css"

    .EXAMPLE
        Group-Files -Verbose
        Sorts all files according to configuration, with detailed output.

    .EXAMPLE
        Group-Files -Force
        Sorts files and creates missing directories as needed; overwrites existing files.

    .EXAMPLE
        Group-Files -Only ".html", ".js"
        Sorts only files belonging to categories that include .html or .js extensions.

    .EXAMPLE
        Group-Files -Only ".html" -Force
        Sorts only HTML-related files, creates target directory if missing, and overwrites duplicates.

    .NOTES
        Requires two JSON files in the current working directory:
        - ConfSearchDirectories.json
        - ConfCreateDirectories.json
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
        }
        else {
            $configCreateDirs = Get-Content $configCreateDirs | ConvertFrom-Json
            $configSearchDirs = Get-Content $configSearchDirs | ConvertFrom-Json
        }

        $files = Get-ChildItem -File # all files in current location
        $directories = Get-ChildItem -Directory | Where-Object { -not $_.Name.StartsWith('.') } # all directories in current location
        foreach ($category in $configSearchDirs.SearchDirectories.PSObject.Properties) { 
            if ($Only -and -not (($category.Name -split '/') | Where-Object { $_ -in $Only })) {continue}            
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
                    $destinationPath = Join-Path -Path $currentDirectory -ChildPath $file.Name

                    if (Test-Path $destinationPath) {
                        if ($Force) {
                            Write-Verbose "File '$destinationPath' exists. Overwriting."
                            Move-Item $file -Destination $destinationPath -Force
                        } else {
                            Write-Verbose "File '$destinationPath' already exists. Skipping (use -Force to overwrite)."
                        }
                    } else {
                        Move-Item $file -Destination $destinationPath
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
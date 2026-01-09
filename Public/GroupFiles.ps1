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

    .PARAMETER Config
        Opens the directory containing the configuration files
        (ConfSearchDirectories.json and ConfCreateDirectories.json)

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

    .EXAMPLE
        Group-Files -Config
        Opens the folder containing ConfSearchDirectories.json and ConfCreateDirectories.json for editing.

    .NOTES
        Requires two JSON files in the current working directory:
        - ConfSearchDirectories.json
        - ConfCreateDirectories.json
    #>


    [CmdletBinding()]
    param (
        [String]$Path = ".",
        [string[]]$Only,
        [switch]$Force,
        [switch]$Config
    )

    begin {
        Write-Verbose "Starting sort file(s)"
    }

    process {
        # Init config files and check their exist
        $scriptDir = $PSScriptRoot
        $configCreateDirsPath = Join-Path $scriptDir "ConfCreateDirectories.json"
        $configSearchDirsPath = Join-Path $scriptDir "ConfSearchDirectories.json"
        if (-not (Test-Path $configCreateDirsPath) -or -not (Test-Path $configSearchDirsPath)) {
            throw "One or both config files are missing!"
        }
        else {
            $configCreateDirs = Get-Content $configCreateDirsPath | ConvertFrom-Json
            $configSearchDirs = Get-Content $configSearchDirsPath | ConvertFrom-Json
        }

        if ($Config) {
            Start-Process $scriptDir
            return
        }

        $files = Get-ChildItem $Path -File # all files in location
        $directories = Get-ChildItem $Path -Directory | Where-Object { -not $_.Name.StartsWith('.') } # all directories in  location
        foreach ($category in $configSearchDirs.SearchDirectories.PSObject.Properties) {
            # Skip category if not in '-Only'
            if ($Only -and -not (($category.Name -split "/") | Where-Object { $_ -in $Only })) {continue}

            $allowedExtentions = $category.Name -split "/"
            $currentFiles = $files | Where-Object { $_.Extension -in $allowedExtentions }
            $currentDirectory = @($directories | Where-Object { $_.Name -in $category.Value })[0]

            # If dir for category not exist but flag '-Force' active
            if (($null -eq $currentDirectory) -and $Force -and $currentFiles) {
                Write-Verbose "We have '-Force' and don't have dir for $currentFiles, so we add this dir"
                $currentDirectory = Join-Path $Path $configCreateDirs.PSObject.Properties[$category.Name].Value
                mkdir $currentDirectory
            }
            
            # Moving files
            if ($currentDirectory -and $currentFiles) {
                Write-Verbose "Found directory and file(s). Processing $($currentFiles.Count) file(s)."
                
                foreach ($file in $currentFiles) {
                    $destinationPath = Join-Path $currentDirectory $file.Name

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

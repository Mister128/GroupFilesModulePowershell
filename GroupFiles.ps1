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
        if (-not ((Test-Path $configCreateDirs) -or -not (Test-Path $configSearchDirs)) ) {
            Write-Error "Config file(s) is not exist!"
            exit 1
        }


        if (-not $Force) {
            # json
            $searchDirs = Get-Content $configSearchDirs | ConvertFrom-Json
            
            # all allowed names of directories and extentions of files
            $allowedNames = @()
            $allowedExtentions = @()
            foreach ($category in $searchDirs.SearchDirectories.PSObject.Properties) {
                $allowedNames += $category.Value
                $allowedExtentions += $category.Name -split "/"
            }

            # current directories
            $folders = Get-ChildItem -Directory | Where-Object {
                -not $_.Name.StartsWith('.') -and
                $_.Name.ToLower() -in $allowedNames
            }            

            # current extentions
            $extentions = Get-ChildItem -File | Where-Object {$_.Extension -in $allowedExtentions}  
            
            # проходимся по всем спискам json и к каждому подбираем свою директорию
        } else {
            
        }
        
    }
    
    end {
        
    }
}
Group-Files
Describe "Group-Files" {
    BeforeEach {
        # Create a temporary test directory
        $TestDrivePath = New-Item "TestDrive:/TestFolder" -ItemType Directory -Force
        Push-Location $TestDrivePath.FullName

        # Copy configuration files to test location
        Copy-Item "$PSScriptRoot/../Public/ConfSearchDirectories.json" -Destination .
        Copy-Item "$PSScriptRoot/../Public/ConfCreateDirectories.json" -Destination .
    }

    AfterEach {
        # Clean up by removing all items in the test directory
        Get-ChildItem -Path . -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Pop-Location
    }

    Context "Basic functionality" {
        It "Should sort files into existing directories" {
            # Create test files and directories
            New-Item "test.png" -ItemType File
            New-Item "test.jpeg" -ItemType File
            New-Item "picture" -ItemType Directory

            # Run the function
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Verbose:$false

            # Check if files were moved to the correct directory
            "picture/test.png" | Should Exist
            "picture/test.jpeg" | Should Exist
            "test.png" | Should not Exist
            "test.jpeg" | Should not Exist
        }

        It "Should handle multiple file types" {
            # Create test files and directories
            New-Item "style.css" -ItemType File
            New-Item "script.js" -ItemType File
            New-Item "index.html" -ItemType File
            New-Item "css" -ItemType Directory
            New-Item "js" -ItemType Directory
            New-Item "html" -ItemType Directory

            # Run the function
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Verbose:$false

            # Check if files were moved to the correct directories
            "css/style.css" | Should Exist
            "js/script.js" | Should Exist
            "html/index.html" | Should Exist
            "style.css" | Should not Exist
            "script.js" | Should not Exist
            "index.html" | Should not Exist
        }
    }

    Context "With -Force parameter" {
        It "Should create directory if it doesn't exist" {
            # Create test files but no target directory
            New-Item "test.png" -ItemType File
            New-Item "test.jpeg" -ItemType File

            # Run the function with -Force
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Force -Verbose:$false

            # Check if the pictures directory was created and files were moved
            "pictures/test.png" | Should Exist
            "pictures/test.jpeg" | Should Exist
            "test.png" | Should not Exist
            "test.jpeg" | Should not Exist
        }

        It "Should overwrite existing files with -Force" {
            # Create test files and target directory with an existing file
            New-Item "test.png" -ItemType File
            New-Item "picture" -ItemType Directory
            New-Item "picture/existing.png" -ItemType File

            # Run the function with -Force
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Force -Verbose:$false

            # Check if both files are in the target directory
            "picture/test.png" | Should Exist
            "picture/existing.png" | Should Exist
            "test.png" | Should not Exist
        }
    }

    Context "With -Only parameter" {
        It "Should only process specified file extensions" {
            # Create test files for different categories
            New-Item "style.css" -ItemType File
            New-Item "script.js" -ItemType File
            New-Item "test.png" -ItemType File
            New-Item "css" -ItemType Directory
            New-Item "js" -ItemType Directory

            # Run the function with -Only to process only CSS files
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Only ".css" -Verbose:$false

            # Check that only CSS file was moved
            "css/style.css" | Should Exist
            "style.css" | Should not Exist
            "script.js" | Should Exist  # JS file should remain in original location
            "test.png" | Should Exist  # PNG file should remain in original location
        }

        It "Should process multiple specified extensions" {
            # Create test files for different categories
            New-Item "style.css" -ItemType File
            New-Item "script.js" -ItemType File
            New-Item "test.png" -ItemType File
            New-Item "css" -ItemType Directory
            New-Item "js" -ItemType Directory

            # Run the function with -Only to process CSS and JS files
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Only .css, .js -Verbose:$false

            # Check that CSS and JS files were moved, but PNG remained
            "css/style.css" | Should Exist
            "js/script.js" | Should Exist
            "style.css" | Should not Exist
            "script.js" | Should not Exist
            "test.png" | Should Exist  # PNG file should remain in original location
        }
    }

    Context "Error handling" {
        It "Should not overwrite existing files without -Force" {
            # Create test files and target directory with an existing file having the same name
            New-Item "test.png" -ItemType File
            New-Item "picture" -ItemType Directory
            New-Item "picture/test.png" -ItemType File

            # Run the function without -Force
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Verbose:$false

            # Both files should exist (original and duplicate in target directory)
            # The original file should remain in place since we didn't use -Force
            "test.png" | Should Exist
            "picture/test.png" | Should Exist
        }
    }

    Context "Path parameter" {
        It "Should work with custom path" {
            $customPath = New-Item "TestDrive:/CustomPath" -ItemType Directory
            Push-Location $customPath.FullName

            # Copy config files to custom path
            Copy-Item "$PSScriptRoot/../Public/ConfSearchDirectories.json" -Destination .
            Copy-Item "$PSScriptRoot/../Public/ConfCreateDirectories.json" -Destination .

            # Create test files and directory
            New-Item "test.png" -ItemType File
            New-Item "picture" -ItemType Directory

            # Run the function with custom path
            . "$PSScriptRoot/../Public/GroupFiles.ps1"
            Group-Files -Path $customPath -Verbose:$false

            # Check if files were moved to the correct directory
            "picture/test.png" | Should Exist
            "test.png" | Should not Exist

            Pop-Location
        }
    }
}
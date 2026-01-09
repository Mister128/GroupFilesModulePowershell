# GroupFiles Module for PowerShell

A PowerShell module that organizes files into directories based on their extensions using configurable rules.

## Description

The GroupFiles module helps you organize your files by automatically moving them into appropriate directories based on their file extensions. It uses JSON configuration files to define which extensions belong to which directories, allowing for flexible and customizable file organization.

## Features

- **Automatic file sorting**: Moves files into directories based on their extensions
- **Flexible configuration**: Define custom extension-to-directory mappings via JSON files
- **Directory creation**: Optionally create target directories if they don't exist
- **Selective processing**: Process only specific file extensions using the `-Only` parameter
- **Safe operation**: Prevents overwriting existing files by default (use `-Force` to override)
- **Customizable paths**: Specify which directory to process (defaults to current directory)

## Installation

1. Clone or download this repository
2. Place the `GroupFiles` folder in your PowerShell modules directory:
   - Personal: `C:\Users\[YourUsername]\Documents\PowerShell\Modules\`
   - System-wide: `$PSHOME\Modules\`
3. Import the module in PowerShell:
   ```powershell
   Import-Module GroupFiles
   ```

## Usage

### Basic Usage
```powershell
# Sort all files in the current directory based on configuration
Group-Files

# Sort files in a specific directory
Group-Files -Path "C:\MyFolder"
```

### Advanced Options
```powershell
# Create directories if they don't exist and overwrite existing files
Group-Files -Force

# Process only specific file extensions
Group-Files -Only ".html", ".css", ".js"

# Process specific extensions with directory creation
Group-Files -Only ".png", ".jpg" -Force

# Open the configuration directory to edit JSON files
Group-Files -Config
```

### Parameters

- **`-Path`**: Specifies the directory to process (default: current directory)
- **`-Only`**: Process only files with specified extensions (e.g., `".html", ".css"`)
- **`-Force`**: Create target directories if they don't exist and overwrite existing files
- **`-Config`**: Opens the configuration directory containing JSON files

## Configuration

The module uses two JSON configuration files located in the Public directory:

### ConfSearchDirectories.json
Defines which extensions map to which existing directory names:
```json
{
    "SearchDirectories": {
        ".png/.jpeg": [
            "picture",
            "photo",
            "photos",
            "pic",
            "pics",
            "image",
            "images"
        ],
        ".html": [
            "html"
        ],
        ".css": [
            "css",
            "style",
            "styles"
        ]
    }
}
```

### ConfCreateDirectories.json
Defines what to name newly created directories for each extension group:
```json
{
    ".png/.jpeg": "pictures",
    ".html": "html",
    ".css": "css",
    ".js": "js",
    ".mp3/.ogg": "musics"
}
```

## Examples

```powershell
# Sort all files in current directory with verbose output
Group-Files -Verbose

# Sort only HTML and CSS files
Group-Files -Only ".html", ".css"

# Sort files, create directories if needed, and overwrite existing files
Group-Files -Force

# Sort only JavaScript files in a specific directory
Group-Files -Path "C:\Project" -Only ".js" -Force
```

## Testing

The module includes Pester tests in the `Test` directory. To run the tests:
```powershell
# Install Pester if not already installed
Install-Module -Name Pester -Force

# Run tests
Invoke-Pester -Path ".\Test\Test.ps1"
```

## License

This project is open source and available under the MIT License.

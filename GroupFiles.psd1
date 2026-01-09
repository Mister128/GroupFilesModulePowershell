@{
    ModuleVersion = '1.0'
    RootModule    = 'GroupFiles.psm1'
    
    Author = 'Alexey Kudryakov (Mister Y)'
    Description = 'Groups files into directories based on JSON rules'
    
    PowerShellVersion = '7.0'
    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport = 'Group-Files'
    CmdletsToExport   = @()
    AliasesToExport   = @()
    PrivateData = @{
        PSData = @{
            Tags = @('files', 'organize', 'sort')
            
        }
    }
}
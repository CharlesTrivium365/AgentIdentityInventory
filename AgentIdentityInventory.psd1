@{
    RootModule        = 'AgentIdentityInventory.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b1e7c3a2-4f6d-4c58-9a21-0d9f2e7c8a13'
    Author            = 'Charles Jenkins'
    Copyright         = 'Copyright (c) 2026 Charles Jenkins. Licence MIT.'
    Description       = 'Outil PowerShell en lecture seule qui inventorie les identites d''agents Microsoft Entra Agent ID via Microsoft Graph.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-AgentIdentityInventory')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('Microsoft365', 'Copilot', 'CopilotStudio', 'EntraAgentID', 'MicrosoftGraph', 'Governance')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://trivium365.com/blog/agent-copilot-studio-qui-grossit-architecture/'
        }
    }
}

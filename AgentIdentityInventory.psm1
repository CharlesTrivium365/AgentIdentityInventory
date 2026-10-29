#
# AgentIdentityInventory.psm1
# Inventaire en lecture seule des identites d'agents Microsoft Entra Agent ID.
#

function Get-ItemValue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $Item,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Key
    )

    if ($Item.Contains($Key)) {
        return $Item[$Key]
    }

    return $null
}

function ConvertTo-InventoryObject {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Category,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary] $Item
    )

    return [pscustomobject]@{
        Category    = $Category
        DisplayName = Get-ItemValue -Item $Item -Key 'displayName'
        Id          = Get-ItemValue -Item $Item -Key 'id'
        AppId       = Get-ItemValue -Item $Item -Key 'appId'
    }
}

function Get-GraphCollection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Uri
    )

    $items = [System.Collections.Generic.List[object]]::new()
    $nextLink = $Uri

    while (-not [string]::IsNullOrEmpty($nextLink)) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $nextLink -ErrorAction Stop

        if ($response.ContainsKey('value')) {
            foreach ($entry in $response['value']) {
                $items.Add($entry)
            }
        }

        if ($response.ContainsKey('@odata.nextLink')) {
            $nextLink = [string]$response['@odata.nextLink']
        }
        else {
            $nextLink = $null
        }
    }

    return $items
}

function Get-AgentIdentityInventory {
    <#
    .SYNOPSIS
        Inventorie en lecture seule les identites d'agents Microsoft Entra Agent ID d'un locataire.

    .DESCRIPTION
        Get-AgentIdentityInventory interroge Microsoft Graph et retourne la liste des identites
        d'agents Microsoft Entra Agent ID enregistrees dans le locataire. La commande est en lecture
        seule : elle ne cree, ne modifie et ne supprime aucune ressource.

        Par defaut la commande interroge le point d'acces v1.0 des identites d'agents. Des commutateurs
        ajoutent les plans d'identites d'agents et le catalogue des packages d'agents. La commande peut
        aussi produire un rapport HTML simple.

        La commande utilise le module Microsoft.Graph (Connect-MgGraph et Invoke-MgGraphRequest). Si
        aucune session Graph n'est active une connexion est ouverte avec les permissions requises.

    .PARAMETER IncludeBlueprints
        Ajoute les plans d'identites d'agents interroges sur le point d'acces
        applications/microsoft.graph.agentIdentityBlueprint. Requiert la permission
        AgentIdentityBlueprint.Read.All.

    .PARAMETER IncludePackages
        Ajoute le catalogue des packages d'agents interroge sur le point d'acces
        copilot/admin/catalog/packages. Requiert la permission CopilotPackages.Read.All et le role
        AI Administrator. Cette API est en preversion et exige une licence Microsoft Agent 365.

    .PARAMETER HtmlReportPath
        Chemin d'un fichier HTML a produire. Le rapport reprend les objets retournes. Aucun fichier
        n'est produit lorsque ce parametre est absent.

    .EXAMPLE
        Get-AgentIdentityInventory

        Retourne les identites d'agents enregistrees dans le locataire.

    .EXAMPLE
        Get-AgentIdentityInventory -IncludeBlueprints -IncludePackages

        Retourne les identites d'agents, les plans d'identites et le catalogue des packages d'agents.

    .EXAMPLE
        Get-AgentIdentityInventory -HtmlReportPath '.\inventaire-agents.html' -Verbose

        Retourne les identites d'agents et enregistre un rapport HTML simple.

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Lecture seule. Les points d'acces et les permissions proviennent de la documentation Microsoft
        citee dans le fichier README. Les capacites de Copilot Studio evoluent : verifiez l'etat exact
        dans votre locataire.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter()]
        [switch] $IncludeBlueprints,

        [Parameter()]
        [switch] $IncludePackages,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $HtmlReportPath
    )

    if (-not (Get-Command -Name 'Connect-MgGraph' -ErrorAction SilentlyContinue)) {
        throw 'Le module Microsoft.Graph est requis. Installez-le avec : Install-Module Microsoft.Graph'
    }

    $requiredScopes = [System.Collections.Generic.List[string]]::new()
    $requiredScopes.Add('AgentIdentity.Read.All')

    if ($IncludeBlueprints) {
        $requiredScopes.Add('AgentIdentityBlueprint.Read.All')
    }

    if ($IncludePackages) {
        $requiredScopes.Add('CopilotPackages.Read.All')
    }

    if ($null -eq (Get-MgContext)) {
        Write-Verbose 'Aucune session Microsoft Graph active. Ouverture d''une connexion.'
        $null = Connect-MgGraph -Scopes $requiredScopes.ToArray() -ErrorAction Stop
    }

    $results = [System.Collections.Generic.List[object]]::new()

    $identityUri = 'https://graph.microsoft.com/v1.0/servicePrincipals/microsoft.graph.agentIdentity'
    Write-Verbose "Interrogation des identites d'agents : $identityUri"
    foreach ($item in (Get-GraphCollection -Uri $identityUri)) {
        $results.Add((ConvertTo-InventoryObject -Category 'AgentIdentity' -Item $item))
    }

    if ($IncludeBlueprints) {
        $blueprintUri = 'https://graph.microsoft.com/v1.0/applications/microsoft.graph.agentIdentityBlueprint'
        Write-Verbose "Interrogation des plans d'identites d'agents : $blueprintUri"
        foreach ($item in (Get-GraphCollection -Uri $blueprintUri)) {
            $results.Add((ConvertTo-InventoryObject -Category 'AgentIdentityBlueprint' -Item $item))
        }
    }

    if ($IncludePackages) {
        $packageUri = 'https://graph.microsoft.com/v1.0/copilot/admin/catalog/packages'
        Write-Verbose "Interrogation du catalogue des packages d'agents : $packageUri"
        foreach ($item in (Get-GraphCollection -Uri $packageUri)) {
            $results.Add((ConvertTo-InventoryObject -Category 'CopilotAgentPackage' -Item $item))
        }
    }

    $sorted = $results | Sort-Object -Property Category, DisplayName

    if ($PSBoundParameters.ContainsKey('HtmlReportPath')) {
        $head = '<meta charset="utf-8"><title>Inventaire des identites d''agents</title><style>body{font-family:Segoe UI,Arial,sans-serif;margin:1em;}table{border-collapse:collapse;}th,td{border:1px solid #cccccc;padding:6px;text-align:left;}th{background:#f2f2f2;}</style>'
        $htmlContent = $sorted |
            ConvertTo-Html -Property Category, DisplayName, Id, AppId -Head $head -PreContent '<h1>Inventaire des identites d''agents</h1>'
        $htmlContent | Out-File -FilePath $HtmlReportPath -Encoding utf8 -ErrorAction Stop
        Write-Verbose "Rapport HTML disponible : $HtmlReportPath"
    }

    return $sorted
}

Export-ModuleMember -Function 'Get-AgentIdentityInventory'

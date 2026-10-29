# AgentIdentityInventory

AgentIdentityInventory est un outil PowerShell en lecture seule qui interroge Microsoft Graph pour dresser la liste des identités d'agents Microsoft Entra Agent ID enregistrées dans votre locataire. La commande retourne des objets PowerShell et peut aussi produire un rapport HTML simple.

## Pourquoi maintenant

Les équipes ajoutent des agents Copilot Studio un peu partout. Chaque agent connecté ajoute de la consommation de jetons, un point de défaillance de plus et davantage à gouverner. Microsoft Entra Agent ID donne une identité aux agents et le registre des agents est interrogeable par l'API Graph.

Le billet qui accompagne cet outil recommande de lancer un inventaire des identités d'agents avant d'appliquer ses décisions d'architecture. Avant de décider quoi séparer ou quoi fusionner, il faut savoir ce qui existe déjà. Si vous voyez plus d'identités que prévu, c'est un signal pour revoir la propriété et la gouvernance de chacune.

## Prérequis

- PowerShell 5.1 ou une version plus récente.
- Le module Microsoft.Graph installé (au minimum Microsoft.Graph.Authentication pour Connect-MgGraph et Invoke-MgGraphRequest).
- Un compte administrateur en mesure de consentir aux permissions Microsoft Graph requises.

Permissions Microsoft Graph déléguées selon ce que vous demandez:

- `AgentIdentity.Read.All` pour l'inventaire de base des identités d'agents.
- `AgentIdentityBlueprint.Read.All` pour le commutateur `-IncludeBlueprints`.
- `CopilotPackages.Read.All` pour le commutateur `-IncludePackages`.

Le commutateur `-IncludePackages` interroge le catalogue des packages d'agents. Cette API est en préversion. Elle demande le rôle AI Administrator et une licence Microsoft Agent 365.

## Installation

- Installez le module Microsoft Graph au besoin:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

- Récupérez ce dépôt puis importez le module:

```powershell
Import-Module .\AgentIdentityInventory.psd1
```

## Utilisation

Inventaire de base:

```powershell
Get-AgentIdentityInventory
```

Inventaire complet avec les plans d'identités et le catalogue des packages:

```powershell
Get-AgentIdentityInventory -IncludeBlueprints -IncludePackages
```

Inventaire avec rapport HTML et messages détaillés:

```powershell
Get-AgentIdentityInventory -HtmlReportPath '.\inventaire-agents.html' -Verbose
```

La commande retourne des objets PowerShell. Vous pouvez donc les filtrer, les trier ou les exporter:

```powershell
Get-AgentIdentityInventory | Export-Csv -Path '.\inventaire-agents.csv' -NoTypeInformation
```

## Exemple de sortie

L'exemple suivant est fictif. Il illustre seulement la forme des objets retournés. Les identifiants présentés ne correspondent à aucun locataire réel.

```
Category       DisplayName                           Id                                   AppId
--------       -----------                           --                                   -----
AgentIdentity  Agent d'approbation des factures      11111111-1111-1111-1111-111111111111 aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
AgentIdentity  Agent d'integration des fournisseurs  22222222-2222-2222-2222-222222222222 bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
AgentIdentity  Agent de soutien interne              33333333-3333-3333-3333-333333333333 cccccccc-cccc-cccc-cccc-cccccccccccc
```

## Limites connues

- La commande est en lecture seule. Elle ne crée, ne modifie et ne supprime aucune ressource de votre locataire.
- Les capacités de Copilot Studio et de Microsoft Entra Agent ID évoluent. Vérifiez l'état exact dans votre locataire.
- Le catalogue des packages d'agents est en préversion. Il demande le rôle AI Administrator et une licence Microsoft Agent 365.
- La page d'orientation pour migrer les identités d'agents Copilot Studio vers Entra Agent ID est en préversion.
- Le schéma des objets retournés par le catalogue des packages peut varier pendant la préversion. La commande n'affiche que les champs communs displayName, id et appId lorsqu'ils sont présents.
- L'outil n'utilise aucun point d'accès en version bêta. Le rapport d'utilisation de Copilot et l'exportation des interactions d'entreprise ne font pas partie de cet inventaire.

## Références

- Article qui accompagne cet outil: [Un agent Copilot Studio qui grossit choisit moins bien et coûte plus cher](https://trivium365.com/blog/agent-copilot-studio-qui-grossit-architecture/)
- Microsoft Tech Community, Copilot Studio Blog: [Are bigger agents better? How to design agents that scale](https://techcommunity.microsoft.com/blog/copilot-studio-blog/are-bigger-agents-better-how-to-design-agents-that-scale/4559073)
- Microsoft Learn: [User subscription license and usage-based billing](https://learn.microsoft.com/fr-fr/microsoft-365/copilot/user-subscription-license-usage-based-billing)
- Microsoft Learn: [Migration des identités d'agents Copilot Studio vers Entra Agent ID](https://learn.microsoft.com/en-us/microsoft-copilot-studio/govern-migrate-api-entra-agent-identity)

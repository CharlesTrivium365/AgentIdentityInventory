# Journal des modifications

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et le versionnage sémantique.

## [1.0.0] - 2026-10-29

### Ajouté

- Commande `Get-AgentIdentityInventory` qui inventorie en lecture seule les identités d'agents Microsoft Entra Agent ID via Microsoft Graph.
- Commutateur `-IncludeBlueprints` pour inclure les plans d'identités d'agents.
- Commutateur `-IncludePackages` pour inclure le catalogue des packages d'agents en préversion.
- Paramètre `-HtmlReportPath` pour produire un rapport HTML simple.
- Aide basée sur les commentaires et sortie en objets PowerShell.

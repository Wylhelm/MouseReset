# Solution de Réinitialisation des Paramètres de Souris

## Description
Solution automatisée pour réinitialiser les paramètres de souris Windows aux valeurs par défaut. Cette solution est déployée via Microsoft Intune et s'exécute automatiquement à la connexion de l'utilisateur ainsi qu'après une période d'inactivité.

## Fonctionnalités
- Réinitialisation automatique des paramètres de souris
- Exécution à la connexion utilisateur
- Exécution après 5 minutes d'inactivité
- Journalisation complète des actions
- Déploiement via Microsoft Intune

## Structure du Projet
```
.
├── Detection.ps1          # Script de détection pour Intune
├── Install.cmd           # Script wrapper pour l'installation
├── Install.intunewin     # Package Intune
├── Install.ps1           # Script d'installation principal
├── IntuneWinAppUtil.exe  # Utilitaire de création de package Intune
├── mouse_reset.xml       # Configuration de la tâche planifiée
├── mouse.ps1            # Script principal de réinitialisation
├── Uninstall.cmd        # Script wrapper pour la désinstallation
└── Uninstall.ps1        # Script de désinstallation principal
```

## Prérequis
- Windows 11
- Droits administratifs pour l'installation
- Microsoft Intune pour le déploiement

## Installation
L'installation est gérée automatiquement via Microsoft Intune. Le package `.intunewin` contient tous les composants nécessaires et configure :
1. Les scripts de réinitialisation
2. La tâche planifiée
3. Les permissions requises
4. La journalisation

## Journalisation
Les logs sont stockés dans :
- `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-install.log`
- `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-detection.log`

## Documentation
Pour plus de détails techniques, consultez le [Guide du Développeur](developer_guide.md).

## Support
En cas de problème :
1. Vérifier les fichiers de logs
2. Consulter la section dépannage du guide développeur
3. Vérifier l'état de la tâche planifiée via le Planificateur de tâches Windows

## Licence
Propriétaire - Tous droits réservés

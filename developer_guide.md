# Guide du Développeur - Solution de Réinitialisation des Paramètres de Souris

## Vue d'ensemble

Cette solution est conçue pour réinitialiser automatiquement les paramètres de souris Windows aux valeurs par défaut. Elle est déployée via Microsoft Intune en tant qu'application Win32 et utilise des tâches planifiées Windows pour s'exécuter à des moments spécifiques.

## Architecture de la Solution

### Composants Principaux

1. **Script Principal (mouse.ps1)**
   - Réinitialise les paramètres de souris aux valeurs par défaut de Windows 11
   - Configure la sensibilité, la vitesse, les seuils et la configuration des boutons
   - Utilise les API Windows pour appliquer les paramètres
   - Journalise toutes les actions effectuées

2. **Tâche Planifiée (mouse_reset.xml)**
   - S'exécute dans deux conditions :
     * À la connexion de l'utilisateur
     * Après 5 minutes d'inactivité
   - Configurée pour s'exécuter avec les privilèges les plus élevés disponibles
   - Utilise le compte utilisateur actuel

3. **Scripts de Déploiement**
   - **Install.ps1** : Script d'installation principal
   - **Uninstall.ps1** : Script de désinstallation
   - **Detection.ps1** : Script de détection pour Intune
   - **Install.cmd** et **Uninstall.cmd** : Wrappers pour l'exécution PowerShell

### Structure des Répertoires

```
%ProgramData%\PNG\Scripts\Mouse\
    └── mouse.ps1

%ProgramFiles%\PNG\Scripts\Journaux\
    ├── mouse-reset-install.log
    └── mouse-reset-detection.log
```

## Processus d'Installation

1. Création des répertoires nécessaires
2. Copie des fichiers dans les emplacements appropriés
3. Configuration des permissions :
   - SYSTEM : Contrôle total
   - Utilisateurs : Lecture et exécution
4. Enregistrement de la tâche planifiée
5. Démarrage initial de la tâche

## Mécanisme de Détection

Le script de détection (`Detection.ps1`) vérifie :
1. La présence de tous les fichiers requis
2. L'existence et l'état de la tâche planifiée
3. Les permissions correctes sur les répertoires
4. Effectue jusqu'à 3 tentatives de détection avec un délai de 10 secondes

## Journalisation

- Les logs d'installation : `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-install.log`
- Les logs de détection : `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-detection.log`
- Format des logs : `[Date-Heure] [Niveau] Message`

## Paramètres de Souris Configurés

Les paramètres suivants sont réinitialisés aux valeurs par défaut :
- Sensibilité de la souris (MouseSensitivity)
- Vitesse du pointeur (MouseSpeed)
- Seuils d'accélération (MouseThreshold1, MouseThreshold2)
- Courbes de mouvement (SmoothMouseXCurve, SmoothMouseYCurve)
- Vitesse du double-clic (DoubleClickSpeed)
- Traînée du pointeur (MouseTrails)
- Configuration des boutons (SwapMouseButtons)

## Déploiement via Intune

### Prérequis
- Accès administratif à Microsoft Intune
- Package `.intunewin` généré avec `IntuneWinAppUtil.exe`

### Commandes de Déploiement
- Installation : `Install.cmd`
- Désinstallation : `Uninstall.cmd`
- Détection : `powershell.exe -ExecutionPolicy Bypass -File Detection.ps1`

## Dépannage

### Problèmes Courants
1. **La tâche ne s'exécute pas**
   - Vérifier les permissions
   - Consulter les journaux d'événements Windows
   - Vérifier l'état de la tâche planifiée

2. **Échec de la détection**
   - Vérifier les logs dans `C:\Program Files\PNG\Scripts\Journaux`
   - S'assurer que tous les fichiers sont présents
   - Vérifier les permissions des répertoires

### Commandes Utiles
```powershell
# Vérifier l'état de la tâche
Get-ScheduledTask -TaskName "mouse_reset"

# Vérifier les permissions
Get-Acl "%ProgramData%\PNG\Scripts\Mouse"

# Exécuter la tâche manuellement
Start-ScheduledTask -TaskName "mouse_reset"
```

## Maintenance et Mise à Jour

Pour mettre à jour la solution :
1. Modifier les scripts nécessaires
2. Mettre à jour la version dans le package Intune
3. Regénérer le fichier `.intunewin`
4. Déployer la nouvelle version via Intune

## Sécurité

- Les scripts s'exécutent avec les privilèges élevés nécessaires
- Les permissions sont strictement contrôlées
- Les chemins d'accès sont codés en dur pour éviter les attaques par injection
- La politique d'exécution PowerShell est configurée de manière sécurisée

## Bonnes Pratiques de Développement

1. Toujours tester les modifications localement avant le déploiement
2. Maintenir une documentation à jour des changements
3. Utiliser le contrôle de version pour suivre les modifications
4. Tester sur différentes versions de Windows
5. Valider les logs après chaque modification

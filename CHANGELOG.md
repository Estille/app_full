# Changelog

Toutes les modifications notables de ce projet sont documentées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/), versionnage [SemVer](https://semver.org/lang/fr/).

## [2.0.0] — Production-ready

### Ajouté
- Internationalisation complète FR/EN (`AppLocalizations`, sélection automatique selon la langue du système).
- Accessibilité : `Semantics` sur tous les éléments interactifs (boutons, champs de formulaire, images, bandeau hors-ligne en `liveRegion`).
- Cache disque + lazy loading des images via `cached_network_image` (liste produits et détail).
- `flutter_hooks` sur `LoginScreen` pour limiter les rebuilds inutiles.
- Suite de tests complète : tests unitaires (modèles, repositories, failures), tests de widgets (écrans auth/produits, `ErrorView`), tests d'intégration (parcours login → produits, navigation détail).
- Pipeline CI GitHub Actions : format, `flutter analyze --fatal-infos`, tests avec couverture, build APK debug, tests d'intégration sur émulateur.

### Modifié
- `ListView` de la liste produits : `itemExtent` fixe pour supprimer le jank au scroll.
- Placeholders de chargement d'image pour éviter les sauts de mise en page (layout shift).

### Corrigé
- Retour `Future` sans `await` dans un bloc `try` (`auth_remote_datasource.dart`).
- Commentaires de documentation utilisant `<...>` mal interprétés comme du HTML.

## [1.1.0] — App connectée & mode hors-ligne

### Ajouté
- Authentification JWT complète (login / register / logout) via DummyJSON, avec refresh token automatique sur 401 (`AuthInterceptor`).
- Cache local Hive pour les produits, catégories et l'utilisateur courant.
- Mode hors-ligne : bandeau visible + repli automatique sur le cache quand il n'y a pas de réseau.
- Gestion d'erreurs typée (`Failure` / `Either`) plutôt que des exceptions brutes remontées à l'UI.
- 7 tests unitaires sur la couche repository (auth + produits).

### Modifié
- Passage à une architecture Feature-First stricte (`data` / `domain` / `presentation` par feature).

## [1.0.0] — Première version

### Ajouté
- Structure initiale du projet Flutter (`flutter create`).
- Écran unique de démonstration.
- Dépendances de base (`cupertino_icons`, `flutter_lints`).

# App Full — Backend Connected App

![CI](https://github.com/<ton-user>/<ton-repo>/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-informational)

Application Flutter **production-ready** connectée à une API REST réelle ([DummyJSON](https://dummyjson.com)) : authentification JWT, cache local, mode hors-ligne, i18n FR/EN, accessibilité, et une suite de tests complète (unitaires, widgets, intégration).

> Remplace `<ton-user>/<ton-repo>` dans le badge CI ci-dessus par le chemin réel de ton dépôt GitHub une fois poussé.

## Sommaire

- [Captures d'écran](#captures-décran)
- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Internationalisation](#internationalisation)
- [Accessibilité](#accessibilité)
- [Performance](#performance)
- [Tests](#tests)
- [CI/CD](#cicd)
- [Installation](#installation)
- [Changelog](#changelog)

## Captures d'écran

| Connexion | Produits | Détail |
|---|---|---|
| _(à ajouter : `docs/screenshots/login.png`)_ | _(à ajouter : `docs/screenshots/products.png`)_ | _(à ajouter : `docs/screenshots/detail.png`)_ |

> Place tes captures dans `docs/screenshots/` et remplace ces lignes par `![Connexion](docs/screenshots/login.png)` etc.

## Fonctionnalités

- **5 écrans** : Connexion, Inscription, Liste des produits, Détail produit, Profil.
- Authentification JWT complète (login/register/logout) avec refresh token automatique.
- Cache local Hive + mode hors-ligne (bandeau visible, repli automatique sur le cache).
- Images en cache disque et chargées à la demande (lazy loading) via `cached_network_image`.
- i18n FR/EN avec bascule automatique selon la langue du système.
- Labels d'accessibilité (`Semantics`) sur tous les éléments interactifs.
- Suite de tests : 16 tests unitaires, 13 tests de widgets, 3 tests d'intégration.
- CI GitHub Actions : format, `flutter analyze`, tests + couverture, build APK, tests d'intégration.

## Architecture

Architecture **Feature-First**, séparée en 3 couches par feature (inspirée de Clean Architecture) :

```
lib/
├── core/                     # transverse : réseau, erreurs, cache, DI, router
│   ├── network/               (Dio, intercepteur JWT, connectivité, token storage)
│   ├── error/                 (Failures + Exceptions)
│   └── di/                    (providers Riverpod, GoRouter)
├── l10n/                      # AppLocalizations (FR/EN, écrit à la main)
├── features/
│   ├── auth/
│   │   ├── data/               modèles JSON, datasources remote/local, repository_impl
│   │   ├── domain/             entités pures, interface repository
│   │   └── presentation/       providers Riverpod, écrans (login, register, profile)
│   └── products/               même structure (products list, product detail)
└── shared/widgets/            widgets réutilisables (ErrorView, ...)

test/
├── core/error/                 tests sur les Failures
├── features/.../data/          tests unitaires modèles + repositories
├── widgets/                     tests de widgets par écran
└── helpers/                     fakes + wrapper de test (pumpApp)

integration_test/               parcours complets (login → produits, navigation)
```

**Flux de dépendance** : `presentation → domain ← data`. Le domain ne dépend de rien ; la présentation ne connaît que les interfaces `domain`, jamais Dio ni Hive directement.

**Repository pattern** : chaque repository orchestre un datasource distant (Dio) et local (Hive), et convertit toute exception en `Failure` via `Either<Failure, T>` (`fpdart`) — la présentation ne fait jamais de `try/catch`, juste `result.match(...)`.

**Injection de dépendances** : centralisée dans `core/di/injection.dart` (providers Riverpod), ce qui permet de remplacer n'importe quel repository par un faux dans les tests sans toucher au code de production (`ProviderScope(overrides: [...])`).

## Internationalisation

`lib/l10n/app_localizations.dart` — implémentation manuelle (pas de génération de code `flutter gen-l10n`, plus simple à maintenir et sans étape de build supplémentaire). Ajoute une langue en ajoutant une entrée dans la map `_strings`.

Utilisation dans un widget : `context.l10n.login`.

Pour forcer une langue en développement, passe `locale: const Locale('en')` à `MaterialApp.router` dans `main.dart`.

## Accessibilité

Tous les boutons, champs de formulaire et images significatives sont enveloppés dans un widget `Semantics` avec un `label` explicite (traduit via `AppLocalizations`). Le bandeau hors-ligne utilise `liveRegion: true` pour être annoncé automatiquement par les lecteurs d'écran (TalkBack / VoiceOver) dès son apparition.

## Performance

- `const` sur tous les widgets qui n'en ont pas besoin (vérifié par le lint `prefer_const_constructors`).
- `LoginScreen` utilise `flutter_hooks` (`useState`, `useTextEditingController`) au lieu d'un `StatefulWidget` classique : moins de boilerplate, et les rebuilds restent localisés à la portion d'UI qui dépend de l'état modifié.
- `ListView.builder` avec `itemExtent` fixe pour la liste produits : évite à Flutter de mesurer chaque item avant de scroller, ce qui supprime le jank sur de longues listes.
- Images chargées via `CachedNetworkImage` : mise en cache disque automatique + espace réservé (`placeholder`) pendant le chargement pour éviter les sauts de layout.

## Tests

```bash
# Tests unitaires + widgets (rapides, pas d'émulateur nécessaire)
flutter test

# Avec couverture
flutter test --coverage

# Tests d'intégration (nécessite un émulateur/appareil connecté)
flutter test integration_test
```

Répartition :

| Type | Nombre | Emplacement |
|---|---|---|
| Unitaires | 16 | `test/core/`, `test/features/*/data/` |
| Widgets | 13 | `test/widgets/` |
| Intégration | 3 | `integration_test/` |

## CI/CD

`.github/workflows/ci.yml` exécute à chaque push/PR sur `main` :
1. `dart format --set-exit-if-changed` (formatage)
2. `flutter analyze --fatal-infos` (analyse statique stricte)
3. `flutter test --coverage` (unitaires + widgets)
4. Build d'un APK debug de démonstration (artifact téléchargeable)
5. `flutter test integration_test` sur un émulateur Android (job séparé)

## Installation

```bash
git clone <url-du-repo>
cd app_full
flutter pub get
flutter run
```

Aucune clé API n'est requise (l'app utilise [DummyJSON](https://dummyjson.com), public). Compte de test pré-rempli sur l'écran de connexion : `emilys` / `emilyspass`.

Pour brancher ton propre backend : modifie `DioClient.baseUrl` dans `lib/core/network/dio_client.dart` et adapte les payloads dans `AuthRemoteDataSourceImpl`.

## Changelog

Voir [CHANGELOG.md](./CHANGELOG.md) pour l'historique des versions.

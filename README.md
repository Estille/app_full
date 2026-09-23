# Backend Connected App

Application Flutter connectée à une **API REST réelle** ([DummyJSON](https://dummyjson.com)), avec authentification JWT, cache local et mode hors-ligne.

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [API utilisée](#api-utilisée)
- [Architecture](#architecture)
- [Gestion du token & refresh](#gestion-du-token--refresh)
- [Mode hors-ligne](#mode-hors-ligne)
- [Tests](#tests)
- [Installation](#installation)

## Fonctionnalités

- Authentification complète : login, register, logout (JWT)
- 3 écrans de données issues de l'API REST : liste des produits, détail d'un produit, profil utilisateur
- Cache local avec **Hive** (produits, catégories, utilisateur courant)
- Mode hors-ligne : bandeau visible + affichage automatique des données en cache si pas de réseau
- Gestion d'erreurs réseau centralisée avec messages utilisateur clairs (`Failure` typées)

## API utilisée

[DummyJSON](https://dummyjson.com) — choisie car c'est l'une des rares API de démo publiques à fournir un **vrai flux JWT avec refresh token** (`POST /auth/login`, `POST /auth/refresh`), en plus des endpoints `/products` nécessaires aux écrans de données.

Compte de test : `username: emilys` / `password: emilyspass` (pré-rempli dans l'écran de connexion). Voir [dummyjson.com/users](https://dummyjson.com/users) pour d'autres comptes.

> Pour brancher ton propre backend : remplace `DioClient.baseUrl` dans `lib/core/network/dio_client.dart`, et adapte les payloads dans `AuthRemoteDataSourceImpl`.

## Architecture

Architecture **Feature-First**, avec séparation stricte en 3 couches par feature (inspirée de Clean Architecture) :

```
lib/
├── core/                     # transverse : réseau, erreurs, cache, DI
│   ├── network/               (Dio, intercepteur JWT, connectivité, token storage)
│   ├── error/                 (Failures + Exceptions)
│   └── di/                    (providers Riverpod, router)
├── features/
│   ├── auth/
│   │   ├── data/               modèles JSON, datasources remote/local, repository_impl
│   │   ├── domain/             entités pures, interface repository
│   │   └── presentation/       providers Riverpod (state), écrans
│   └── products/               même structure
└── shared/widgets/            widgets réutilisables (ErrorView, ...)
```

**Flux de dépendance** : `presentation → domain ← data`. Le domain ne dépend de rien ; la présentation ne connaît que les interfaces `domain`, jamais Dio ni Hive directement.

**Repository pattern** : chaque repository (`AuthRepositoryImpl`, `ProductRepositoryImpl`) orchestre un datasource distant (Dio) et un datasource local (Hive), décide quelle source utiliser, et convertit toute exception en `Failure` via `Either<Failure, T>` (package `fpdart`) — la couche présentation n'a jamais de `try/catch`, elle fait juste `result.match(...)`.

## Gestion du token & refresh

`AuthInterceptor` (`lib/core/network/auth_interceptor.dart`) :
1. Injecte `Authorization: Bearer <token>` sur chaque requête sortante.
2. Si le serveur répond `401`, tente automatiquement `POST /auth/refresh` avec le refresh token stocké.
3. Si le refresh réussit → rejoue la requête d'origine avec le nouveau token, de façon transparente pour l'appelant.
4. Si le refresh échoue → efface la session locale (l'UI redirige alors vers `/login` via le `redirect` de GoRouter).

Les tokens sont stockés avec `flutter_secure_storage` (Keychain/Keystore), jamais dans Hive en clair.

## Mode hors-ligne

`ProductRepositoryImpl.getProducts()` :
- Si connecté → appel API, résultat mis en cache Hive, retourné.
- Si non connecté (ou si le serveur échoue) → lecture du cache Hive ; si le cache est vide, l'erreur réseau d'origine est renvoyée avec un message clair.

Un bandeau orange s'affiche automatiquement en haut de l'écran produits quand l'appareil est hors-ligne.

## Tests

3 tests unitaires minimum sur la couche repository (`test/features/.../repositories/`), avec des doublures de test écrites à la main (pas de génération de code nécessaire) :

- `auth_repository_impl_test.dart` : login réussi + mise en cache, échec réseau, identifiants invalides, logout.
- `product_repository_impl_test.dart` : récupération réseau + cache, fallback hors-ligne avec cache rempli, échec quand ni réseau ni cache.

```bash
flutter test
```

## Installation

```bash
git clone <url-du-repo>
cd app_full
flutter pub get
flutter run
```

Aucune clé API n'est requise (DummyJSON est public). Pour un vrai backend, ajuste `baseUrl` dans `lib/core/network/dio_client.dart`.

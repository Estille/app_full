import 'package:flutter/material.dart';

/// Système d'i18n écrit à la main (pas de `flutter gen-l10n` requis) :
/// plus simple à maintenir dans un projet étudiant et évite une étape
/// de génération de code supplémentaire qui peut casser sur certains setups.
///
/// Utilisation dans un widget : `context.l10n.login`
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(l10n != null, 'AppLocalizations non trouvé dans le contexte.');
    return l10n!;
  }

  static const supportedLocales = [Locale('fr'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _strings = {
    'fr': {
      'appTitle': 'Backend Connected App',
      'login': 'Connexion',
      'logout': 'Se déconnecter',
      'register': 'Créer un compte',
      'username': "Nom d'utilisateur",
      'password': 'Mot de passe',
      'email': 'Email',
      'loginButton': 'Se connecter',
      'registerButton': "S'inscrire",
      'noAccount': "Pas de compte ? S'inscrire",
      'requiredField': 'Champ requis',
      'invalidEmail': 'Email invalide',
      'passwordTooShort': 'Minimum 6 caractères',
      'products': 'Produits',
      'profile': 'Profil',
      'productDetail': 'Détail produit',
      'guest': 'Invité',
      'offlineBanner': '⚠ Hors-ligne — données en cache',
      'retry': 'Réessayer',
      'errorGeneric': 'Une erreur inattendue est survenue.',
      'showPassword': 'Afficher le mot de passe',
      'hidePassword': 'Masquer le mot de passe',
      'productImage': 'Image du produit',
      'userAvatar': 'Photo de profil',
      'openProfile': 'Ouvrir le profil',
      'category': 'Catégorie',
      'price': 'Prix',
      'rating': 'Note',
    },
    'en': {
      'appTitle': 'Backend Connected App',
      'login': 'Login',
      'logout': 'Log out',
      'register': 'Create account',
      'username': 'Username',
      'password': 'Password',
      'email': 'Email',
      'loginButton': 'Log in',
      'registerButton': 'Sign up',
      'noAccount': "Don't have an account? Sign up",
      'requiredField': 'Required field',
      'invalidEmail': 'Invalid email',
      'passwordTooShort': 'Minimum 6 characters',
      'products': 'Products',
      'profile': 'Profile',
      'productDetail': 'Product detail',
      'guest': 'Guest',
      'offlineBanner': '⚠ Offline — showing cached data',
      'retry': 'Retry',
      'errorGeneric': 'An unexpected error occurred.',
      'showPassword': 'Show password',
      'hidePassword': 'Hide password',
      'productImage': 'Product image',
      'userAvatar': 'Profile picture',
      'openProfile': 'Open profile',
      'category': 'Category',
      'price': 'Price',
      'rating': 'Rating',
    },
  };

  String _t(String key) =>
      _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;

  String get appTitle => _t('appTitle');
  String get login => _t('login');
  String get logout => _t('logout');
  String get register => _t('register');
  String get username => _t('username');
  String get password => _t('password');
  String get email => _t('email');
  String get loginButton => _t('loginButton');
  String get registerButton => _t('registerButton');
  String get noAccount => _t('noAccount');
  String get requiredField => _t('requiredField');
  String get invalidEmail => _t('invalidEmail');
  String get passwordTooShort => _t('passwordTooShort');
  String get products => _t('products');
  String get profile => _t('profile');
  String get productDetail => _t('productDetail');
  String get guest => _t('guest');
  String get offlineBanner => _t('offlineBanner');
  String get retry => _t('retry');
  String get errorGeneric => _t('errorGeneric');
  String get showPassword => _t('showPassword');
  String get hidePassword => _t('hidePassword');
  String get productImage => _t('productImage');
  String get userAvatar => _t('userAvatar');
  String get openProfile => _t('openProfile');
  String get category => _t('category');
  String get price => _t('price');
  String get rating => _t('rating');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Sucre syntaxique : `context.l10n.login` au lieu de
/// `AppLocalizations.of(context).login`.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

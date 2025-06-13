import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currency';
  static const String _themeModeKey = 'theme_mode';
  static const String _currencySymbolKey = 'currency_symbol';
  static const String _languageKey = 'language';
  static const String _defaultCurrency = 'USD';

  final SharedPreferences _prefs;
  
  String _currency;
  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol;
  String _language = 'en';

  SettingsProvider(this._prefs)
      : _currency = _prefs.getString(_currencyKey) ?? _defaultCurrency,
        _currencySymbol = _prefs.getString(_currencySymbolKey) ?? '\$' {
    _loadSettings();
  }

  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  String get language => _language;

  void _loadSettings() {
    _language = _prefs.getString(_languageKey) ?? 'en';
    // Ensure currency symbol matches the current currency
    _updateCurrencySymbol(_currency);
    notifyListeners();
  }

  void _updateCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        _currencySymbol = '\$';
        break;
      case 'INR':
        _currencySymbol = '₹';
        break;
      case 'EUR':
        _currencySymbol = '€';
        break;
      case 'GBP':
        _currencySymbol = '£';
        break;
      default:
        _currencySymbol = '\$';
    }
  }

  Future<void> setCurrency(String currency) async {
    if (_currency != currency) {
      _currency = currency;
      _updateCurrencySymbol(currency);
      await _prefs.setString(_currencyKey, currency);
      await _prefs.setString(_currencySymbolKey, _currencySymbol);
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_language != language) {
      _language = language;
      await _prefs.setString(_languageKey, language);
      notifyListeners();
    }
  }
} 
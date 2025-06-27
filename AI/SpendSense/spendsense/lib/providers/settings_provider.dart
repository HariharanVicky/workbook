import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currency';
  static const String _themeModeKey = 'theme_mode';
  static const String _currencySymbolKey = 'currency_symbol';
  static const String _languageKey = 'language';
  static const String _pinKey = 'security_pin';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _lastUnlockTimeKey = 'last_unlock_time';
  static const String _defaultCurrency = 'USD';

  final SharedPreferences _prefs;
  
  String _currency;
  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol;
  String _language = 'en';
  String? _pin;
  bool _pinEnabled = false;
  DateTime? _lastUnlockTime;

  SettingsProvider(this._prefs)
      : _currency = _prefs.getString(_currencyKey) ?? _defaultCurrency,
        _currencySymbol = _prefs.getString(_currencySymbolKey) ?? '\$' {
    _loadSettings();
  }

  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  String get language => _language;
  String? get pin => _pin;
  bool get pinEnabled => _pinEnabled;
  DateTime? get lastUnlockTime => _lastUnlockTime;

  void _loadSettings() {
    _language = _prefs.getString(_languageKey) ?? 'en';
    _pin = _prefs.getString(_pinKey);
    _pinEnabled = _prefs.getBool(_pinEnabledKey) ?? false;
    
    // Load last unlock time
    final lastUnlockString = _prefs.getString(_lastUnlockTimeKey);
    if (lastUnlockString != null) {
      _lastUnlockTime = DateTime.tryParse(lastUnlockString);
    }
    
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

  // PIN Security Methods
  Future<void> setPin(String pin) async {
    _pin = pin;
    await _prefs.setString(_pinKey, pin);
    notifyListeners();
  }

  Future<void> enablePin() async {
    if (_pin != null && _pin!.isNotEmpty) {
      _pinEnabled = true;
      await _prefs.setBool(_pinEnabledKey, true);
      notifyListeners();
    }
  }

  Future<void> disablePin() async {
    _pinEnabled = false;
    await _prefs.setBool(_pinEnabledKey, false);
    notifyListeners();
  }

  Future<void> removePin() async {
    _pin = null;
    _pinEnabled = false;
    _lastUnlockTime = null;
    await _prefs.remove(_pinKey);
    await _prefs.setBool(_pinEnabledKey, false);
    await _prefs.remove(_lastUnlockTimeKey);
    notifyListeners();
  }

  bool validatePin(String enteredPin) {
    return _pin == enteredPin;
  }

  bool isPinSet() {
    return _pin != null && _pin!.isNotEmpty;
  }

  bool shouldShowPinScreen() {
    return _pinEnabled && isPinSet();
  }

  // Track successful unlock
  Future<void> recordSuccessfulUnlock() async {
    _lastUnlockTime = DateTime.now();
    await _prefs.setString(_lastUnlockTimeKey, _lastUnlockTime!.toIso8601String());
    notifyListeners();
  }

  // Clear unlock time when app is paused (for maximum security)
  Future<void> clearUnlockTime() async {
    _lastUnlockTime = null;
    await _prefs.remove(_lastUnlockTimeKey);
    notifyListeners();
  }

  // Check if PIN should be required on resume
  bool shouldRequirePinOnResume() {
    if (!shouldShowPinScreen()) {
      return false;
    }
    
    // If no last unlock time, require PIN
    if (_lastUnlockTime == null) {
      return true;
    }
    
    // For now, always require PIN on resume for maximum security
    // You can modify this logic to add a grace period if needed
    // For example: return DateTime.now().difference(_lastUnlockTime!).inMinutes > 5;
    return true;
  }
} 
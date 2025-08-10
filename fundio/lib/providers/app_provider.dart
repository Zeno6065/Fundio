import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AppStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppStatus _status = AppStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  ThemeMode _themeMode = ThemeMode.light;
  
  // Theme mode key for shared preferences
  static const String _themeModeKey = 'theme_mode';

  // Getters
  AppStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AppStatus.authenticated;
  ThemeMode get themeMode => _themeMode;

  // Constructor
  AppProvider() {
    _initialize();
    _loadThemeMode();
  }

  // Initialize the app state
  Future<void> _initialize() async {
    _authService.userStream.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _status = AppStatus.unauthenticated;
        _user = null;
        notifyListeners();
      } else {
        _status = AppStatus.authenticating;
        notifyListeners();
        
        try {
          final userData = await _authService.getUserData();
          if (userData != null) {
            _user = userData;
            _status = AppStatus.authenticated;
          } else {
            _status = AppStatus.unauthenticated;
          }
        } catch (e) {
          _status = AppStatus.error;
          _errorMessage = e.toString();
        }
        
        notifyListeners();
      }
    });
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      _status = AppStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      // The auth state listener will handle the rest
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String defaultCurrency,
  }) async {
    try {
      _status = AppStatus.authenticating;
      _errorMessage = null;
      notifyListeners();

      await _authService.registerWithEmailAndPassword(
        email,
        password,
        username,
        defaultCurrency,
      );
      // The auth state listener will handle the rest
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // The auth state listener will handle the rest
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String username, String defaultCurrency) async {
    try {
      await _authService.updateUserProfile(username, defaultCurrency);
      
      // Update local user data
      if (_user != null) {
        _user = _user!.copyWith(
          username: username,
          defaultCurrency: defaultCurrency,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update profile with various fields
  Future<void> updateProfile({
    String? photoURL,
    String? displayName,
    String? phone,
  }) async {
    try {
      await _authService.updateProfile(
        photoURL: photoURL,
        displayName: displayName,
        phone: phone,
      );
      
      // Update local user data
      if (_user != null) {
        _user = _user!.copyWith(
          photoURL: photoURL,
          username: displayName ?? _user!.username,
          phone: phone ?? _user!.phone,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);
      
      if (themeModeString != null) {
        if (themeModeString == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (themeModeString == 'light') {
          _themeMode = ThemeMode.light;
        } else if (themeModeString == 'system') {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, use the default theme mode (light)
      _themeMode = ThemeMode.light;
    }
  }

  // Save theme mode to shared preferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;
      
      switch (mode) {
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }
      
      await prefs.setString(_themeModeKey, themeModeString);
    } catch (e) {
      // Handle error silently
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    
    await _saveThemeMode(_themeMode);
    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeMode(mode);
    notifyListeners();
  }
}
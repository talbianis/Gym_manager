import 'package:flutter/material.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:gym_manager/models/auth.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  bool _initialCheckDone = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get initialCheckDone => _initialCheckDone;

  LoginViewModel() {
    // Initialize by checking if user is already logged in
    checkLoggedInUser();
  }

  // Check if user is already logged in from previous session
  Future<void> checkLoggedInUser() async {
    if (_initialCheckDone) return;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await DBHelper.getLoggedInUser();
      if (user != null) {
        _currentUser = user;
        print('User ${user.username} is already logged in');
      }
    } catch (e) {
      print('Error checking logged in user: $e');
      // If there's an error (like column doesn't exist yet), just continue
    } finally {
      _isLoading = false;
      _initialCheckDone = true;
      notifyListeners();
    }
  }

  // Login function
  Future<bool> login(String username, String password) async {
    // Validate input
    if (username.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Username and password are required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await DBHelper.loginUser(username.trim(), password);

      if (user != null) {
        _currentUser = user;

        // Save login state to database
        await DBHelper.setUserLoggedIn(user.id!, true);

        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user
  Future<bool> register(
    String username,
    String password,
    String confirmPassword,
  ) async {
    // Validate input
    if (username.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Username and password are required';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if username exists
      final exists = await DBHelper.usernameExists(username.trim());
      if (exists) {
        _errorMessage = 'Username already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Register user
      await DBHelper.registerUser(username.trim(), password);

      // Auto-login after registration
      final user = await DBHelper.loginUser(username.trim(), password);
      if (user != null) {
        _currentUser = user;
        await DBHelper.setUserLoggedIn(user.id!, true);
      }

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_currentUser != null) {
        // Clear login state from database
        await DBHelper.setUserLoggedIn(_currentUser!.id!, false);
      }
    } catch (e) {
      print('Error during logout: $e');
    }

    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;

    if (newPassword.length < 6) {
      _errorMessage = 'New password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await DBHelper.changePassword(
        _currentUser!.id!,
        oldPassword,
        newPassword,
      );

      if (success) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Old password is incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Password change failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Force check login status (useful when coming back to app)
  Future<void> refreshLoginStatus() async {
    await checkLoggedInUser();
  }
}

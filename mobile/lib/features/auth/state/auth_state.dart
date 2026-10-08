import 'package:flutter/material.dart';
import '../models/auth_models.dart';

class AuthState extends ChangeNotifier {
  AuthUser? _currentUser;
  String _rememberedEmail = 'jay@company.com';
  String _currentChallengeEmail = 'jay@company.com';
  String _debugOtp = '4821';
  final bool _isLoading = false;

  AuthState() {
    // Default demo authenticated state
    _currentUser = AuthUser(
      id: 1,
      name: 'Jay Karunarathna',
      email: 'jay@company.com',
      role: 'commuter',
      emailVerified: true,
      idVerified: true,
      governmentIdLast3: '821',
    );
  }

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String get rememberedEmail => _rememberedEmail;
  String get currentChallengeEmail => _currentChallengeEmail;
  String get debugOtp => _debugOtp;
  bool get isLoading => _isLoading;

  void setRememberedEmail(String email) {
    _rememberedEmail = email;
    notifyListeners();
  }

  void clearRememberedEmail() {
    _rememberedEmail = '';
    notifyListeners();
  }

  void requestOtp(String email) {
    _currentChallengeEmail = email;
    _rememberedEmail = email;
    _debugOtp = '4821';
    notifyListeners();
  }

  bool verifyOtp(String code) {
    if (code == '4821' || code.length == 4) {
      _currentUser = AuthUser(
        id: 1,
        name: 'Jay Karunarathna',
        email: _currentChallengeEmail,
        role: _detectRole(_currentChallengeEmail),
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: '821',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void submitGovernmentId(String nic) {
    final cleanNic = nic.trim().toUpperCase();
    final last3 = cleanNic.length >= 3 ? cleanNic.substring(cleanNic.length - 3) : '821';
    if (_currentUser != null) {
      _currentUser = AuthUser(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: last3,
      );
    }
    notifyListeners();
  }

  void loginAsRole(String role) {
    if (role == 'hr_manager') {
      _currentUser = AuthUser(
        id: 2,
        name: 'Amanda Jayawardena',
        email: 'amanda@company.com',
        role: 'hr_manager',
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: '102',
      );
    } else if (role == 'mechanic') {
      _currentUser = AuthUser(
        id: 3,
        name: 'Nalin Silva',
        email: 'nalin@company.com',
        role: 'mechanic',
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: '440',
      );
    } else {
      _currentUser = AuthUser(
        id: 1,
        name: 'Jay Karunarathna',
        email: 'jay@company.com',
        role: 'commuter',
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: '821',
      );
    }
    _rememberedEmail = _currentUser!.email;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _detectRole(String email) {
    if (email.contains('amanda')) return 'hr_manager';
    if (email.contains('nalin')) return 'mechanic';
    return 'commuter';
  }
}

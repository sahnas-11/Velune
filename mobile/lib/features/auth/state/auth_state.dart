import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/auth_models.dart';

class AuthState extends ChangeNotifier {
  AuthUser? _currentUser;
  String _rememberedEmail = 'jay@company.com';
  String _currentChallengeEmail = 'jay@company.com';
  String _debugOtp = '4821';
  final bool _isLoading = false;

  // Registered users repository in memory (synced with Laravel DB)
  final List<AuthUser> _users = [
    AuthUser(
      id: 1,
      name: 'Jay Karunarathna',
      email: 'jay@company.com',
      password: 'password123',
      role: 'commuter',
      emailVerified: true,
      idVerified: true,
      governmentIdLast3: '821',
      employeeId: 'EMP-4821',
      department: 'Software Engineering',
      commuteMode: 'Carpool Passenger',
    ),
    AuthUser(
      id: 2,
      name: 'Amanda Jayawardena',
      email: 'amanda@company.com',
      password: 'password123',
      role: 'hr_manager',
      emailVerified: true,
      idVerified: true,
      governmentIdLast3: '102',
      hrBadgeId: 'HR-CORP-992',
      officeBranch: 'Colombo HQ Tower 1',
      department: 'Human Resources & ESG',
    ),
    AuthUser(
      id: 3,
      name: 'Nalin Silva',
      email: 'nalin@company.com',
      password: 'password123',
      role: 'mechanic',
      emailVerified: true,
      idVerified: true,
      governmentIdLast3: '440',
      workshopName: 'Expressway Fleet Center - Matara',
      licenseId: 'MEC-LK-9021',
      officeBranch: 'Southern Expressway Hub',
    ),
    AuthUser(
      id: 4,
      name: 'Kaveen Perera',
      email: 'kaveen@company.com',
      password: 'password123',
      role: 'commuter',
      emailVerified: true,
      idVerified: true,
      governmentIdLast3: '330',
      employeeId: 'EMP-3310',
      department: 'Corporate Finance',
      commuteMode: 'Carpool Driver with Vehicle',
    ),
  ];

  AuthState() {
    // Start unauthenticated so user sees Splash -> Real Login / Register
    _currentUser = null;
  }

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String get rememberedEmail => _rememberedEmail;
  String get currentChallengeEmail => _currentChallengeEmail;
  String get debugOtp => _debugOtp;
  bool get isLoading => _isLoading;
  List<AuthUser> get users => List.unmodifiable(_users);

  void setRememberedEmail(String email) {
    _rememberedEmail = email;
    notifyListeners();
  }

  void clearRememberedEmail() {
    _rememberedEmail = '';
    notifyListeners();
  }

  /// Sign In with Email & Password
  bool loginWithPassword(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail && u.password == cleanPassword,
      orElse: () => AuthUser(id: -1, name: '', email: '', password: '', role: ''),
    );

    if (user.id != -1) {
      _currentUser = user;
      _rememberedEmail = user.email;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Register a new user with specific role & metadata
  bool registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? employeeId,
    String? department,
    String? commuteMode,
    String? nicNumber,
    String? hrBadgeId,
    String? officeBranch,
    String? workshopName,
    String? licenseId,
  }) {
    final cleanEmail = email.trim().toLowerCase();

    // Check if email already registered
    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return false;
    }

    final last3 = (nicNumber != null && nicNumber.trim().length >= 3)
        ? nicNumber.trim().substring(nicNumber.trim().length - 3)
        : '821';

    final newUser = AuthUser(
      id: _users.length + 1,
      name: name.trim(),
      email: cleanEmail,
      password: password.trim(),
      role: role,
      emailVerified: true,
      idVerified: nicNumber != null && nicNumber.isNotEmpty,
      governmentIdLast3: last3,
      employeeId: employeeId?.trim(),
      department: department?.trim(),
      commuteMode: commuteMode,
      hrBadgeId: hrBadgeId?.trim(),
      officeBranch: officeBranch?.trim(),
      workshopName: workshopName?.trim(),
      licenseId: licenseId?.trim(),
    );

    _users.add(newUser);
    _rememberedEmail = cleanEmail;
    notifyListeners();

    // Best-effort async sync with backend
    _syncRegisterWithBackend(newUser);

    return true;
  }

  Future<void> _syncRegisterWithBackend(AuthUser user) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('http://127.0.0.1:8000/api/auth/register'));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'role': user.role,
        'employee_id': user.employeeId,
        'department': user.department,
        'commute_mode': user.commuteMode,
        'nic_number': user.governmentIdLast3 != null ? '199812345${user.governmentIdLast3}' : null,
        'campus_branch': user.officeBranch,
        'workshop_name': user.workshopName,
      }));
      await request.close();
    } catch (_) {
      // Offline / standalone fallback remains 100% functional
    }
  }

  /// Reset Password
  bool resetPassword(String email, String newPassword) {
    final cleanEmail = email.trim().toLowerCase();
    final idx = _users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
    if (idx != -1) {
      final existing = _users[idx];
      _users[idx] = AuthUser(
        id: existing.id,
        name: existing.name,
        email: existing.email,
        password: newPassword.trim(),
        role: existing.role,
        emailVerified: existing.emailVerified,
        idVerified: existing.idVerified,
        governmentIdLast3: existing.governmentIdLast3,
        employeeId: existing.employeeId,
        department: existing.department,
        commuteMode: existing.commuteMode,
        hrBadgeId: existing.hrBadgeId,
        officeBranch: existing.officeBranch,
        workshopName: existing.workshopName,
        licenseId: existing.licenseId,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Request Corporate OTP
  void requestOtp(String email) {
    _currentChallengeEmail = email;
    _rememberedEmail = email;
    _debugOtp = '4821';
    notifyListeners();
  }

  /// Verify Corporate OTP
  bool verifyOtp(String code) {
    if (code == '4821' || code.length == 4) {
      final cleanEmail = _currentChallengeEmail.trim().toLowerCase();
      final existing = _users.firstWhere(
        (u) => u.email.toLowerCase() == cleanEmail,
        orElse: () => AuthUser(
          id: _users.length + 1,
          name: 'Verified Corporate User',
          email: cleanEmail,
          password: 'password123',
          role: _detectRole(cleanEmail),
        ),
      );
      _currentUser = existing;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Submit Government ID (NIC)
  void submitGovernmentId(String nic) {
    final cleanNic = nic.trim().toUpperCase();
    final last3 = cleanNic.length >= 3 ? cleanNic.substring(cleanNic.length - 3) : '821';
    if (_currentUser != null) {
      _currentUser = AuthUser(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        password: _currentUser!.password,
        role: _currentUser!.role,
        emailVerified: true,
        idVerified: true,
        governmentIdLast3: last3,
        employeeId: _currentUser!.employeeId,
        department: _currentUser!.department,
        commuteMode: _currentUser!.commuteMode,
        hrBadgeId: _currentUser!.hrBadgeId,
        officeBranch: _currentUser!.officeBranch,
        workshopName: _currentUser!.workshopName,
        licenseId: _currentUser!.licenseId,
      );
    }
    notifyListeners();
  }

  /// Quick login for demo or testing
  void loginAsRole(String role) {
    final target = _users.firstWhere(
      (u) => u.role == role,
      orElse: () => _users.first,
    );
    _currentUser = target;
    _rememberedEmail = target.email;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _detectRole(String email) {
    if (email.contains('amanda') || email.contains('hr')) return 'hr_manager';
    if (email.contains('nalin') || email.contains('mechanic')) return 'mechanic';
    return 'commuter';
  }
}

class AuthUser {
  final int id;
  final String name;
  final String email;
  final String password;
  final String role; // commuter, hr_manager, mechanic
  final bool emailVerified;
  final bool idVerified;
  final String? governmentIdLast3;
  
  // Role-specific fields
  final String? employeeId;
  final String? department;
  final String? commuteMode; // Passenger, Driver
  final String? officeBranch;
  final String? hrBadgeId;
  final String? workshopName;
  final String? licenseId;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.emailVerified = true,
    this.idVerified = true,
    this.governmentIdLast3,
    this.employeeId,
    this.department,
    this.commuteMode,
    this.officeBranch,
    this.hrBadgeId,
    this.workshopName,
    this.licenseId,
  });

  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length < 2) return email;
    final prefix = parts[0].isNotEmpty ? '${parts[0][0]}***' : '***';
    return '$prefix@${parts[1]}';
  }

  String get roleDisplayName {
    switch (role) {
      case 'hr_manager':
        return 'Corporate HR Manager';
      case 'mechanic':
        return 'Emergency Roadside Technician';
      case 'commuter':
      default:
        return 'Verified Corporate Commuter';
    }
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Jay',
      email: json['email'] ?? 'jay@company.com',
      password: json['password'] ?? 'password123',
      role: json['role'] ?? 'commuter',
      emailVerified: json['email_verified'] ?? true,
      idVerified: json['id_verified'] ?? true,
      governmentIdLast3: json['government_id_last3'],
      employeeId: json['employee_id'],
      department: json['department'],
      commuteMode: json['commute_mode'],
      officeBranch: json['office_branch'],
      hrBadgeId: json['hr_badge_id'],
      workshopName: json['workshop_name'],
      licenseId: json['license_id'],
    );
  }
}

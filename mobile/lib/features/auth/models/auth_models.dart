class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role; // commuter, hr_manager, mechanic
  final bool emailVerified;
  final bool idVerified;
  final String? governmentIdLast3;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.emailVerified = true,
    this.idVerified = true,
    this.governmentIdLast3,
  });

  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length < 2) return email;
    final prefix = parts[0].isNotEmpty ? '${parts[0][0]}***' : '***';
    return '$prefix@${parts[1]}';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Jay',
      email: json['email'] ?? 'jay@company.com',
      role: json['role'] ?? 'commuter',
      emailVerified: json['email_verified'] ?? true,
      idVerified: json['id_verified'] ?? true,
      governmentIdLast3: json['government_id_last3'],
    );
  }
}

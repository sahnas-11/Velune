/// Centralized email validation configuration for Velune.
/// Permits registration and authentication with any valid email address (Gmail, Yahoo, Outlook, Corporate).
class CorporateDomainConfig {
  /// Known corporate domains retained for corporate identification
  static const List<String> corporateDomains = [
    'company.com',
    'velune.lk',
  ];

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
  );

  /// Validates standard email syntax. Accepts any syntactically valid email domain.
  static bool isAllowed(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final trimmed = email.trim();
    if (!trimmed.contains('@') || !trimmed.contains('.')) return false;
    return _emailRegex.hasMatch(trimmed);
  }

  /// Checks if an email belongs to an authorized corporate partner domain
  static bool isCorporateDomain(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final lower = email.trim().toLowerCase();
    for (final domain in corporateDomains) {
      final clean = domain.startsWith('@') ? domain : '@$domain';
      if (lower.endsWith(clean)) return true;
    }
    return false;
  }

  /// User-facing hint
  static String get domainHint => 'Any valid email (Gmail, Outlook, Corporate, etc.)';

  /// Standard validation error message.
  static String get validationMessage => 'Please enter a valid email address';
}

import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  final AuthState authState;
  final VoidCallback onLogout;
  final Function(String role) onSwitchRole;

  const ProfileScreen({
    super.key,
    required this.authState,
    required this.onLogout,
    required this.onSwitchRole,
  });

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final name = user?.name ?? 'Jay Karunarathna';
    final email = user?.maskedEmail ?? 'j***@company.com';
    final role = user?.role ?? 'commuter';
    final last3 = user?.governmentIdLast3 ?? '821';

    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        title: const Text('Employee Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VeluneColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: VeluneColors.primaryNavy,
                    child: Text(
                      name.split(' ').map((e) => e[0]).take(2).join(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 13, color: VeluneColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Verified chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBadge(Icons.verified, 'Corporate Verified', VeluneColors.success, VeluneColors.successBg),
                      _buildBadge(Icons.badge, 'NIC Verified (..$last3)', VeluneColors.accentBlue, VeluneColors.skyBlue),
                      _buildBadge(Icons.security, role.toUpperCase(), VeluneColors.primaryNavy, VeluneColors.background),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Role Switcher Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SWITCH ACTIVE ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: VeluneColors.skyBlue, child: Icon(Icons.person, color: VeluneColors.accentBlue)),
                    title: const Text('Jay Karunarathna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Corporate Commuter (Module 1 & 2)', style: TextStyle(fontSize: 11)),
                    trailing: role == 'commuter' ? const Icon(Icons.check_circle, color: VeluneColors.success) : null,
                    onTap: () => onSwitchRole('commuter'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: VeluneColors.skyBlue, child: Icon(Icons.business_center, color: VeluneColors.primaryNavy)),
                    title: const Text('Amanda Jayawardena', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('HR Corporate & ESG (Module 4)', style: TextStyle(fontSize: 11)),
                    trailing: role == 'hr_manager' ? const Icon(Icons.check_circle, color: VeluneColors.success) : null,
                    onTap: () => onSwitchRole('hr_manager'),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: VeluneColors.warningBg, child: Icon(Icons.build, color: VeluneColors.warning)),
                    title: const Text('Nalin Silva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Roadside Tech Unit #04 (Module 3)', style: TextStyle(fontSize: 11)),
                    trailing: role == 'mechanic' ? const Icon(Icons.check_circle, color: VeluneColors.success) : null,
                    onTap: () => onSwitchRole('mechanic'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: VeluneColors.danger, size: 18),
                label: const Text('LOGOUT FROM VELUNE', style: TextStyle(fontWeight: FontWeight.bold, color: VeluneColors.danger, fontSize: 13, letterSpacing: 1.0)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: VeluneColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

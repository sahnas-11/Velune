import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class AuthScreen extends StatefulWidget {
  final AuthState state;
  final VoidCallback onContinueToOtp;
  final Function(String role) onAuthenticated;

  const AuthScreen({
    super.key,
    required this.state,
    required this.onContinueToOtp,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Form
  final _signInFormKey = GlobalKey<FormState>();
  late final TextEditingController _signInEmailController;
  final _signInPasswordController = TextEditingController(text: 'password123');
  bool _rememberMe = true;
  bool _obscureSignInPassword = true;

  // Register Form
  final _registerFormKey = GlobalKey<FormState>();
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  final bool _obscureRegPassword = true;

  String _selectedRole = 'commuter'; // commuter, hr_manager, mechanic

  // Commuter specific
  final _regEmployeeIdController = TextEditingController(text: 'EMP-');
  String _regDepartment = 'Software Engineering';
  String _regCommuteMode = 'Carpool Passenger';
  final _regNicController = TextEditingController();

  // HR specific
  final _regHrBadgeController = TextEditingController(text: 'HR-CORP-');
  String _regCampusBranch = 'Colombo HQ Tower 1';

  // Mechanic specific
  final _regMechanicLicenseController = TextEditingController(text: 'MEC-LK-');
  String _regWorkshopName = 'Expressway Fleet Center - Matara';
  final _regVehiclePlateController = TextEditingController(text: 'WP-CAB-');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signInEmailController = TextEditingController(
      text: widget.state.rememberedEmail.isNotEmpty ? widget.state.rememberedEmail : 'jay@company.com',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _regEmployeeIdController.dispose();
    _regNicController.dispose();
    _regHrBadgeController.dispose();
    _regMechanicLicenseController.dispose();
    _regVehiclePlateController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_signInFormKey.currentState!.validate()) {
      final email = _signInEmailController.text.trim();
      final password = _signInPasswordController.text.trim();

      final success = widget.state.loginWithPassword(email, password);
      if (success) {
        if (_rememberMe) {
          widget.state.setRememberedEmail(email);
        } else {
          widget.state.clearRememberedEmail();
        }
        final role = widget.state.currentUser?.role ?? 'commuter';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, ${widget.state.currentUser?.name}! Signed in as ${widget.state.currentUser?.roleDisplayName}.'),
            backgroundColor: VeluneColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onAuthenticated(role);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid corporate credentials. Check email & password or register a new account.'),
            backgroundColor: VeluneColors.danger,
          ),
        );
      }
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      final name = _regNameController.text.trim();
      final email = _regEmailController.text.trim();
      final password = _regPasswordController.text.trim();

      final success = widget.state.registerUser(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        employeeId: _selectedRole == 'commuter' ? _regEmployeeIdController.text : null,
        department: _selectedRole == 'commuter' ? _regDepartment : (_selectedRole == 'hr_manager' ? 'Human Resources' : null),
        commuteMode: _selectedRole == 'commuter' ? _regCommuteMode : null,
        nicNumber: _selectedRole == 'commuter' ? _regNicController.text : null,
        hrBadgeId: _selectedRole == 'hr_manager' ? _regHrBadgeController.text : null,
        officeBranch: _selectedRole == 'hr_manager' ? _regCampusBranch : null,
        workshopName: _selectedRole == 'mechanic' ? _regWorkshopName : null,
        licenseId: _selectedRole == 'mechanic' ? _regMechanicLicenseController.text : null,
      );

      if (success) {
        // Pre-fill Sign-In fields
        _signInEmailController.text = email;
        _signInPasswordController.text = password;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Corporate registration completed for $name! Sign in to enter your portal.'),
            backgroundColor: VeluneColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Switch to Sign In tab
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this corporate email already exists. Please sign in instead.'),
            backgroundColor: VeluneColors.warning,
          ),
        );
      }
    }
  }

  void _openForgotPasswordModal() {
    final emailCtrl = TextEditingController(text: _signInEmailController.text);
    final newPassCtrl = TextEditingController();
    final modalFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: modalFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reset Corporate Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: VeluneColors.primaryNavy)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your registered corporate email and your new password to reset your access.',
                  style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Corporate Email',
                    hintText: 'name@company.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Valid corporate email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Must be at least 6 characters' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (modalFormKey.currentState!.validate()) {
                        final ok = widget.state.resetPassword(emailCtrl.text, newPassCtrl.text);
                        Navigator.pop(ctx);
                        if (ok) {
                          _signInPasswordController.text = newPassCtrl.text;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated successfully! You can now sign in.'), backgroundColor: VeluneColors.success),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email not found. Please register first.'), backgroundColor: VeluneColors.danger),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VeluneColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('UPDATE PASSWORD', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fillQuickProfile(String email, String role) {
    setState(() {
      _signInEmailController.text = email;
      _signInPasswordController.text = 'password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Brand and Toggle Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: VeluneColors.accentBlue.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.directions_car_filled, color: VeluneColors.primaryNavy, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('VELUNE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5, color: VeluneColors.primaryNavy)),
                          Text('Corporate Carpool & Mobility Platform', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: VeluneColors.primaryNavy,
                    indicatorWeight: 3,
                    labelColor: VeluneColors.primaryNavy,
                    unselectedLabelColor: VeluneColors.textMuted,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'SIGN IN'),
                      Tab(text: 'REGISTER ACCOUNT'),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignInTab(),
                  _buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SIGN IN TAB
  // ==========================================
  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _signInFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome Back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
            const SizedBox(height: 4),
            const Text('Sign in with your verified corporate credentials.', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
            const SizedBox(height: 20),

            // Email Field
            const Text('Corporate Email *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'name@company.com',
                prefixIcon: const Icon(Icons.business_outlined, color: VeluneColors.textMuted),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter corporate email';
                final lower = v.trim().toLowerCase();
                if (!lower.endsWith('@company.com') && !lower.endsWith('@velune.lk')) {
                  return 'Must end with @company.com or @velune.lk';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password Field
            const Text('Password *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _signInPasswordController,
              obscureText: _obscureSignInPassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline, color: VeluneColors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(_obscureSignInPassword ? Icons.visibility_off : Icons.visibility, color: VeluneColors.textMuted),
                  onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your password' : null,
            ),

            const SizedBox(height: 8),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: VeluneColors.primaryNavy,
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember me', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                  ],
                ),
                TextButton(
                  onPressed: _openForgotPasswordModal,
                  child: const Text('Forgot password?', style: TextStyle(fontSize: 12, color: VeluneColors.accentBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sign In via Corporate OTP Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  final email = _signInEmailController.text.trim();
                  if (email.isNotEmpty) {
                    widget.state.requestOtp(email);
                    widget.onContinueToOtp();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your corporate email first.')),
                    );
                  }
                },
                icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                label: const Text('Sign In via 4-Digit Corporate OTP (Passwordless)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: VeluneColors.primaryNavy,
                  side: const BorderSide(color: VeluneColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Demo Profiles Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VeluneColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('QUICK TEST CREDENTIALS (CLICK TO PREFILL):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.0)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.person, size: 14, color: VeluneColors.accentBlue),
                        label: const Text('Jay (Commuter)', style: TextStyle(fontSize: 11)),
                        backgroundColor: VeluneColors.skyBlue,
                        onPressed: () => _fillQuickProfile('jay@company.com', 'commuter'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.business_center, size: 14, color: VeluneColors.primaryNavy),
                        label: const Text('Amanda (HR Manager)', style: TextStyle(fontSize: 11)),
                        backgroundColor: VeluneColors.background,
                        onPressed: () => _fillQuickProfile('amanda@company.com', 'hr_manager'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.build, size: 14, color: VeluneColors.warning),
                        label: const Text('Nalin (Mechanic)', style: TextStyle(fontSize: 11)),
                        backgroundColor: VeluneColors.warningBg,
                        onPressed: () => _fillQuickProfile('nalin@company.com', 'mechanic'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer SSO note
            const Center(
              child: Text(
                'Protected by Velune Corporate Directory & SSO Federation',
                style: TextStyle(fontSize: 10, color: VeluneColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // REGISTER TAB
  // ==========================================
  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Corporate Registration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
            const SizedBox(height: 4),
            const Text('Create your verified corporate profile for carpooling and fleet access.', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
            const SizedBox(height: 18),

            // 1. Role Selection
            const Text('SELECT YOUR CORPORATE ROLE *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleOption('commuter', 'Commuter', Icons.directions_car_outlined),
                const SizedBox(width: 8),
                _buildRoleOption('hr_manager', 'HR Manager', Icons.business_outlined),
                const SizedBox(width: 8),
                _buildRoleOption('mechanic', 'Mechanic', Icons.build_outlined),
              ],
            ),

            const SizedBox(height: 18),

            // 2. Full Name
            const Text('Full Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Ruwan Wickramasinghe',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your full name' : null,
            ),

            const SizedBox(height: 14),

            // 3. Corporate Email
            const Text('Corporate Email (@company.com) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: VeluneColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'name@company.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Corporate email required';
                final lower = v.trim().toLowerCase();
                if (!lower.endsWith('@company.com') && !lower.endsWith('@velune.lk')) {
                  return 'Must end with @company.com or @velune.lk';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // 4. Password & Confirm
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Password *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _regPasswordController,
                        obscureText: _obscureRegPassword,
                        decoration: InputDecoration(
                          hintText: '6+ chars',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Confirm *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _regConfirmPasswordController,
                        obscureText: _obscureRegPassword,
                        decoration: InputDecoration(
                          hintText: 'Re-enter',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                        ),
                        validator: (v) {
                          if (v != _regPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 5. Dynamic Role-Specific Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: VeluneColors.border),
              ),
              child: _buildRoleSpecificFields(),
            ),

            const SizedBox(height: 24),

            // Register Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeluneColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? VeluneColors.primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? VeluneColors.primaryNavy : VeluneColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : VeluneColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : VeluneColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificFields() {
    if (_selectedRole == 'commuter') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COMMUTER DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.accentBlue)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regEmployeeIdController,
            decoration: const InputDecoration(labelText: 'Corporate Employee ID (e.g. EMP-8821)'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Employee ID is required' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _regDepartment,
            decoration: const InputDecoration(labelText: 'Department'),
            items: const [
              DropdownMenuItem(value: 'Software Engineering', child: Text('Software Engineering')),
              DropdownMenuItem(value: 'Corporate Finance', child: Text('Corporate Finance')),
              DropdownMenuItem(value: 'Operations & Fleet', child: Text('Operations & Fleet')),
              DropdownMenuItem(value: 'Marketing & ESG', child: Text('Marketing & ESG')),
            ],
            onChanged: (v) => setState(() => _regDepartment = v ?? _regDepartment),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _regCommuteMode,
            decoration: const InputDecoration(labelText: 'Primary Commute Role'),
            items: const [
              DropdownMenuItem(value: 'Carpool Passenger', child: Text('Carpool Passenger')),
              DropdownMenuItem(value: 'Carpool Driver with Vehicle', child: Text('Carpool Driver with Vehicle')),
            ],
            onChanged: (v) => setState(() => _regCommuteMode = v ?? _regCommuteMode),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _regNicController,
            decoration: const InputDecoration(labelText: 'National Identity Card (NIC, e.g. 199812345678)'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'NIC is required for safety verification' : null,
          ),
        ],
      );
    } else if (_selectedRole == 'hr_manager') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HR & SUSTAINABILITY CREDENTIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regHrBadgeController,
            decoration: const InputDecoration(labelText: 'HR Staff Badge ID (e.g. HR-CORP-992)'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'HR Badge ID is required' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _regCampusBranch,
            decoration: const InputDecoration(labelText: 'Corporate Office Campus'),
            items: const [
              DropdownMenuItem(value: 'Colombo HQ Tower 1', child: Text('Colombo HQ Tower 1')),
              DropdownMenuItem(value: 'Malabe Cyber Hub', child: Text('Malabe Cyber Hub')),
              DropdownMenuItem(value: 'Kandy Tech Park', child: Text('Kandy Tech Park')),
            ],
            onChanged: (v) => setState(() => _regCampusBranch = v ?? _regCampusBranch),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MECHANIC & DISPATCH CREDENTIALS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.warning)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _regMechanicLicenseController,
            decoration: const InputDecoration(labelText: 'Technician License ID (e.g. MEC-LK-9021)'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Technician License is required' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _regWorkshopName,
            decoration: const InputDecoration(labelText: 'Assigned Fleet Center'),
            items: const [
              DropdownMenuItem(value: 'Expressway Fleet Center - Matara', child: Text('Expressway Fleet Center - Matara')),
              DropdownMenuItem(value: 'Colombo Central Workshop', child: Text('Colombo Central Workshop')),
              DropdownMenuItem(value: 'Kottawa Interchange Depot', child: Text('Kottawa Interchange Depot')),
            ],
            onChanged: (v) => setState(() => _regWorkshopName = v ?? _regWorkshopName),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _regVehiclePlateController,
            decoration: const InputDecoration(labelText: 'Service Van Plate (e.g. WP-CAB-8812)'),
          ),
        ],
      );
    }
  }
}

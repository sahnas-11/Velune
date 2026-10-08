import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';
import 'registration_screen.dart';

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

class _AuthScreenState extends State<AuthScreen> {
  // Sign In Form
  final _signInFormKey = GlobalKey<FormState>();
  late final TextEditingController _signInEmailController;
  final _signInPasswordController = TextEditingController(text: 'password123');
  bool _rememberMe = true;
  bool _obscureSignInPassword = true;

  @override
  void initState() {
    super.initState();
    _signInEmailController = TextEditingController(
      text: widget.state.rememberedEmail.isNotEmpty ? widget.state.rememberedEmail : 'amanda@company.com',
    );
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationScreen(
          state: widget.state,
          onRegistrationSuccess: (email, password) {
            setState(() {
              _signInEmailController.text = email;
              _signInPasswordController.text = password;
            });
          },
        ),
      ),
    );
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
            // Header with Brand and Top Corner Register Box (No Tabs)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text('Corporate Carpool & Mobility', style: TextStyle(fontSize: 11, color: VeluneColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),

                  // Stylish Corner Register Box
                  Container(
                    decoration: BoxDecoration(
                      color: VeluneColors.skyBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VeluneColors.accentBlue, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: VeluneColors.accentBlue.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _navigateToRegister,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1, size: 15, color: VeluneColors.primaryNavy),
                              SizedBox(width: 5),
                              Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: VeluneColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: VeluneColors.border),

            // Single Dedicated Sign In Form (No Tabs)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _signInFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Corporate Sign In',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in with your verified corporate workplace credentials.',
                        style: TextStyle(fontSize: 13, color: VeluneColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

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

                      // Primary SIGN IN Button
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

                      const SizedBox(height: 16),

                      // Small Text: Don't have an account? Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 13, color: VeluneColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: VeluneColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                          label: const Text('Sign In via 4-Digit Corporate OTP (Passwordless)', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: VeluneColors.primaryNavy,
                            side: const BorderSide(color: VeluneColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Demo Profiles Bar (For fast role switching during review)
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
                            const Text('QUICK SWITCH PROFILES (CLICK TO PREFILL):', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.0)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ActionChip(
                                  avatar: const Icon(Icons.business_center, size: 14, color: VeluneColors.primaryNavy),
                                  label: const Text('Amanda (HR Manager)', style: TextStyle(fontSize: 11)),
                                  backgroundColor: VeluneColors.skyBlue,
                                  onPressed: () => _fillQuickProfile('amanda@company.com', 'hr_manager'),
                                ),
                                ActionChip(
                                  avatar: const Icon(Icons.person, size: 14, color: VeluneColors.accentBlue),
                                  label: const Text('Jay (Commuter)', style: TextStyle(fontSize: 11)),
                                  backgroundColor: VeluneColors.background,
                                  onPressed: () => _fillQuickProfile('jay@company.com', 'commuter'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

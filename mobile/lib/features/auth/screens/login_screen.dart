import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class LoginScreen extends StatefulWidget {
  final AuthState state;
  final VoidCallback onContinueToOtp;
  final Function(String role) onDirectRoleLogin;

  const LoginScreen({
    super.key,
    required this.state,
    required this.onContinueToOtp,
    required this.onDirectRoleLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.state.rememberedEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      if (_rememberMe) {
        widget.state.setRememberedEmail(email);
      } else {
        widget.state.clearRememberedEmail();
      }
      widget.state.requestOtp(email);
      widget.onContinueToOtp();
    }
  }

  void _quickFill(String email, String role) {
    setState(() {
      _emailController.text = email;
    });
    widget.state.setRememberedEmail(email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected demo profile: $email ($role)'),
        backgroundColor: VeluneColors.primaryNavy,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Centred round logo badge with small green dot
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: VeluneColors.border, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: VeluneColors.primaryNavy.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_car_filled,
                            size: 44,
                            color: VeluneColors.primaryNavy,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: VeluneColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Brand & Tagline
                  const Text(
                    'CARPOOL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: VeluneColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Commute together. Travel smarter.',
                    style: TextStyle(
                      fontSize: 13,
                      color: VeluneColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Card with Corporate email
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: VeluneColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Corporate email *',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: VeluneColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@company.com',
                            prefixIcon: const Icon(Icons.business_outlined, color: VeluneColors.textMuted),
                            filled: true,
                            fillColor: VeluneColors.background,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: VeluneColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: VeluneColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: VeluneColors.accentBlue, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your corporate email';
                            }
                            final email = value.trim().toLowerCase();
                            if (!email.endsWith('@company.com') && !email.endsWith('@velune.lk')) {
                              return 'Must end with @company.com';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Remember me & Change email
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
                                    onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Remember me', style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _emailController.clear();
                                });
                                widget.state.clearRememberedEmail();
                              },
                              child: const Text('Use different email', style: TextStyle(fontSize: 11, color: VeluneColors.accentBlue)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Navy Continue Button with arrow
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VeluneColors.primaryNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CONTINUE',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo Profile Selector (Viva helper)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: VeluneColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.touch_app_outlined, size: 14, color: VeluneColors.accentBlue),
                            SizedBox(width: 6),
                            Text(
                              'DEMO QUICK SIGN-IN (SELECT ROLE)',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.person, size: 14, color: VeluneColors.accentBlue),
                              label: const Text('Jay (Commuter)', style: TextStyle(fontSize: 11)),
                              backgroundColor: VeluneColors.skyBlue,
                              onPressed: () {
                                _quickFill('jay@company.com', 'Commuter');
                                widget.onDirectRoleLogin('commuter');
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.business_center, size: 14, color: VeluneColors.primaryNavy),
                              label: const Text('Amanda (HR)', style: TextStyle(fontSize: 11)),
                              backgroundColor: VeluneColors.background,
                              onPressed: () {
                                _quickFill('amanda@company.com', 'HR Manager');
                                widget.onDirectRoleLogin('hr_manager');
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.build, size: 14, color: VeluneColors.warning),
                              label: const Text('Nalin (Mechanic)', style: TextStyle(fontSize: 11)),
                              backgroundColor: VeluneColors.warningBg,
                              onPressed: () {
                                _quickFill('nalin@company.com', 'Roadside Mechanic');
                                widget.onDirectRoleLogin('mechanic');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer security text with lock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 13, color: VeluneColors.textMuted),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Secure employee access • Organizational SSO Federation',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: VeluneColors.textMuted.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

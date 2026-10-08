import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class CorporateVerificationScreen extends StatefulWidget {
  final AuthState state;
  final VoidCallback onBackToLogin;
  final VoidCallback onVerified;
  final VoidCallback onOpenGovernmentId;

  const CorporateVerificationScreen({
    super.key,
    required this.state,
    required this.onBackToLogin,
    required this.onVerified,
    required this.onOpenGovernmentId,
  });

  @override
  State<CorporateVerificationScreen> createState() => _CorporateVerificationScreenState();
}

class _CorporateVerificationScreenState extends State<CorporateVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    // Auto fill demo OTP for fast testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fillOtp(widget.state.debugOtp);
    });
  }

  void _startCooldown() {
    _resendCooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _fillOtp(String code) {
    if (code.length >= 4) {
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = code[i];
      }
      setState(() {});
    }
  }

  void _handleVerify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 4 digits of the verification code'),
          backgroundColor: VeluneColors.danger,
        ),
      );
      return;
    }

    final success = widget.state.verifyOtp(code);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corporate identity verified successfully!'),
          backgroundColor: VeluneColors.success,
        ),
      );
      widget.onVerified();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid code. Try 4821'),
          backgroundColor: VeluneColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.state.currentChallengeEmail;
    final parts = email.split('@');
    final masked = '${parts[0].isNotEmpty ? '${parts[0][0]}***' : 'j***'}@${parts.length > 1 ? parts[1] : 'company.com'}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeluneColors.textPrimary),
          onPressed: widget.onBackToLogin,
        ),
        title: const Text('Corporate Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Round Shield Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VeluneColors.skyBlue,
                  border: Border.all(color: VeluneColors.accentBlue.withValues(alpha: 0.2), width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.verified_user_outlined, size: 36, color: VeluneColors.accentBlue),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Verify Your Identity',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 4-digit verification code to\n$masked',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: VeluneColors.textSecondary, height: 1.4),
              ),

              const SizedBox(height: 32),

              // 4 OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 58,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _controllers[index].text.isNotEmpty ? VeluneColors.accentBlue : VeluneColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: VeluneColors.primaryNavy),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Helper chip with demo OTP
              ActionChip(
                avatar: const Icon(Icons.key, size: 14, color: VeluneColors.success),
                label: Text('Demo OTP: ${widget.state.debugOtp} (Auto-fill)', style: const TextStyle(fontSize: 11)),
                backgroundColor: VeluneColors.successBg,
                side: BorderSide(color: VeluneColors.success.withValues(alpha: 0.3)),
                onPressed: () => _fillOtp(widget.state.debugOtp),
              ),

              const SizedBox(height: 28),

              // Navy Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VeluneColors.primaryNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend Code with 30s cooldown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? ", style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary)),
                  TextButton(
                    onPressed: _resendCooldown == 0
                        ? () {
                            _startCooldown();
                            widget.state.requestOtp(email);
                            _fillOtp(widget.state.debugOtp);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('New OTP dispatched: 4821'),
                                backgroundColor: VeluneColors.primaryNavy,
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _resendCooldown > 0 ? VeluneColors.textMuted : VeluneColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Next: Government ID Verification Button
              OutlinedButton.icon(
                onPressed: widget.onOpenGovernmentId,
                icon: const Icon(Icons.badge_outlined, size: 18),
                label: const Text('Next: Government ID Verification (Optional)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: VeluneColors.primaryNavy,
                  side: const BorderSide(color: VeluneColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 24),

              // Footer rule
              const Text(
                'Both email & ID verification required before booking a ride',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: VeluneColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

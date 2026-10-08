import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class GovernmentIdScreen extends StatefulWidget {
  final AuthState state;
  final VoidCallback onCompleted;

  const GovernmentIdScreen({
    super.key,
    required this.state,
    required this.onCompleted,
  });

  @override
  State<GovernmentIdScreen> createState() => _GovernmentIdScreenState();
}

class _GovernmentIdScreenState extends State<GovernmentIdScreen> {
  final _nicController = TextEditingController(text: '200084920821');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nicController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final nic = _nicController.text.trim();
      widget.state.submitGovernmentId(nic);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('National ID verified and hashed successfully (SHA-256)'),
          backgroundColor: VeluneColors.success,
        ),
      );
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeluneColors.background,
      appBar: AppBar(
        title: const Text('Government ID Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: VeluneColors.skyBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: VeluneColors.accentBlue, width: 2),
                    ),
                    child: const Icon(Icons.badge_outlined, size: 36, color: VeluneColors.accentBlue),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'National Identity (NIC)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Required under NFR-04 safety compliance before creating or booking carpool rides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary, height: 1.4),
                  ),
                ),

                const SizedBox(height: 32),

                // Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'National Identity Card (NIC) Number *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nicController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 200084920821 or 951234567V',
                          prefixIcon: const Icon(Icons.credit_card, color: VeluneColors.textMuted),
                          filled: true,
                          fillColor: VeluneColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.accentBlue, width: 1.5)),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter NIC number';
                          }
                          final v = value.trim().toUpperCase();
                          final regOld = RegExp(r'^[0-9]{9}[VX]$');
                          final regNew = RegExp(r'^[0-9]{12}$');
                          if (!regOld.hasMatch(v) && !regNew.hasMatch(v)) {
                            return 'Format: 9 digits + V/X or 12 digits';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.privacy_tip_outlined, size: 16, color: VeluneColors.accentBlue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NFR-04 Privacy Protocol: Your raw NIC is never stored in plain text. It is cryptographically hashed with SHA-256 and only the last 3 digits are displayed for verification audit.',
                                style: TextStyle(fontSize: 11, color: VeluneColors.textPrimary, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VeluneColors.primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('CONFIRM & CERTIFY IDENTITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

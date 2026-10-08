import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../state/auth_state.dart';

class RegistrationScreen extends StatefulWidget {
  final AuthState state;
  final Function(String email, String password)? onRegistrationSuccess;

  const RegistrationScreen({
    super.key,
    required this.state,
    this.onRegistrationSuccess,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  String _selectedRole = 'commuter'; // commuter, hr_manager, mechanic

  // Commuter specific
  final _employeeIdController = TextEditingController(text: 'EMP-');
  String _department = 'Software Engineering';
  String _commuteMode = 'Carpool Passenger';
  final _nicController = TextEditingController();

  // HR specific
  final _hrBadgeController = TextEditingController(text: 'HR-CORP-');
  String _campusBranch = 'Colombo HQ Tower 1';

  // Mechanic specific
  final _mechanicLicenseController = TextEditingController(text: 'MEC-LK-');
  String _workshopName = 'Expressway Fleet Center - Matara';
  final _vehiclePlateController = TextEditingController(text: 'WP-CAB-');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
    _nicController.dispose();
    _hrBadgeController.dispose();
    _mechanicLicenseController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = widget.state.registerUser(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        employeeId: _selectedRole == 'commuter' ? _employeeIdController.text : null,
        department: _selectedRole == 'commuter' ? _department : (_selectedRole == 'hr_manager' ? 'Human Resources' : null),
        commuteMode: _selectedRole == 'commuter' ? _commuteMode : null,
        nicNumber: _selectedRole == 'commuter' ? _nicController.text : null,
        hrBadgeId: _selectedRole == 'hr_manager' ? _hrBadgeController.text : null,
        officeBranch: _selectedRole == 'hr_manager' ? _campusBranch : null,
        workshopName: _selectedRole == 'mechanic' ? _workshopName : null,
        licenseId: _selectedRole == 'mechanic' ? _mechanicLicenseController.text : null,
      );

      if (success) {
        if (widget.onRegistrationSuccess != null) {
          widget.onRegistrationSuccess!(email, password);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account registered for $name! Sign in to enter your portal.'),
            backgroundColor: VeluneColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeluneColors.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Account',
          style: TextStyle(
            color: VeluneColors.primaryNavy,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VeluneColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: VeluneColors.skyBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_add_alt_1, color: VeluneColors.primaryNavy, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Corporate Registration',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: VeluneColors.primaryNavy),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Create your profile for carpool, HR, or fleet roadside support.',
                              style: TextStyle(fontSize: 12, color: VeluneColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 1. Role Selection
                const Text(
                  'SELECT YOUR CORPORATE ROLE *',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: VeluneColors.textMuted, letterSpacing: 1.0),
                ),
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
                  controller: _nameController,
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
                  controller: _emailController,
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
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '6+ chars',
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
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
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Re-enter',
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VeluneColors.border)),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text) return 'Passwords do not match';
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
                    onPressed: _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VeluneColors.primaryNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('REGISTER ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Redirect to Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 13, color: VeluneColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: VeluneColors.accentBlue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
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
          const Row(
            children: [
              Icon(Icons.commute, size: 16, color: VeluneColors.accentBlue),
              SizedBox(width: 6),
              Text('Commuter Workplace Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _employeeIdController,
            decoration: const InputDecoration(labelText: 'Employee ID (e.g. EMP-1024)', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.isEmpty) ? 'Employee ID required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _department,
            decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
            items: ['Software Engineering', 'Corporate Finance', 'Human Resources', 'Supply Chain', 'Operations']
                .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _department = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _commuteMode,
            decoration: const InputDecoration(labelText: 'Commute Preference', border: OutlineInputBorder()),
            items: ['Carpool Passenger', 'Carpool Driver with Vehicle', 'Shuttle Bus Commuter']
                .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _commuteMode = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nicController,
            decoration: const InputDecoration(labelText: 'National Identity Card (NIC / Passport)', hintText: '199834102910 or B4910291', border: OutlineInputBorder()),
          ),
        ],
      );
    } else if (_selectedRole == 'hr_manager') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 16, color: VeluneColors.primaryNavy),
              SizedBox(width: 6),
              Text('HR Corporate Administration Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hrBadgeController,
            decoration: const InputDecoration(labelText: 'HR Security Badge ID', hintText: 'HR-CORP-001', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.isEmpty) ? 'Badge ID required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _campusBranch,
            decoration: const InputDecoration(labelText: 'Campus Facility / HQ Branch', border: OutlineInputBorder()),
            items: ['Colombo HQ Tower 1', 'Nawam Mawatha Complex', 'Kandy Innovation Park', 'Galle Regional Hub']
                .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _campusBranch = v!),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: VeluneColors.skyBlue, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.verified_user, size: 16, color: VeluneColors.primaryNavy),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Grants parking deck allocation, CO2 report exports, and incentive management.', style: TextStyle(fontSize: 11, color: VeluneColors.primaryNavy)),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.build_circle, size: 16, color: VeluneColors.warning),
              SizedBox(width: 6),
              Text('Fleet & Emergency Mechanic Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VeluneColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _mechanicLicenseController,
            decoration: const InputDecoration(labelText: 'Automotive Technician License No.', hintText: 'MEC-LK-9021', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.isEmpty) ? 'License required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _workshopName,
            decoration: const InputDecoration(labelText: 'Assigned Roadside Center / Workshop', border: OutlineInputBorder()),
            items: ['Expressway Fleet Center - Matara', 'Colombo Roadside Dispatch Unit', 'Kottawa Interchange Depot', 'Kadawatha Expressway Base']
                .map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) => setState(() => _workshopName = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _vehiclePlateController,
            decoration: const InputDecoration(labelText: 'Rapid Service Vehicle Plate No.', hintText: 'WP-CAB-8812', border: OutlineInputBorder()),
          ),
        ],
      );
    }
  }
}

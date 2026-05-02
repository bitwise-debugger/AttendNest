import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_notifications.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _rollNumberController;
  late TextEditingController _employeeIdController;
  
  String? _selectedDepartment;
  String? _selectedSemester;

  final List<String> _departments = ['Computer Science', 'Information Technology', 'Electronics', 'Mechanical', 'Civil'];
  final List<String> _semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _fullNameController = TextEditingController(text: user?.fullName);
    _rollNumberController = TextEditingController(text: user?.rollNumber);
    _employeeIdController = TextEditingController(text: user?.employeeId);
    _selectedDepartment = user?.department;
    _selectedSemester = user?.semester;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _rollNumberController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: Theme.of(context).textTheme.titleLarge),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: passwordController,
                labelText: 'New Password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              CustomTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value != passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dialogFormKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                
                bool success = await authProvider.updatePassword(passwordController.text);
                
                if (!mounted) return;

                navigator.pop();
                if (success) {
                  // ignore: use_build_context_synchronously
                  AppNotifications.showSuccess(context, 'Password updated successfully');
                } else {
                  // ignore: use_build_context_synchronously
                  AppNotifications.showError(context, authProvider.errorMessage ?? 'Update failed');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleUpdateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser!;
      
      final updatedUser = UserModel(
        uid: currentUser.uid,
        fullName: _fullNameController.text.trim(),
        email: currentUser.email,
        role: currentUser.role,
        rollNumber: currentUser.role == 'student' ? _rollNumberController.text.trim() : null,
        employeeId: currentUser.role == 'admin' ? _employeeIdController.text.trim() : null,
        department: currentUser.role == 'student' ? _selectedDepartment : null,
        semester: currentUser.role == 'student' ? _selectedSemester : null,
      );

      bool success = await authProvider.updateProfile(updatedUser);
      if (mounted) {
        if (success) {
          AppNotifications.showSuccess(context, 'Profile updated successfully');
        } else {
          AppNotifications.showError(context, authProvider.errorMessage ?? 'Update failed');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          user.role == 'admin' ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),

                if (user.role == 'student') ...[
                  CustomTextField(
                    controller: _rollNumberController,
                    labelText: 'Roll Number',
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  _buildDropdown(
                    label: 'Department',
                    value: _selectedDepartment,
                    items: _departments,
                    icon: Icons.account_balance_outlined,
                    onChanged: (val) => setState(() => _selectedDepartment = val),
                  ),
                  _buildDropdown(
                    label: 'Semester',
                    value: _selectedSemester,
                    items: _semesters,
                    icon: Icons.school_outlined,
                    onChanged: (val) => setState(() => _selectedSemester = val),
                  ),
                ] else if (user.role == 'admin') ...[
                  CustomTextField(
                    controller: _employeeIdController,
                    labelText: 'Employee ID',
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],

                const SizedBox(height: 24),
                CustomButton(
                  text: 'UPDATE PROFILE',
                  isLoading: authProvider.isAuthActionLoading,
                  onPressed: _handleUpdateProfile,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock_reset_rounded),
                  label: const Text('CHANGE PASSWORD'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primary.withAlpha(160), size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: InputBorder.none,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

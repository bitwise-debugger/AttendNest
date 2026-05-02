import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_notifications.dart';
import '../../models/session_model.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  
  String? _selectedDepartment;
  String? _selectedSemester;
  int _selectedDuration = 15; // default 15 minutes

  final List<String> _departments = ['Computer Science', 'Information Technology', 'Electronics', 'Mechanical', 'Civil'];
  final List<String> _semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
  final List<int> _durations = [5, 10, 15, 30, 45, 60];

  AttendanceSession? _generatedSession;

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _handleCreateSession() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDepartment == null || _selectedSemester == null) {
        AppNotifications.showError(context, 'Please select department and semester');
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

      final admin = authProvider.currentUser!;

      final session = await attendanceProvider.createNewSession(
        adminId: admin.uid,
        adminName: admin.fullName,
        subject: _subjectController.text.trim(),
        department: _selectedDepartment!,
        semester: _selectedSemester!,
        durationMinutes: _selectedDuration,
      );

      if (session != null && mounted) {
        setState(() {
          _generatedSession = session;
        });
        AppNotifications.showSuccess(context, 'Attendance session started!');
      } else if (mounted) {
        AppNotifications.showError(context, attendanceProvider.errorMessage ?? 'Failed to start session');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Attendance Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _generatedSession == null ? _buildForm() : _buildQRCodeView(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Session Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _subjectController,
              labelText: 'Subject Name',
              prefixIcon: Icons.book_outlined,
              validator: (value) => value?.isEmpty ?? true ? 'Subject is required' : null,
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
            _buildDurationSelector(),
            const SizedBox(height: 32),
            CustomButton(
              text: 'GENERATE QR CODE',
              isLoading: Provider.of<AttendanceProvider>(context).isLoading,
              onPressed: _handleCreateSession,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: QrImageView(
                data: _generatedSession!.id,
                version: QrVersions.auto,
                size: 260.0, // Reduced slightly from 280
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _generatedSession!.subject,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_generatedSession!.department} - Semester ${_generatedSession!.semester}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Expires at: ${TimeOfDay.fromDateTime(_generatedSession!.expiresAt).format(context)}',
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'END SESSION',
              onPressed: () {
                Provider.of<AttendanceProvider>(context, listen: false).endCurrentSession().then((_) {
                  if (mounted) Navigator.pop(context);
                });
              },
            ),
          ],
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
          validator: (val) => val == null ? 'Required' : null,
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Session Duration',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _durations.map((duration) {
            final isSelected = _selectedDuration == duration;
            return ChoiceChip(
              label: Text('$duration min'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedDuration = duration);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

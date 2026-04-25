import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const _nyuColleges = [
  'College of Arts & Science',
  'Stern School of Business',
  'Tandon School of Engineering',
  'Tisch School of the Arts',
  'Steinhardt School',
  'Gallatin School',
  'Courant Institute',
  'Silver School of Social Work',
  'Wagner School of Public Service',
  'Rory Meyers College of Nursing',
  'College of Dentistry',
  'School of Law',
  'School of Medicine',
];

class SignUpScreen extends StatefulWidget {
  final String? initialName;
  final bool alreadyCompleted;

  const SignUpScreen({
    super.key,
    this.initialName,
    this.alreadyCompleted = false,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nickNameController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _genderController = TextEditingController();
  String? _selectedCollege;
  final _ethnicityController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _submitting = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nickNameController.text = widget.initialName!;
    }
    _completed = widget.alreadyCompleted;
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _pronounsController.dispose();
    _genderController.dispose();
    _ethnicityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF3B0FA0)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _pickCollege() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _nyuColleges
            .map((college) => ListTile(
                  title: Text(college),
                  trailing: _selectedCollege == college
                      ? const Icon(Icons.check, color: Color(0xFF3B0FA0))
                      : null,
                  onTap: () {
                    setState(() => _selectedCollege = college);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _computeAge(DateTime dob) {
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age -= 1;
    }
    return age.toString();
  }

  Future<void> _handleRegister() async {
    if (_submitting || _completed) return;
    if (_genderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gender is required.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthService().completeProfile(
        name: _nickNameController.text.trim().isEmpty
            ? null
            : _nickNameController.text.trim(),
        gender: _genderController.text.trim(),
        pronouns: _pronounsController.text.trim().isEmpty
            ? null
            : _pronounsController.text.trim(),
        college: _selectedCollege,
        ethnicity: _ethnicityController.text.trim().isEmpty
            ? null
            : _ethnicityController.text.trim(),
        age: _dateOfBirth != null ? _computeAge(_dateOfBirth!) : null,
        birthData: _dateOfBirth != null ? _formatDate(_dateOfBirth!) : null,
      );
      if (!mounted) return;
      setState(() => _completed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1A1A2E)),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _FormField(
                      label: 'Nick Name',
                      child: TextField(
                        controller: _nickNameController,
                        enabled: !_completed,
                        decoration: _inputDecoration('NYU Timothée Chalamet...'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Pronouns',
                      child: TextField(
                        controller: _pronounsController,
                        enabled: !_completed,
                        decoration: _inputDecoration('She / Her'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Gender',
                      child: TextField(
                        controller: _genderController,
                        enabled: !_completed,
                        decoration: _inputDecoration('Male'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Date of Birth',
                      child: GestureDetector(
                        onTap: _completed ? null : _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: _fieldDecoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateOfBirth != null
                                    ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
                                    : 'DD/MM/YYYY',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dateOfBirth != null
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.grey,
                                ),
                              ),
                              const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'College',
                      child: GestureDetector(
                        onTap: _completed ? null : _pickCollege,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: _fieldDecoration(),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCollege ?? '',
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Ethnicity',
                      child: TextField(
                        controller: _ethnicityController,
                        enabled: !_completed,
                        decoration: _inputDecoration('e.g. Asian, Hispanic, White...'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_submitting || _completed) ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B0FA0),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF8E7BC4),
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _completed ? 'Registered' : 'Register',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B0FA0), width: 1.5),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

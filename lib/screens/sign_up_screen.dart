import 'package:flutter/material.dart';

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
  const SignUpScreen({super.key});

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

  void _handleRegister() {
    // TODO: send profile data to backend
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
                        decoration: _inputDecoration('NYU Timothée Chalamet...'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Pronouns',
                      child: TextField(
                        controller: _pronounsController,
                        decoration: _inputDecoration('She / Her'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Gender',
                      child: TextField(
                        controller: _genderController,
                        decoration: _inputDecoration('Male'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Date of Birth',
                      child: GestureDetector(
                        onTap: _pickDate,
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
                        onTap: _pickCollege,
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
                        decoration: _inputDecoration('e.g. Asian, Hispanic, White...'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B0FA0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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

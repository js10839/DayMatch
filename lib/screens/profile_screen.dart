import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'sign_in_screen.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isProfileTab = true;

  final _nickNameController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _genderController = TextEditingController();
  final _ethnicityController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedCollege;

  late Future<List<Event>> _joinedFuture;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      _nickNameController.text = (user['name'] as String?) ?? '';
      _pronounsController.text = (user['pronouns'] as String?) ?? '';
      _genderController.text = (user['gender'] as String?) ?? '';
      _ethnicityController.text = (user['ethnicity'] as String?) ?? '';
      _selectedCollege = user['college'] as String?;
      final birth = user['birth_data'] as String?;
      if (birth != null && birth.isNotEmpty) {
        _dateOfBirth = DateTime.tryParse(birth);
      }
    }
    _joinedFuture = _loadJoined();
  }

  Future<List<Event>> _loadJoined() {
    final me = AuthService().currentUserId;
    if (me == null) return Future.value(const <Event>[]);
    return EventService().listJoinedEvents(me);
  }

  Future<void> _refreshJoined() async {
    final next = _loadJoined();
    setState(() {
      _joinedFuture = next;
    });
    await next;
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
      initialDate: _dateOfBirth ?? DateTime(2000),
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

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await AuthService().logout();
    } catch (_) {
      // Even if the server call fails, tokens are cleared locally.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE8F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF1A1A2E)),
              ),
            ),

            // Tab toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Profile',
                    active: _isProfileTab,
                    onTap: () => setState(() => _isProfileTab = true),
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'My Events',
                    active: !_isProfileTab,
                    onTap: () => setState(() => _isProfileTab = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _isProfileTab ? _buildProfileTab() : _buildMyEventsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'Nick Name',
            child: TextField(
              controller: _nickNameController,
              decoration: _inputDecoration(''),
            ),
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'Pronouns',
            child: TextField(
              controller: _pronounsController,
              decoration: _inputDecoration(''),
            ),
          ),
          const SizedBox(height: 16),
          _FormField(
            label: 'Gender',
            child: TextField(
              controller: _genderController,
              decoration: _inputDecoration(''),
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
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
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
                    const Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCollege ?? '',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
                      ),
                    ),
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
              onPressed: () {
                // TODO: save profile to backend
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B0FA0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Save', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Colors.red, width: 1.5),
              ),
              child: const Text('Log Out', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyEventsTab() {
    return RefreshIndicator(
      onRefresh: _refreshJoined,
      child: FutureBuilder<List<Event>>(
        future: _joinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                Text(
                  'Failed to load events.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF57068C)),
                ),
              ],
            );
          }
          final events = snapshot.data ?? const <Event>[];
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Events',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF57068C),
                  ),
                ),
                const SizedBox(height: 12),
                if (events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "You haven't joined any events yet.",
                      style: TextStyle(color: Color(0xFF7B4FA8), fontSize: 14),
                    ),
                  )
                else
                  ...events.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: _toCardData(e),
                          isMyEvent: true,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: e),
                              ),
                            );
                            if (mounted) await _refreshJoined();
                          },
                        ),
                      )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  EventData _toCardData(Event e) {
    return EventData(
      title: e.title,
      time: _formatTime(e.endTime),
      host: e.hostLabel,
      category: e.category,
      capacity: '${e.capacity}',
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12 $period';
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B0FA0), width: 1.5),
      ),
    );
  }

  BoxDecoration _fieldDecoration() =>
      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12));
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3B0FA0) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF3B0FA0), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF3B0FA0),
          ),
        ),
      ),
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
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
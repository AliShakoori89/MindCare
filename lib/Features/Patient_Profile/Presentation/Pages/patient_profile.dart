import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF4CA30D);
const _backgroundColor = Color(0xFFF8FAF7);

class _PatientProfile {
  const _PatientProfile({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.preferredLanguage,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
  });

  final String firstName;
  final String lastName;
  final String birthDate;
  final String gender;
  final String preferredLanguage;
  final String emergencyContactName;
  final String emergencyContactRelationship;
  final String emergencyContactPhone;

  String get fullName => '$firstName $lastName'.trim();

  _PatientProfile copyWith({
    String? firstName,
    String? lastName,
    String? birthDate,
    String? gender,
    String? preferredLanguage,
    String? emergencyContactName,
    String? emergencyContactRelationship,
    String? emergencyContactPhone,
  }) {
    return _PatientProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      emergencyContactName:
      emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelationship:
      emergencyContactRelationship ?? this.emergencyContactRelationship,
      emergencyContactPhone:
      emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }
}

class _MockPatientProfileStore {
  _MockPatientProfileStore._();

  static final instance = _MockPatientProfileStore._();

  _PatientProfile profile = const _PatientProfile(
    firstName: 'علی',
    lastName: 'شاکوری',
    birthDate: '۱۳۷۵/۰۵/۲۰',
    gender: 'مرد',
    preferredLanguage: 'فارسی',
    emergencyContactName: 'محمد شاکوری',
    emergencyContactRelationship: 'برادر',
    emergencyContactPhone: '09123456789',
  );
}

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  _PatientProfile get _profile =>
      _MockPatientProfileStore.instance.profile;

  Future<void> _editProfile() async {
    final updatedProfile =
    await showModalBottomSheet<_PatientProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => _EditPatientProfileSheet(profile: _profile),
    );

    if (!mounted || updatedProfile == null) return;

    setState(() {
      _MockPatientProfileStore.instance.profile = updatedProfile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اطلاعات پروفایل ذخیره شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        title: const Text(
          'پروفایل من',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'ویرایش پروفایل',
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'اطلاعات شخصی',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildInfoCard([
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'نام و نام خانوادگی',
                value: profile.fullName,
              ),
              _InfoRow(
                icon: Icons.cake_outlined,
                label: 'تاریخ تولد',
                value: profile.birthDate,
              ),
              _InfoRow(
                icon: Icons.wc_outlined,
                label: 'جنسیت',
                value: profile.gender,
              ),
              _InfoRow(
                icon: Icons.language_outlined,
                label: 'زبان ترجیحی',
                value: profile.preferredLanguage,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(
              'تماس اضطراری',
              icon: Icons.contact_emergency_outlined,
            ),
            const SizedBox(height: 12),
            _buildInfoCard([
              _InfoRow(
                icon: Icons.person_outline,
                label: 'نام مخاطب',
                value: profile.emergencyContactName,
              ),
              _InfoRow(
                icon: Icons.people_outline,
                label: 'نسبت',
                value: profile.emergencyContactRelationship,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'شماره تماس',
                value: profile.emergencyContactPhone,
              ),
            ]),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('ویرایش اطلاعات'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'اطلاعات این صفحه فعلاً به‌صورت آزمایشی ذخیره می‌شوند.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(_PatientProfile profile) {
    final initials = [
      profile.firstName,
      profile.lastName,
    ].where((value) => value.isNotEmpty).map((value) => value[0]).join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4CA30D),
            Color(0xFF66C61C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName.isEmpty ? 'نام کاربر' : profile.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'پروفایل سلامت شما',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: _editProfile,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('ویرایش پروفایل'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, {
        required IconData icon,
      }) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index++) ...[
              _buildInfoRow(rows[index]),
              if (index != rows.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(row.icon, color: _primaryColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  row.value.isEmpty ? 'ثبت نشده' : row.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _EditPatientProfileSheet extends StatefulWidget {
  const _EditPatientProfileSheet({required this.profile});

  final _PatientProfile profile;

  @override
  State<_EditPatientProfileSheet> createState() =>
      _EditPatientProfileSheetState();
}

class _EditPatientProfileSheetState
    extends State<_EditPatientProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyRelationshipController;
  late final TextEditingController _emergencyPhoneController;

  late String _gender;
  late String _language;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;
    _firstNameController =
        TextEditingController(text: profile.firstName);
    _lastNameController =
        TextEditingController(text: profile.lastName);
    _birthDateController =
        TextEditingController(text: profile.birthDate);
    _emergencyNameController =
        TextEditingController(text: profile.emergencyContactName);
    _emergencyRelationshipController =
        TextEditingController(text: profile.emergencyContactRelationship);
    _emergencyPhoneController =
        TextEditingController(text: profile.emergencyContactPhone);

    _gender = profile.gender;
    _language = profile.preferredLanguage;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      widget.profile.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        gender: _gender,
        preferredLanguage: _language,
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactRelationship:
        _emergencyRelationshipController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'ویرایش پروفایل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _field(
                controller: _firstNameController,
                label: 'نام',
              ),
              _field(
                controller: _lastNameController,
                label: 'نام خانوادگی',
              ),
              _field(
                controller: _birthDateController,
                label: 'تاریخ تولد',
                hint: 'مثلاً ۱۳۷۵/۰۵/۲۰',
              ),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'جنسیت',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'مرد', child: Text('مرد')),
                  DropdownMenuItem(value: 'زن', child: Text('زن')),
                  DropdownMenuItem(
                    value: 'ترجیح می‌دهم نگویم',
                    child: Text('ترجیح می‌دهم نگویم'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(
                  labelText: 'زبان ترجیحی',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'فارسی',
                    child: Text('فارسی'),
                  ),
                  DropdownMenuItem(
                    value: 'English',
                    child: Text('English'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'اطلاعات تماس اضطراری',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _emergencyNameController,
                label: 'نام مخاطب اضطراری',
                required: false,
              ),
              _field(
                controller: _emergencyRelationshipController,
                label: 'نسبت با شما',
                required: false,
              ),
              _field(
                controller: _emergencyPhoneController,
                label: 'شماره تماس اضطراری',
                required: false,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('ذخیره تغییرات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'لطفاً $label را وارد کن.';
          }
          return null;
        },
      ),
    );
  }
}
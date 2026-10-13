
import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF4CA30D);
const _pageBackground = Color(0xFFF8FAF7);

enum _MedicationFilter { all, active, paused }

class _MedicationMock {
  _MedicationMock({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.note = '',
    this.isActive = true,
  });

  final int id;
  final String name;
  final String dosage;
  final String schedule;
  final String note;
  bool isActive;
}

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final _searchController = TextEditingController();

  _MedicationFilter _filter = _MedicationFilter.all;
  int _nextId = 4;

  final List<_MedicationMock> _medications = [
    _MedicationMock(
      id: 1,
      name: 'ویتامین D',
      dosage: '۱۰۰۰ واحد',
      schedule: 'هر روز، بعد از صبحانه',
      note: 'نمونه نمایشی',
    ),
    _MedicationMock(
      id: 2,
      name: 'منیزیم',
      dosage: '۲۵۰ میلی‌گرم',
      schedule: 'هر شب، بعد از شام',
      note: 'نمونه نمایشی',
    ),
    _MedicationMock(
      id: 3,
      name: 'امگا ۳',
      dosage: '۱۰۰۰ میلی‌گرم',
      schedule: 'هر روز، همراه ناهار',
      note: 'نمونه نمایشی',
      isActive: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MedicationMock> get _filteredMedications {
    final query = _searchController.text.trim().toLowerCase();

    return _medications.where((medication) {
      final matchesSearch =
          medication.name.toLowerCase().contains(query) ||
              medication.dosage.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        _MedicationFilter.all => true,
        _MedicationFilter.active => medication.isActive,
        _MedicationFilter.paused => !medication.isActive,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get _activeCount =>
      _medications.where((medication) => medication.isActive).length;


  Future<void> _showAddMedicationSheet() async {
    final result = await showModalBottomSheet<_MedicationMock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedicationSheet(id: _nextId),
    );

    if (!mounted || result == null) return;

    setState(() {
      _nextId++;
      _medications.insert(0, result);
      _filter = _MedicationFilter.all;
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('داروی نمونه اضافه شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  Future<void> _confirmDelete(_MedicationMock medication) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف دارو'),
        content: Text('داروی «${medication.name}» از فهرست حذف شود؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _medications.removeWhere((item) => item.id == medication.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('دارو از فهرست نمونه حذف شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medications = _filteredMedications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: AppBar(
          backgroundColor: _pageBackground,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'داروهای من',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddMedicationSheet,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('افزودن دارو'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _buildSummary(),
              const SizedBox(height: 22),
              const Text(
                'فهرست داروها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'جست‌وجوی نام یا دوز دارو',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('همه', _MedicationFilter.all),
                  _filterChip('فعال', _MedicationFilter.active),
                  _filterChip('متوقف‌شده', _MedicationFilter.paused),
                ],
              ),
              const SizedBox(height: 16),
              if (medications.isEmpty)
                _buildEmptyState()
              else
                ...medications.map(_buildMedicationCard),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF9A6700),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'این فهرست صرفاً برای نمایش رابط کاربری است. '
                            'برای تغییر دوز یا برنامه مصرف، با پزشک یا داروساز مشورت کن.',
                        style: TextStyle(
                          height: 1.6,
                          color: Color(0xFF725000),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CA30D), Color(0xFF75BE3A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مراقبت منظم از سلامت',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'فهرست داروهایت را یک‌جا ببین.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 18),
                Text(
                  '$_activeCount داروی فعال',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, _MedicationFilter filter) {
    final selected = _filter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = filter),
      selectedColor: _primaryColor.withValues(alpha: 0.15),
      side: BorderSide(
        color: selected ? _primaryColor : Colors.black12,
      ),
      labelStyle: TextStyle(
        color: selected ? _primaryColor : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildMedicationCard(_MedicationMock medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8ECE5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.medication_outlined,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        medication.dosage,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              medication.schedule,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'toggle') {
                      setState(() {
                        medication.isActive = !medication.isActive;
                      });
                    } else if (value == 'delete') {
                      _confirmDelete(medication);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        medication.isActive
                            ? 'توقف موقت'
                            : 'فعال‌کردن',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف از فهرست'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: medication.isActive
                        ? const Color(0xFFEAF6E3)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    medication.isActive ? 'فعال' : 'متوقف‌شده',
                    style: TextStyle(
                      fontSize: 12,
                      color: medication.isActive
                          ? _primaryColor
                          : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (medication.note.isNotEmpty)
                  Text(
                    medication.note,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 48,
            color: Colors.black38,
          ),
          SizedBox(height: 12),
          Text(
            'دارویی پیدا نشد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'عبارت جست‌وجو یا فیلتر را تغییر بده.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}


class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet({required this.id});

  final int id;

  @override
  State<_AddMedicationSheet> createState() =>
      _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? validatorMessage,
    bool requiredField = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (requiredField &&
                (value == null || value.trim().isEmpty)) {
              return validatorMessage;
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _MedicationMock(
        id: widget.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        schedule: _scheduleController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'افزودن داروی جدید',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اطلاعات دارو را وارد کن.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _nameController,
                      label: 'نام دارو',
                      hint: 'مثلاً ویتامین D',
                      validatorMessage: 'نام دارو را وارد کن.',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _dosageController,
                      label: 'دوز مصرف',
                      hint: 'مثلاً ۵۰۰ میلی‌گرم',
                      validatorMessage: 'دوز دارو را وارد کن.',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _scheduleController,
                      label: 'زمان مصرف',
                      hint: 'مثلاً هر روز بعد از صبحانه',
                      validatorMessage: 'زمان مصرف را وارد کن.',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _noteController,
                      label: 'یادداشت (اختیاری)',
                      hint: 'توضیحات تکمیلی',
                      requiredField: false,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('ثبت دارو'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

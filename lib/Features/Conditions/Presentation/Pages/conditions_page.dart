import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF4CA30D);
const _pageBackground = Color(0xFFF8FAF7);

enum _ConditionStatus {
  active,
  controlled,
  recovered,
}

class _ConditionMock {
  _ConditionMock({
    required this.id,
    required this.name,
    required this.status,
    required this.diagnosisDate,
    required this.description,
    this.note = '',
  });

  final int id;
  final String name;
  _ConditionStatus status;
  final String diagnosisDate;
  final String description;
  final String note;
}

class ConditionsPage extends StatefulWidget {
  const ConditionsPage({super.key});

  @override
  State<ConditionsPage> createState() => _ConditionsPageState();
}

class _ConditionsPageState extends State<ConditionsPage> {
  final _searchController = TextEditingController();

  _ConditionStatus? _selectedStatus;
  int _nextId = 4;

  final List<_ConditionMock> _conditions = [
    _ConditionMock(
      id: 1,
      name: 'میگرن',
      status: _ConditionStatus.controlled,
      diagnosisDate: 'فروردین ۱۴۰۴',
      description: 'سردردهای دوره‌ای همراه با حساسیت به نور.',
      note: 'نمونه نمایشی',
    ),
    _ConditionMock(
      id: 2,
      name: 'کمبود ویتامین D',
      status: _ConditionStatus.active,
      diagnosisDate: 'خرداد ۱۴۰۴',
      description: 'سطح پایین ویتامین D در آزمایش خون.',
      note: 'نمونه نمایشی',
    ),
    _ConditionMock(
      id: 3,
      name: 'کم‌خونی',
      status: _ConditionStatus.recovered,
      diagnosisDate: 'بهمن ۱۴۰۳',
      description: 'کمبود آهن که در حال حاضر بهبود یافته است.',
      note: 'نمونه نمایشی',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ConditionMock> get _filteredConditions {
    final query = _searchController.text.trim().toLowerCase();

    return _conditions.where((condition) {
      final matchesSearch =
          condition.name.toLowerCase().contains(query) ||
              condition.description.toLowerCase().contains(query);

      final matchesStatus =
          _selectedStatus == null ||
              condition.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get _activeCount => _conditions
      .where(
        (condition) => condition.status == _ConditionStatus.active,
  )
      .length;

  int get _controlledCount => _conditions
      .where(
        (condition) => condition.status == _ConditionStatus.controlled,
  )
      .length;

  Future<void> _showAddConditionSheet() async {
    final result = await showModalBottomSheet<_ConditionMock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddConditionSheet(id: _nextId),
    );

    if (!mounted || result == null) return;

    setState(() {
      _nextId++;
      _conditions.insert(0, result);
      _selectedStatus = null;
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شرایط پزشکی اضافه شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showEditConditionSheet(
      _ConditionMock condition,
      ) async {
    final result = await showModalBottomSheet<_ConditionMock>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddConditionSheet(
        id: condition.id,
        initialCondition: condition,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      final index = _conditions.indexWhere(
            (item) => item.id == condition.id,
      );

      if (index != -1) {
        _conditions[index] = result;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اطلاعات شرایط پزشکی به‌روزرسانی شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(_ConditionMock condition) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف شرایط پزشکی'),
          content: Text(
            'آیا می‌خواهی «${condition.name}» را حذف کنی؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('انصراف'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _conditions.removeWhere(
            (item) => item.id == condition.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شرایط پزشکی حذف شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conditions = _filteredConditions;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: AppBar(
          backgroundColor: _pageBackground,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'شرایط پزشکی من',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddConditionSheet,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('افزودن'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            children: [
              _buildSummary(),
              const SizedBox(height: 22),
              const Text(
                'شرایط پزشکی',
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
                  hintText: 'جست‌وجوی شرایط پزشکی',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildFilters(),
              const SizedBox(height: 16),
              if (conditions.isEmpty)
                _buildEmptyState()
              else
                ...conditions.map(_buildConditionCard),
              const SizedBox(height: 20),
              _buildInfoCard(),
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
          colors: [
            Color(0xFF4CA30D),
            Color(0xFF75BE3A),
          ],
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
                  'نمای کلی شرایط سلامت',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'شرایط پزشکی‌ات را یک‌جا مدیریت کن.',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _SummaryItem(
                      value: _activeCount.toString(),
                      label: 'فعال',
                    ),
                    const SizedBox(width: 24),
                    _SummaryItem(
                      value: _controlledCount.toString(),
                      label: 'تحت کنترل',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _filterChip(
          label: 'همه',
          status: null,
        ),
        _filterChip(
          label: 'فعال',
          status: _ConditionStatus.active,
        ),
        _filterChip(
          label: 'تحت کنترل',
          status: _ConditionStatus.controlled,
        ),
        _filterChip(
          label: 'بهبود یافته',
          status: _ConditionStatus.recovered,
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required _ConditionStatus? status,
  }) {
    final selected = _selectedStatus == status;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedStatus = status;
        });
      },
      selectedColor: _primaryColor.withValues(
        alpha: 0.15,
      ),
      side: BorderSide(
        color: selected
            ? _primaryColor
            : Colors.black12,
      ),
      labelStyle: TextStyle(
        color: selected
            ? _primaryColor
            : Colors.black87,
        fontWeight: selected
            ? FontWeight.w600
            : FontWeight.normal,
      ),
    );
  }

  Widget _buildConditionCard(
      _ConditionMock condition,
      ) {
    final statusColor = _statusColor(condition.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE8ECE5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.medical_information_outlined,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        condition.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(condition.status),
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditConditionSheet(condition);
                    } else if (value == 'delete') {
                      _confirmDelete(condition);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('ویرایش'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 7),
                const Text(
                  'تاریخ تشخیص:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  condition.diagnosisDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                condition.description,
                style: const TextStyle(
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
            ),
            if (condition.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  condition.note,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(_ConditionStatus status) {
    switch (status) {
      case _ConditionStatus.active:
        return const Color(0xFFC62828);
      case _ConditionStatus.controlled:
        return const Color(0xFFB7791F);
      case _ConditionStatus.recovered:
        return _primaryColor;
    }
  }

  String _statusLabel(_ConditionStatus status) {
    switch (status) {
      case _ConditionStatus.active:
        return 'فعال';
      case _ConditionStatus.controlled:
        return 'تحت کنترل';
      case _ConditionStatus.recovered:
        return 'بهبود یافته';
    }
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
            Icons.medical_information_outlined,
            size: 48,
            color: Colors.black38,
          ),
          SizedBox(height: 12),
          Text(
            'موردی پیدا نشد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'عبارت جست‌وجو یا فیلتر را تغییر بده.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF9A6700),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'اطلاعات این بخش فعلاً نمونه است. '
                  'در نسخه نهایی، اطلاعات شرایط پزشکی '
                  'از پرونده سلامت شما خوانده خواهد شد.',
              style: TextStyle(
                height: 1.6,
                color: Color(0xFF725000),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AddConditionSheet extends StatefulWidget {
  const _AddConditionSheet({
    required this.id,
    this.initialCondition,
  });

  final int id;
  final _ConditionMock? initialCondition;

  @override
  State<_AddConditionSheet> createState() =>
      _AddConditionSheetState();
}

class _AddConditionSheetState
    extends State<_AddConditionSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController =
  TextEditingController();
  final _noteController = TextEditingController();

  _ConditionStatus _status =
      _ConditionStatus.active;

  bool get _isEditing =>
      widget.initialCondition != null;

  @override
  void initState() {
    super.initState();

    final condition = widget.initialCondition;

    if (condition == null) return;

    _nameController.text = condition.name;
    _dateController.text = condition.diagnosisDate;
    _descriptionController.text =
        condition.description;
    _noteController.text = condition.note;
    _status = condition.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      _ConditionMock(
        id: widget.id,
        name: _nameController.text.trim(),
        status: _status,
        diagnosisDate: _dateController.text.trim(),
        description:
        _descriptionController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? validatorMessage,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (requiredField &&
                (value == null ||
                    value.trim().isEmpty)) {
              return validatorMessage;
            }

            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
          MediaQuery.of(context).viewInsets.bottom,
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isEditing
                          ? 'ویرایش شرایط پزشکی'
                          : 'افزودن شرایط پزشکی',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isEditing
                          ? 'اطلاعات را به‌روزرسانی کن.'
                          : 'اطلاعات شرایط پزشکی را وارد کن.',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _nameController,
                      label: 'نام شرایط پزشکی',
                      hint: 'مثلاً میگرن',
                      validatorMessage:
                      'نام شرایط پزشکی را وارد کن.',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _dateController,
                      label: 'تاریخ تشخیص',
                      hint: 'مثلاً فروردین ۱۴۰۴',
                      validatorMessage:
                      'تاریخ تشخیص را وارد کن.',
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'وضعیت',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<
                        _ConditionStatus>(
                      initialValue: _status,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _pageBackground,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: _ConditionStatus.active,
                          child: Text('فعال'),
                        ),
                        DropdownMenuItem(
                          value:
                          _ConditionStatus.controlled,
                          child: Text('تحت کنترل'),
                        ),
                        DropdownMenuItem(
                          value:
                          _ConditionStatus.recovered,
                          child: Text('بهبود یافته'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _status = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller:
                      _descriptionController,
                      label: 'توضیحات',
                      hint:
                      'توضیح کوتاهی درباره شرایط پزشکی',
                      validatorMessage:
                      'توضیحات را وارد کن.',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _noteController,
                      label: 'یادداشت',
                      hint: 'توضیحات تکمیلی (اختیاری)',
                      requiredField: false,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                          _primaryColor,
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          _isEditing
                              ? 'ذخیره تغییرات'
                              : 'ثبت شرایط پزشکی',
                        ),
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
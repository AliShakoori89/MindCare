import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF4CA30D);
const _backgroundColor = Color(0xFFF8FAF7);

class _MedicalDocument {
  const _MedicalDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.fileName,
    required this.description,
  });

  final int id;
  final String title;
  final String type;
  final DateTime date;
  final String fileName;
  final String description;
}

class MedicalDocumentsPage extends StatefulWidget {
  const MedicalDocumentsPage({super.key});

  @override
  State<MedicalDocumentsPage> createState() =>
      _MedicalDocumentsPageState();
}

class _MedicalDocumentsPageState extends State<MedicalDocumentsPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedFilter = 'همه';

  final List<String> _filters = const [
    'همه',
    'آزمایش',
    'نسخه',
    'تصویربرداری',
    'سایر',
  ];

  final List<_MedicalDocument> _documents = [
    _MedicalDocument(
      id: 1,
      title: 'آزمایش خون',
      type: 'آزمایش',
      date: DateTime(2026, 9, 20),
      fileName: 'blood_test.pdf',
      description: 'نتایج آزمایش خون دوره‌ای',
    ),
    _MedicalDocument(
      id: 2,
      title: 'نسخه پزشک',
      type: 'نسخه',
      date: DateTime(2026, 9, 15),
      fileName: 'prescription.jpg',
      description: 'نسخه مربوط به آخرین مراجعه پزشکی',
    ),
    _MedicalDocument(
      id: 3,
      title: 'تصویر رادیولوژی',
      type: 'تصویربرداری',
      date: DateTime(2026, 8, 28),
      fileName: 'radiology.png',
      description: 'تصاویر مربوط به بررسی پزشکی',
    ),
    _MedicalDocument(
      id: 4,
      title: 'آزمایش ویتامین D',
      type: 'آزمایش',
      date: DateTime(2026, 8, 10),
      fileName: 'vitamin_d.pdf',
      description: 'بررسی سطح ویتامین D',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MedicalDocument> get _filteredDocuments {
    final query = _searchController.text.trim().toLowerCase();

    return _documents.where((document) {
      final matchesQuery =
          document.title.toLowerCase().contains(query) ||
              document.type.toLowerCase().contains(query) ||
              document.fileName.toLowerCase().contains(query);

      final matchesFilter = _selectedFilter == 'همه' ||
          document.type == _selectedFilter;

      return matchesQuery && matchesFilter;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _addDocument() async {
    final document =
    await showModalBottomSheet<_MedicalDocument>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => const _AddMedicalDocumentSheet(),
    );

    if (!mounted || document == null) return;

    setState(() {
      _documents.add(document);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('مدرک پزشکی اضافه شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteDocument(
      _MedicalDocument document,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف مدرک'),
        content: Text(
          'آیا از حذف «${document.title}» مطمئن هستی؟',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () =>
                Navigator.of(dialogContext).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _documents.removeWhere((item) => item.id == document.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('مدرک حذف شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDetails(_MedicalDocument document) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  _DocumentIcon(type: document.type, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: 'نوع مدرک',
                value: document.type,
              ),
              _DetailRow(
                label: 'تاریخ ثبت',
                value: _formatDate(document.date),
              ),
              _DetailRow(
                label: 'نام فایل',
                value: document.fileName.isEmpty
                    ? 'بدون فایل'
                    : document.fileName,
              ),
              const SizedBox(height: 12),
              const Text(
                'توضیحات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                document.description.isEmpty
                    ? 'توضیحی ثبت نشده است.'
                    : document.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'این نسخه فعلاً نمایشی است و فایل واقعی '
                      'بارگذاری یا باز نمی‌شود.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = _filteredDocuments;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text(
          'مدارک پزشکی',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDocument,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('افزودن مدرک'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummary(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'جست‌وجو در مدارک پزشکی...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) =>
                const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final selected = filter == _selectedFilter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: _primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: documents.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  100,
                ),
                itemCount: documents.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final document = documents[index];

                  return _DocumentCard(
                    document: document,
                    onTap: () => _showDetails(document),
                    onDelete: () =>
                        _deleteDocument(document),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final total = _documents.length;
    final labCount = _documents
        .where((item) => item.type == 'آزمایش')
        .length;
    final prescriptionCount = _documents
        .where((item) => item.type == 'نسخه')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4CA30D),
              Color(0xFF66C61C),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'بایگانی سلامت من',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'مدارک پزشکی‌ات را در یک جا نگه دار.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _SummaryItem(
                  value: '$total',
                  label: 'کل مدارک',
                ),
                const SizedBox(width: 28),
                _SummaryItem(
                  value: '$labCount',
                  label: 'آزمایش‌ها',
                ),
                const SizedBox(width: 28),
                _SummaryItem(
                  value: '$prescriptionCount',
                  label: 'نسخه‌ها',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'مدرکی پیدا نشد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عبارت جست‌وجو یا فیلتر را تغییر بده.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  final _MedicalDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _DocumentIcon(type: document.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      document.description.isEmpty
                          ? document.type
                          : document.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(document.date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryColor.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            document.type,
                            style: const TextStyle(
                              color: _primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('حذف مدرک'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon({
    required this.type,
    this.size = 54,
  });

  final String type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    switch (type) {
      case 'آزمایش':
        icon = Icons.science_outlined;
        color = const Color(0xFF2476C7);
      case 'نسخه':
        icon = Icons.medication_outlined;
        color = _primaryColor;
      case 'تصویربرداری':
        icon = Icons.image_outlined;
        color = const Color(0xFF8E62C7);
      default:
        icon = Icons.description_outlined;
        color = const Color(0xFFCC8A26);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMedicalDocumentSheet extends StatefulWidget {
  const _AddMedicalDocumentSheet();

  @override
  State<_AddMedicalDocumentSheet> createState() =>
      _AddMedicalDocumentSheetState();
}

class _AddMedicalDocumentSheetState
    extends State<_AddMedicalDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'آزمایش';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _date = selectedDate;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final document = _MedicalDocument(
      id: DateTime.now().microsecondsSinceEpoch,
      title: _titleController.text.trim(),
      type: _type,
      date: _date,
      fileName: _fileNameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(document);
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'افزودن مدرک پزشکی',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان مدرک',
                  hintText: 'مثلاً آزمایش خون',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'عنوان مدرک را وارد کن.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'نوع مدرک',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'آزمایش',
                    child: Text('آزمایش'),
                  ),
                  DropdownMenuItem(
                    value: 'نسخه',
                    child: Text('نسخه'),
                  ),
                  DropdownMenuItem(
                    value: 'تصویربرداری',
                    child: Text('تصویربرداری'),
                  ),
                  DropdownMenuItem(
                    value: 'سایر',
                    child: Text('سایر'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاریخ مدرک',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(_formatDate(_date)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'نام فایل (اختیاری)',
                  hintText: 'مثلاً blood_test.pdf',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_file),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'توضیحات (اختیاری)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'در این مرحله فقط اطلاعات مدرک ثبت می‌شود؛ '
                      'انتخاب و بارگذاری فایل را بعداً اضافه می‌کنیم.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.7,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('ثبت مدرک'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
import 'package:flutter/material.dart';
import 'package:mind_care/Features/Conditions/Presentation/Pages/conditions_page.dart';
import 'package:mind_care/Features/Documents/Presentation/Pages/medical_documents_page.dart';
import 'package:mind_care/Features/Medications/Presentation/Pages/medications_page.dart';

class MyHealthPage extends StatelessWidget {
  const MyHealthPage({super.key});

  static const Color _primaryColor = Color(0xFF4CA30D);
  static const Color _backgroundColor = Color(0xFFF8FAF7);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _backgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'سلامت من',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'اطلاعات سلامتت را در یک مکان مدیریت کن.',
            style: TextStyle(color: Colors.black54, height: 1.8),
          ),
          const SizedBox(height: 24),

          // Health overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CA30D), Color(0xFF75BB39)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 16),
                Text(
                  'پرونده سلامت تو',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اطلاعاتت را به‌روز نگه دار تا مرور سوابق '
                  'سلامتت آسان‌تر شود.',
                  style: TextStyle(color: Colors.white, height: 1.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const _SectionTitle(title: 'اطلاعات سلامت'),
          const SizedBox(height: 14),

          _HealthMenuCard(
            icon: Icons.medication_outlined,
            title: 'داروهای من',
            subtitle: 'مشاهده و مدیریت داروها',
            color: _primaryColor,
            onTap: () => _openPage(context, const MedicationsPage()),
          ),
          _HealthMenuCard(
            icon: Icons.medical_information_outlined,
            title: 'شرایط پزشکی',
            subtitle: 'بیماری‌ها و شرایط ثبت‌شده',
            color: const Color(0xFFE05A5A),
            onTap: () => _openPage(context, const ConditionsPage()),
          ),
          _HealthMenuCard(
            icon: Icons.description_outlined,
            title: 'مدارک پزشکی',
            subtitle: 'مدیریت مدارک و پرونده‌ها',
            color: const Color(0xFF2588D8),
            onTap: () => _openPage(context, const MedicalDocumentsPage()),
          ),

          const SizedBox(height: 28),
          const _SectionTitle(title: 'یادآوری مهم'),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _primaryColor, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اطلاعات این نسخه ممکن است نمونه باشد. '
                    'برای تصمیم‌های درمانی به اطلاعات تأییدشده '
                    'و نظر متخصص سلامت تکیه کن.',
                    style: TextStyle(color: Colors.black54, height: 1.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _HealthMenuCard extends StatelessWidget {
  const _HealthMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE9EDE6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 27),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

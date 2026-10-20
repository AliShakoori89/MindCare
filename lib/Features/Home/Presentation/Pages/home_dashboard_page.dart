import 'package:flutter/material.dart';

import '../../../Ai_Assistant/Presentation/Pages/ai_assistant.dart';
import '../../../Conditions/Presentation/Pages/conditions_page.dart';
import '../../../Daily_Checkin/Presentation/Mock/mock_daily_check_in_store.dart';
import '../../../Daily_Checkin/Presentation/Pages/daily_check_in_page.dart';
import '../../../Documents/Presentation/Pages/medical_documents_page.dart';
import '../../../Insights/Presentation/Pages/health_insights_page.dart';
import '../../../Journal/Presentation/Pages/journal_page.dart';
import '../../../Medications/Presentation/Pages/medications_page.dart';
import '../../../Patient_Profile/Presentation/Pages/patient_profile.dart';
import '../../../My_Health/Presentation/Pages/my_health_page.dart';
import 'Component/chang_date_format.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  int _selectedIndex = 0;

  static const Color _backgroundColor = Color(0xFFF8FAF7);
  static const Color _primaryColor = Color(0xFF4CA30D);

  Future<void> _openDailyCheckIn() async {
    final existingCheckIn = MockDailyCheckInStore.instance.today;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DailyCheckInPage(existingCheckIn: existingCheckIn),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      const HealthInsightsPage(),
      const AiAssistantPage(),
      const MyHealthPage(),
      const PatientProfilePage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: _primaryColor.withValues(alpha: 0.2),
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'خانه',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'روند سلامت',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy),
              label: 'دستیار',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'سلامت من',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    final todayCheckIn = MockDailyCheckInStore.instance.today;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سلام، روزت آرام 👋',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 5,
                        bottom: 5,
                      ),
                      child: Text(getTodayPersianDate()),
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: _primaryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.favorite, color: _primaryColor, size: 27),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Daily check-in
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MockDailyCheckInStore.instance.hasTodayCheckIn
                              ? 'ویرایش حال امروز'
                              : 'ارزیابی روزانه',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          MockDailyCheckInStore.instance.hasTodayCheckIn
                              ? ''
                              : 'چند ثانیه برای خودت وقت بذار',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                MockDailyCheckInStore.instance.hasTodayCheckIn
                    ? 'حال امروزت ثبت شده؛ اگر لازم است آن را تغییر بده.'
                    : 'احساس و سطح انرژی امروزت رو ثبت کن تا الگوی آرامش، تاب آوری و خواب عمیقت با دقت شکل بگیره',
                style: TextStyle(color: Colors.white, height: 1.7),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _openDailyCheckIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primaryColor,
                  ),
                  child: Text(
                    MockDailyCheckInStore.instance.hasTodayCheckIn
                        ? 'بروز زسانی حال روزانه.'
                        : 'شروع ثبت روزانه',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        _sectionTitle('نمای کلی امروز'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.mood_outlined,
                title: 'حال امروز',
                value: todayCheckIn?.moodLabel ?? 'ثبت نشده',
                color: const Color(0xFF7C5CE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.medication_outlined,
                title: 'داروها',
                value: '۲ داروی نمونه',
                color: _primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        _sectionTitle('دسترسی سریع'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _QuickActionCard(
              icon: Icons.menu_book_outlined,
              title: 'دفترچه یادداشت',
              subtitle: 'ثبت احساسات و افکار',
              color: const Color(0xFF7C5CE7),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => JournalPage(userId: '10'),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.medication_outlined,
              title: 'داروهای من',
              subtitle: 'مدیریت داروها',
              color: _primaryColor,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MedicationsPage(),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.medical_information_outlined,
              title: 'شرایط پزشکی',
              subtitle: 'بیماری‌ها و شرایط',
              color: const Color(0xFFE05A5A),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConditionsPage(),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.description_outlined,
              title: 'مدارک پزشکی',
              subtitle: 'پرونده‌های سلامت',
              color: const Color(0xFF2588D8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MedicalDocumentsPage(),
                  ),
                );
              },
            ),
            _QuickActionCard(
              icon: Icons.auto_awesome_outlined,
              title: 'دستیار هوشمند',
              subtitle: 'گفت‌وگو درباره سلامت',
              color: const Color(0xFFDB8B24),
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تأمل روزانه'),
              _sectionTitle('پذیرش آرام آنچه در جریان است'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                margin: EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '«آرامش به این معنا نیست که طوفانی در کار نباشد، بلکه به این معناست که در دل طوفان، لنگرگاهی استوار در درون خود داشته باشی.»',
                    style: TextStyle(color: Colors.black54, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

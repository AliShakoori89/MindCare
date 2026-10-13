
import 'package:flutter/material.dart';
import '../../../Daily_Checkin/Presentation/Mock/mock_daily_check_in_store.dart';
import '../../../Daily_Checkin/Presentation/Pages/daily_check_in_page.dart';
import '../../../Medications/Presentation/Pages/medications_page.dart';

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
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const DailyCheckInPage(),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }


  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature به‌زودی در دسترس خواهد بود.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      const _SectionPage(
        title: 'روند سلامت',
        subtitle: 'تغییرات سلامتت را در طول زمان دنبال کن.',
        icon: Icons.insights_outlined,
        items: ['گزارش هفتگی', 'تاریخچه حال روزانه', 'خلاصه ماهانه'],
      ),
      const _SectionPage(
        title: 'دستیار هوشمند',
        subtitle: 'برای درک بهتر اطلاعات سلامتت آماده‌ای؟',
        icon: Icons.smart_toy_outlined,
        items: ['گفت‌وگو درباره سلامت', 'سؤالات متداول', 'گفت‌وگوهای اخیر'],
      ),
      const _SectionPage(
        title: 'سلامت من',
        subtitle: 'اطلاعات سلامتت را یک‌جا مدیریت کن.',
        icon: Icons.health_and_safety_outlined,
        items: ['شرایط پزشکی', 'داروهای من', 'مدارک پزشکی'],
      ),
      const _SectionPage(
        title: 'پروفایل من',
        subtitle: 'اطلاعات شخصی و ترجیحاتت را مدیریت کن.',
        icon: Icons.person_outline,
        items: ['اطلاعات شخصی', 'اطلاعات تماس اضطراری', 'تنظیمات'],
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: _primaryColor.withValues(alpha: 0.13),
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
    final latestCheckIn = MockDailyCheckInStore.instance.latest;
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
                    'سلام، خوش اومدی 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'امروز چطوری؟',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: _primaryColor.withValues(alpha: 0.12),
              child: const Icon(
                Icons.favorite,
                color: _primaryColor,
                size: 27,
              ),
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
              const Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'حال امروزت رو ثبت کن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'چند دقیقه برای خودت وقت بذار و حال امروزت رو ثبت کن.',
                style: TextStyle(
                  color: Colors.white,
                  height: 1.7,
                ),
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
                  child: const Text('شروع ثبت روزانه'),
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
                value: latestCheckIn?.moodLabel ?? 'ثبت نشده',
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
              onTap: () => _showComingSoon('دفترچه یادداشت'),
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
              icon: Icons.description_outlined,
              title: 'مدارک پزشکی',
              subtitle: 'پرونده‌های سلامت',
              color: const Color(0xFF2588D8),
              onTap: () => setState(() => _selectedIndex = 3),
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

        _sectionTitle('یادآوری برای خودت'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: const Row(
            children: [
              Icon(Icons.spa_outlined, color: _primaryColor, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مراقبت از خودت رو فراموش نکن',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'استراحت کوتاه هم می‌تونه بخشی از مراقبت روزانه باشه.',
                      style: TextStyle(color: Colors.black54, height: 1.6),
                    ),
                  ],
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Icon(icon, size: 54, color: const Color(0xFF4CA30D)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, height: 1.7),
        ),
        const SizedBox(height: 28),
        ...items.map(
              (item) => Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF5E2),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF4CA30D),
                  size: 17,
                ),
              ),
              title: Text(item),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$item به‌زودی در دسترس خواهد بود.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class HealthInsightsPage extends StatelessWidget {
  const HealthInsightsPage({super.key});

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
            'روند سلامت',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'نگاهی به تغییرات سلامت و حال روحی‌ات در طول زمان.',
            style: TextStyle(color: Colors.black54, height: 1.8),
          ),
          const SizedBox(height: 24),

          // Weekly summary
          const _SectionTitle(title: 'خلاصه این هفته'),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.mood_outlined,
                  title: 'میانگین حال روحی',
                  value: '۴ از ۵',
                  subtitle: 'خوب',
                  color: Color(0xFF7C5CE7),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'ثبت روزانه',
                  value: '۵ از ۷',
                  subtitle: 'روز ثبت‌شده',
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Mood chart
          const _SectionTitle(title: 'تغییرات حال روحی'),
          const SizedBox(height: 8),
          const Text(
            'وضعیت ثبت‌شده در هفت روز اخیر',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const _WeeklyMoodCard(),
          const SizedBox(height: 28),

          // Health overview
          const _SectionTitle(title: 'خلاصه اطلاعات سلامت'),
          const SizedBox(height: 14),
          const _HealthInfoTile(
            icon: Icons.medication_outlined,
            title: 'داروهای من',
            subtitle: '۲ داروی نمونه',
            color: _primaryColor,
          ),
          const SizedBox(height: 10),
          const _HealthInfoTile(
            icon: Icons.medical_information_outlined,
            title: 'شرایط پزشکی',
            subtitle: '۲ مورد نمونه ثبت‌شده',
            color: Color(0xFFE05A5A),
          ),
          const SizedBox(height: 10),
          const _HealthInfoTile(
            icon: Icons.description_outlined,
            title: 'مدارک پزشکی',
            subtitle: '۳ مدرک نمونه',
            color: Color(0xFF2588D8),
          ),
          const SizedBox(height: 28),

          // Recent activity
          const _SectionTitle(title: 'فعالیت‌های اخیر'),
          const SizedBox(height: 14),
          const _ActivityTile(
            icon: Icons.mood_outlined,
            title: 'ثبت حال روزانه',
            subtitle: 'امروز · اطلاعات نمونه',
            color: Color(0xFF7C5CE7),
          ),
          const _ActivityTile(
            icon: Icons.medication_outlined,
            title: 'بررسی داروها',
            subtitle: 'دیروز · اطلاعات نمونه',
            color: _primaryColor,
          ),
          const _ActivityTile(
            icon: Icons.edit_note_outlined,
            title: 'یادداشت سلامت',
            subtitle: '۲ روز پیش · اطلاعات نمونه',
            color: Color(0xFF2588D8),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: _primaryColor),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'این اطلاعات فعلاً نمایشی هستند و برای طراحی رابط کاربری استفاده می‌شوند.',
                    style: TextStyle(color: Color(0xFF376B18), height: 1.7),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
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
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyMoodCard extends StatelessWidget {
  const _WeeklyMoodCard();

  static const List<_MoodDay> _days = [
    _MoodDay(label: 'ش', score: 3),
    _MoodDay(label: 'ی', score: 4),
    _MoodDay(label: 'د', score: 5),
    _MoodDay(label: 'س', score: 3),
    _MoodDay(label: 'چ', score: 4),
    _MoodDay(label: 'پ', score: 5),
    _MoodDay(label: 'ج', score: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: HealthInsightsPage._primaryColor),
              SizedBox(width: 8),
              Text(
                'امتیاز حال روحی',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text('از ۵', style: TextStyle(color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 126,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _days.map((day) {
                return Expanded(child: _MoodBar(day: day));
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'امتیاز صفر یعنی اطلاعاتی برای آن روز ثبت نشده است.',
            style: TextStyle(color: Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MoodDay {
  const _MoodDay({required this.label, required this.score});

  final String label;
  final int score;
}

class _MoodBar extends StatelessWidget {
  const _MoodBar({required this.day});

  final _MoodDay day;

  @override
  Widget build(BuildContext context) {
    final hasData = day.score > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          hasData ? '${day.score}' : '—',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: hasData ? day.score * 15.0 : 5,
          decoration: BoxDecoration(
            color: hasData ? const Color(0xFF4CA30D) : Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day.label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }
}

class _HealthInfoTile extends StatelessWidget {
  const _HealthInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}

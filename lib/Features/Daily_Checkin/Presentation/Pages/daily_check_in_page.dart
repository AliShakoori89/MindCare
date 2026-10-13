
import 'package:flutter/material.dart';

import '../Mock/mock_daily_check_in_store.dart';

class DailyCheckInPage extends StatefulWidget {
  const DailyCheckInPage({super.key});

  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  static const Color primaryColor = Color(0xFF4CA30D);

  int? _mood;
  int _energy = 3;
  int _stress = 2;
  int _sleepQuality = 3;
  double _sleepDuration = 8;
  final TextEditingController _noteController = TextEditingController();

  final List<_MoodOption> _moods = const [
    _MoodOption(1, 'خیلی بد', '😞'),
    _MoodOption(2, 'بد', '😕'),
    _MoodOption(3, 'معمولی', '😐'),
    _MoodOption(4, 'خوب', '🙂'),
    _MoodOption(5, 'عالی', '😄'),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }


  void _saveCheckIn() {
    if (_mood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً حال امروزت رو انتخاب کن.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    MockDailyCheckInStore.instance.save(
      MockDailyCheckIn(
        mood: _mood!,
        energy: _energy,
        stress: _stress,
        sleepQuality: _sleepQuality,
        sleepDuration: _sleepDuration,
        note: _noteController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('حال امروزت ثبت شد.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(true);
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF7),
        appBar: AppBar(
          title: const Text('ثبت حال روزانه'),
          backgroundColor: const Color(0xFFF8FAF7),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5E2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      color: primaryColor,
                      size: 34,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'چند دقیقه برای خودت وقت بذار',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'جواب درست یا غلطی وجود نداره. فقط حال واقعی امروزت رو ثبت کن.',
                      style: TextStyle(height: 1.8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _sectionTitle('۱. امروز چه احساسی داری؟'),
              const SizedBox(height: 14),
              Row(
                children: _moods.map((mood) {
                  final selected = _mood == mood.value;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() => _mood = mood.value);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFEAF5E2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? primaryColor
                                  : Colors.black12,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 25),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              _sectionTitle('۲. سطح انرژی امروزت چطوره؟'),
              const SizedBox(height: 8),
              _ratingCard(
                value: _energy,
                labels: const ['خیلی کم', 'کم', 'متوسط', 'زیاد', 'عالی'],
                onChanged: (value) => setState(() => _energy = value),
              ),
              const SizedBox(height: 24),

              _sectionTitle('۳. میزان استرست چقدره؟'),
              const SizedBox(height: 8),
              _ratingCard(
                value: _stress,
                labels: const ['خیلی کم', 'کم', 'متوسط', 'زیاد', 'خیلی زیاد'],
                onChanged: (value) => setState(() => _stress = value),
              ),
              const SizedBox(height: 24),

              _sectionTitle('۴. دیشب چقدر خوب خوابیدی؟'),
              const SizedBox(height: 8),
              _ratingCard(
                value: _sleepQuality,
                labels: const ['خیلی بد', 'بد', 'متوسط', 'خوب', 'عالی'],
                onChanged: (value) {
                  setState(() => _sleepQuality = value);
                },
              ),
              const SizedBox(height: 24),

              _sectionTitle('۵. چند ساعت خوابیدی؟'),
              const SizedBox(height: 8),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.bedtime_outlined,
                            color: primaryColor,
                          ),
                          Text(
                            '${_sleepDuration.toStringAsFixed(1)} ساعت',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _sleepDuration,
                        min: 0,
                        max: 14,
                        divisions: 28,
                        activeColor: primaryColor,
                        label: '${_sleepDuration.toStringAsFixed(1)} ساعت',
                        onChanged: (value) {
                          setState(() => _sleepDuration = value);
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('۰ ساعت'),
                          Text('۱۴ ساعت'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _sectionTitle('۶. چیزی هست که بخوای یادداشت کنی؟'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'امروز چه چیزی روی حالت تأثیر گذاشت؟',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saveCheckIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'ثبت حال امروز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'اطلاعات این نسخه آزمایشی هنوز ذخیره دائمی نمی‌شوند.',
                textAlign: TextAlign.center,
                style: TextStyle(
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _ratingCard({
    required int value,
    required List<String> labels,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: List.generate(5, (index) {
            final number = index + 1;
            final selected = value == number;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(number),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? primaryColor
                              : const Color(0xFFF0F2ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? primaryColor : Colors.black54,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.value, this.label, this.emoji);

  final int value;
  final String label;
  final String emoji;
}

import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

String getTodayPersianDate() {
  final now = DateTime.now();
  final jalali = Jalali.fromDateTime(now);

  const weekDays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

  const months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  final weekDay = weekDays[jalali.weekDay % 7];
  final month = months[jalali.month - 1];

  return '$weekDay ${jalali.day.toString().toPersianDigit()} $month';
}
//برای مدارک پزشکی.
// مثلاً:
// Documents
//
// Blood Test
// MRI
// Prescription
// Doctor Report
// Medical Image
//
// UI:
// Documents
//        ↓
// [ + Upload ]
//
// Blood Test
// Oct 5, 2026
//
// MRI
// Sep 20, 2026
//
// و Detail:
// Document
// ────────────
//
// Blood Test
//
// Date:
// 2026/10/05
//
// [View]
// [Download]
// [Delete]
//
// نکته مهم
// برای UI فعلاً حتی لازم نیست واقعاً فایل upload کنیم.
// Mock:
// MockMedicalDocument(
//   title: 'Blood Test',
//   type: 'Lab Result',
//   date: ...,
// )
//
// بعداً File Picker + API/Storage اضافه می‌کنیم.
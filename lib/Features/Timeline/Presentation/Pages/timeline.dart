//Timeline به نظرم باید بعد از چند Feature دیگر ساخته شود.
// چون Timeline در واقع وقایع مختلف سلامت کاربر را کنار هم قرار می‌دهد.
// مثلاً:
// October 7
//
// 📝 Journal
// "Today I felt better."
//
// 💊 Medication
// Metformin added
//
// 😊 Check-in
// Mood: 4/5
//
// October 5
//
// 📄 Document
// Blood Test uploaded
//
// September 20
//
// 🏥 Condition
// Migraine updated
//
// یعنی:
// Journal
//    \
// Medication ----\
// Check-in ------- > Timeline
// Documents ------/
// Conditions -----/
//
// پس Timeline بیشتر Aggregator است تا یک Feature مستقل داده‌ای.
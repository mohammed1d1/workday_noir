String dateKey(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
DateTime todayLocal() { final n = DateTime.now(); return DateTime(n.year,n.month,n.day); }
String monthKey(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}';
bool isFutureDateKey(String key) => key.compareTo(dateKey(todayLocal())) > 0;

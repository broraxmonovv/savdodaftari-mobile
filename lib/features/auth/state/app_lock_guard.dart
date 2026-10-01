/// Ilova qulfi (PIN) uchun himoya: kamera, galereya, "ulashish" yoki to'lov sahifasi kabi tashqi ilova
/// ochilganda Flutter ilovasi `paused` holatiga o'tadi. Bu holatda PIN so'ralmasligi kerak.
///
/// - [run] — tashqi ekran ochiq turgan butun vaqt (rasm tanlash, ulashish) qulfni to'xtatadi.
/// - [suspendFor] — natijasini kutib bo'lmaydigan tashqi ilovalar uchun (brauzer, to'lov, telefon).
/// - Qolgan hollarda ilova [graceSeconds] soniyadan uzoq fonda turgandagina PIN so'raladi.
abstract final class AppLockGuard {
  /// Fonda shuncha soniyadan oshsa, qaytganda PIN so'raladi.
  static const int graceSeconds = 30;

  static int _depth = 0;
  static DateTime? _until;

  /// Hozir (yoki yaqinda) tashqi ekran ochilganmi — qulf qo'llanmaydi.
  static bool get suspended =>
      _depth > 0 || (_until != null && DateTime.now().isBefore(_until!));

  /// [action] davomida qulf to'xtatiladi; tugagach yana 10 soniya himoya (lifecycle kechiksa).
  static Future<T> run<T>(Future<T> Function() action) async {
    _depth++;
    try {
      return await action();
    } finally {
      _depth--;
      _extend(const Duration(seconds: 10));
    }
  }

  /// Tashqi ilovaga o'tishdan oldin chaqiriladi (masalan, to'lov sahifasi).
  static void suspendFor(Duration duration) => _extend(duration);

  static void _extend(Duration duration) {
    final DateTime until = DateTime.now().add(duration);
    if (_until == null || until.isAfter(_until!)) {
      _until = until;
    }
  }

  /// Faqat testlar uchun.
  static void reset() {
    _depth = 0;
    _until = null;
  }
}

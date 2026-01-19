import 'package:shared_preferences/shared_preferences.dart';

class TimeClock {
  DateTime? clockInTime;
  DateTime? clockOutTime;

  TimeClock({this.clockInTime, this.clockOutTime});

  Map<String, dynamic> toMap() {
    return {
      'clockInTime': clockInTime?.toIso8601String(),
      'clockOutTime': clockOutTime?.toIso8601String(),
    };
  }

  factory TimeClock.fromMap(Map<String, dynamic> map) {
    return TimeClock(
      clockInTime: map['clockInTime'] != null
          ? DateTime.parse(map['clockInTime'])
          : null,
      clockOutTime: map['clockOutTime'] != null
          ? DateTime.parse(map['clockOutTime'])
          : null,
    );
  }

  Duration? getWorkedDuration() {
    if (clockInTime != null && clockOutTime != null) {
      return clockOutTime!.difference(clockInTime!);
    }
    return null;
  }
}

class TimeClockService {
  static final TimeClockService _instance = TimeClockService._internal();

  factory TimeClockService() {
    return _instance;
  }

  TimeClockService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> clockIn() async {
    final today = DateTime.now();
    final key = _getKey(today);
    
    final timeClock = TimeClock(clockInTime: DateTime.now());
    await _prefs.setString(key, _serializeTimeClock(timeClock));
  }

  Future<void> clockOut() async {
    final today = DateTime.now();
    final key = _getKey(today);
    
    final existing = _prefs.getString(key);
    if (existing != null) {
      final parts = existing.split('|');
      final timeClock = TimeClock(
        clockInTime: parts[0].isNotEmpty ? DateTime.parse(parts[0]) : null,
        clockOutTime: DateTime.now(),
      );
      await _prefs.setString(key, _serializeTimeClock(timeClock));
    }
  }

  Future<TimeClock?> getTodaysRecord() async {
    final key = _getKey(DateTime.now());
    final existing = _prefs.getString(key);
    
    if (existing == null) return null;
    
    final parts = existing.split('|');
    return TimeClock(
      clockInTime: parts[0].isNotEmpty ? DateTime.parse(parts[0]) : null,
      clockOutTime: parts.length > 1 && parts[1].isNotEmpty
          ? DateTime.parse(parts[1])
          : null,
    );
  }

  Future<List<TimeClock>> getMonthlyRecords(DateTime month) async {
    final List<TimeClock> records = [];
    
    for (int i = 1; i <= 31; i++) {
      try {
        final date = DateTime(month.year, month.month, i);
        final key = _getKey(date);
        final existing = _prefs.getString(key);
        
        if (existing != null) {
          final parts = existing.split('|');
          records.add(TimeClock(
            clockInTime:
                parts[0].isNotEmpty ? DateTime.parse(parts[0]) : null,
            clockOutTime: parts.length > 1 && parts[1].isNotEmpty
                ? DateTime.parse(parts[1])
                : null,
          ));
        }
      } catch (e) {
        continue;
      }
    }
    
    return records;
  }

  String _getKey(DateTime date) {
    return 'timeclock_${date.year}_${date.month}_${date.day}';
  }

  String _serializeTimeClock(TimeClock timeClock) {
    return '${timeClock.clockInTime?.toIso8601String() ?? ''}|${timeClock.clockOutTime?.toIso8601String() ?? ''}';
  }
}

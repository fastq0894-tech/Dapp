import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications with error handling
  try {
    final notificationService = NotificationService();
    await notificationService.initNotifications();
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString('theme_mode');

    setState(() {
      if (storedMode != null) {
        switch (storedMode) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
      }
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    final prefs = await SharedPreferences.getInstance();
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString('theme_mode', modeString);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D Shift',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ShiftCalendarScreen(),
      SettingsScreen(
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      const VacationScreen(),
      const RecordsScreen(),
      const InfoScreen(),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Vacation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}

class ShiftCalendarScreen extends StatefulWidget {
  const ShiftCalendarScreen({super.key});

  @override
  State<ShiftCalendarScreen> createState() => _ShiftCalendarScreenState();
}

class _ShiftCalendarScreenState extends State<ShiftCalendarScreen> {
  String selectedShift = 'A';
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  final Map<String, int> shiftOffsets = {
    'A': 2,
    'B': 3,
    'C': 4,
    'D': 0,
    'F': 1,
  };

  late SharedPreferences _prefs;
  bool _isLoaded = false;
  Map<String, Color> shiftColors = {
    'morning': Colors.blue,
    'evening': Colors.orange,
    'night': Colors.black,
    'off': Colors.white,
  };
  
  // Shift pattern: list of duty types for each day in cycle
  // 0 = morning, 1 = evening, 2 = night, 3 = off
  List<int> shiftPattern = [0, 1, 2, 3, 3]; // Default 5-day pattern
  
  // Custom shift hours
  Map<String, String> shiftHours = {
    'morning_start': '7:00 AM',
    'morning_end': '3:00 PM',
    'evening_start': '3:00 PM',
    'evening_end': '11:00 PM',
    'night_start': '11:00 PM',
    'night_end': '7:00 AM',
  };
  
  // Cycle start date (the date that is Day 1 of the cycle)
  DateTime cycleStartDate = DateTime(2026, 2, 1);

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoaded) {
      Future.microtask(() => _loadCustomColors());
    }
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Set default colors on first run
    if (!_prefs.containsKey('color_morning')) {
      await _saveColorDirect('color_morning', Colors.blue);
    }
    if (!_prefs.containsKey('color_evening')) {
      await _saveColorDirect('color_evening', Colors.orange);
    }
    if (!_prefs.containsKey('color_night')) {
      await _saveColorDirect('color_night', Colors.black);
    }
    
    // Set default shift pattern on first run (5-day rotation)
    if (!_prefs.containsKey('shift_pattern')) {
      await _prefs.setString('shift_pattern', '0,1,2,3,3');
    }
    
    // Set default shift hours on first run
    if (!_prefs.containsKey('morning_start')) {
      await _prefs.setString('morning_start', '7:00 AM');
      await _prefs.setString('morning_end', '3:00 PM');
      await _prefs.setString('evening_start', '3:00 PM');
      await _prefs.setString('evening_end', '11:00 PM');
      await _prefs.setString('night_start', '11:00 PM');
      await _prefs.setString('night_end', '7:00 AM');
    }
    
    // Set default cycle start date on first run
    if (!_prefs.containsKey('cycle_start_date')) {
      await _prefs.setString('cycle_start_date', '2026-02-01');
    }
    
    setState(() {
      selectedShift = _prefs.getString('selectedShift') ?? 'A';
      _loadCustomColorsSync();
      _loadShiftPatternSync();
      _loadShiftHoursSync();
      _loadCycleStartDateSync();
      _isLoaded = true;
    });
    
    // Schedule notifications after loading preferences
    _scheduleUpcomingNotifications();
  }

  Future<void> _scheduleUpcomingNotifications() async {
    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();
    
    // Schedule notifications for the next 7 days
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Check if this is a work day (not rest day)
      int offset = shiftOffsets[selectedShift] ?? 0;
      int cycleIndex = getCycleDay(normalizedDate, offset);
      int dutyType = shiftPattern[cycleIndex];
      
      if (dutyType != 3) { // Not a rest day
        DateTime shiftStartTime;
        String dutyName;
        
        switch (dutyType) {
          case 0: // Morning
            shiftStartTime = _parseShiftTime(normalizedDate, shiftHours['morning_start'] ?? '7:00 AM');
            dutyName = 'Morning (${shiftHours['morning_start']} - ${shiftHours['morning_end']})';
            break;
          case 1: // Evening
            shiftStartTime = _parseShiftTime(normalizedDate, shiftHours['evening_start'] ?? '3:00 PM');
            dutyName = 'Evening (${shiftHours['evening_start']} - ${shiftHours['evening_end']})';
            break;
          case 2: // Night
            shiftStartTime = _parseShiftTime(normalizedDate, shiftHours['night_start'] ?? '11:00 PM');
            dutyName = 'Night (${shiftHours['night_start']} - ${shiftHours['night_end']})';
            break;
          default:
            continue;
        }
        
        await notificationService.scheduleShiftNotifications(
          shiftStartTime: shiftStartTime,
          shift: selectedShift,
          duty: dutyName,
          dayIndex: i,
        );
      }
    }
  }

  DateTime _parseShiftTime(DateTime date, String timeStr) {
    // Parse time string like "7:00 AM" or "3:00 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    if (parts.length > 1 && parts[1].toUpperCase() == 'PM' && hour != 12) {
      hour += 12;
    } else if (parts.length > 1 && parts[1].toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> _saveColorDirect(String key, Color color) async {
    final a = (color.a * 255.0).round().clamp(0, 255);
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final argbInt = (a << 24) | (r << 16) | (g << 8) | b;
    await _prefs.setString(key, argbInt.toString());
  }

  Future<void> _saveSelectedShift(String shift) async {
    await _prefs.setString('selectedShift', shift);
  }

  void _loadCustomColorsSync() {
    String? morningColor = _prefs.getString('color_morning');
    String? eveningColor = _prefs.getString('color_evening');
    String? nightColor = _prefs.getString('color_night');

    if (morningColor != null) {
      shiftColors['morning'] = Color(int.parse(morningColor));
    }
    if (eveningColor != null) {
      shiftColors['evening'] = Color(int.parse(eveningColor));
    }
    if (nightColor != null) {
      shiftColors['night'] = Color(int.parse(nightColor));
    }
  }

  void _loadCustomColors() {
    setState(() {
      _loadCustomColorsSync();
    });
  }

  void _loadShiftPatternSync() {
    String? patternStr = _prefs.getString('shift_pattern');
    if (patternStr != null) {
      shiftPattern = patternStr.split(',').map((e) => int.parse(e)).toList();
    }
  }

  void _loadShiftHoursSync() {
    shiftHours['morning_start'] = _prefs.getString('morning_start') ?? '7:00 AM';
    shiftHours['morning_end'] = _prefs.getString('morning_end') ?? '3:00 PM';
    shiftHours['evening_start'] = _prefs.getString('evening_start') ?? '3:00 PM';
    shiftHours['evening_end'] = _prefs.getString('evening_end') ?? '11:00 PM';
    shiftHours['night_start'] = _prefs.getString('night_start') ?? '11:00 PM';
    shiftHours['night_end'] = _prefs.getString('night_end') ?? '7:00 AM';
  }

  void _loadCycleStartDateSync() {
    String? dateStr = _prefs.getString('cycle_start_date');
    if (dateStr != null) {
      final parsed = DateTime.parse(dateStr);
      cycleStartDate = DateTime(parsed.year, parsed.month, parsed.day);
    }
  }

  int getCycleDay(DateTime date, int offset) {
    // Normalize both dates to midnight local time to avoid timezone issues
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedCycleStart = DateTime(cycleStartDate.year, cycleStartDate.month, cycleStartDate.day);
    int daysSince = normalizedDate.difference(normalizedCycleStart).inDays;
    int cycleLength = shiftPattern.length;
    int cycle = (daysSince + offset) % cycleLength;
    if (cycle < 0) cycle += cycleLength;
    return cycle;
  }

  String getDuty(DateTime date, String shift) {
    int offset = shiftOffsets[shift] ?? 0;
    int c = getCycleDay(date, offset);
    int dutyType = shiftPattern[c];
    switch (dutyType) {
      case 0:
        return '${shiftHours['morning_start']} - ${shiftHours['morning_end']}';
      case 1:
        return '${shiftHours['evening_start']} - ${shiftHours['evening_end']}';
      case 2:
        return '${shiftHours['night_start']} - ${shiftHours['night_end']} (next day)';
      default:
        return 'Off';
    }
  }

  String getDutyTypeName(DateTime date, String shift) {
    int offset = shiftOffsets[shift] ?? 0;
    int c = getCycleDay(date, offset);
    int dutyType = shiftPattern[c];
    switch (dutyType) {
      case 0:
        return 'Morning Shift';
      case 1:
        return 'Evening Shift';
      case 2:
        return 'Night Shift';
      default:
        return 'Day Off';
    }
  }

  Color getDutyColor(DateTime date, String shift) {
    int offset = shiftOffsets[shift] ?? 0;
    int c = getCycleDay(date, offset);
    int dutyType = shiftPattern[c];
    switch (dutyType) {
      case 0:
        return shiftColors['morning']!;
      case 1:
        return shiftColors['evening']!;
      case 2:
        return shiftColors['night']!;
      default:
        return shiftColors['off']!;
    }
  }

  String _getNoteKey(DateTime date) {
    return 'note_${date.year}_${date.month}_${date.day}';
  }

  Future<String?> _getNote(DateTime date) async {
    return _prefs.getString(_getNoteKey(date));
  }

  Future<void> _saveNote(DateTime date, String note) async {
    if (note.isEmpty) {
      await _prefs.remove(_getNoteKey(date));
    } else {
      await _prefs.setString(_getNoteKey(date), note);
    }
  }

  void _showNoteDialog(DateTime date) {
    String noteText = '';
    _getNote(date).then((note) {
      if (!mounted) return;
      noteText = note ?? '';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Note for ${date.year}-${date.month}-${date.day}'),
          content: TextField(
            controller: TextEditingController(text: noteText),
            maxLines: 4,
            onChanged: (value) {
              noteText = value;
            },
            decoration: const InputDecoration(
              hintText: 'Add a note for this day...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (noteText.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await _saveNote(date, '');
                  setState(() {});
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: () async {
                await _saveNote(date, noteText);
                setState(() {});
                // ignore: use_build_context_synchronously
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedDay ??= focusedDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Shift Schedule')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedShift,
              items: ['A', 'B', 'C', 'D', 'F']
                  .map((s) => DropdownMenuItem(value: s, child: Text('Shift $s')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedShift = value;
                  });
                  _saveSelectedShift(value);
                  _scheduleUpcomingNotifications(); // Reschedule notifications for new shift
                }
              },
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            onDayLongPressed: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
              _showNoteDialog(selected);
            },
            calendarFormat: CalendarFormat.month,
            onPageChanged: (focused) {
              focusedDay = focused;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                Color color = getDutyColor(day, selectedShift);
                return FutureBuilder<String?>(
                  future: _getNote(day),
                  builder: (context, snapshot) {
                    bool hasNote = snapshot.hasData && snapshot.data != null;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        if (hasNote)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                Color color = getDutyColor(day, selectedShift);
                return FutureBuilder<String?>(
                  future: _getNote(day),
                  builder: (context, snapshot) {
                    bool hasNote = snapshot.hasData && snapshot.data != null;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (hasNote)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
              todayBuilder: (context, day, focusedDay) {
                Color color = getDutyColor(day, selectedShift);
                return FutureBuilder<String?>(
                  future: _getNote(day),
                  builder: (context, snapshot) {
                    bool hasNote = snapshot.hasData && snapshot.data != null;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 3,
                            ),
                          ),
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (hasNote)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Today's Duty Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: getDutyColor(DateTime.now(), selectedShift).withValues(alpha: 0.2),
                      border: Border.all(
                        color: getDutyColor(DateTime.now(), selectedShift),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Today (${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year})',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getDutyTypeName(DateTime.now(), selectedShift),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: getDutyColor(DateTime.now(), selectedShift),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getDuty(DateTime.now(), selectedShift),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected Day Duty Card
                  if (selectedDay != null && !isSameDay(selectedDay, DateTime.now()))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: getDutyColor(selectedDay!, selectedShift).withValues(alpha: 0.15),
                        border: Border.all(
                          color: getDutyColor(selectedDay!, selectedShift).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_month, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Selected (${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year})',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            getDutyTypeName(selectedDay!, selectedShift),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: getDutyColor(selectedDay!, selectedShift),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getDuty(selectedDay!, selectedShift),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  // Note Display
                  if (selectedDay != null)
                    const SizedBox(height: 12),
                  if (selectedDay != null)
                    FutureBuilder<String?>(
                      future: _getNote(selectedDay!),
                      builder: (context, snapshot) {
                        String? note = snapshot.data;
                        if (note != null && note.isNotEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withValues(alpha: 0.2),
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.note, size: 18, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Note:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  note,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  const SizedBox(height: 16),
                  // Hint text for adding notes
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hold on a date to add a note',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  Color morningColor = Colors.blue;
  Color eveningColor = Colors.orange;
  Color nightColor = Colors.black;
  late ThemeMode _themeMode;
  List<int> shiftPattern = [0, 1, 2, 3, 3]; // Default 5-day pattern
  
  // Custom shift hours
  Map<String, String> shiftHours = {
    'morning_start': '7:00 AM',
    'morning_end': '3:00 PM',
    'evening_start': '3:00 PM',
    'evening_end': '11:00 PM',
    'night_start': '11:00 PM',
    'night_end': '7:00 AM',
  };
  
  // Cycle start date
  DateTime cycleStartDate = DateTime(2026, 2, 1);
  int todayCycleDay = 1; // For "Apply from today" feature

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() => _loadSettings());
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _themeMode = widget.themeMode;
    }
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      String? morning = _prefs.getString('color_morning');
      String? evening = _prefs.getString('color_evening');
      String? night = _prefs.getString('color_night');
      String? patternStr = _prefs.getString('shift_pattern');

      if (morning != null) morningColor = Color(int.parse(morning));
      if (evening != null) eveningColor = Color(int.parse(evening));
      if (night != null) nightColor = Color(int.parse(night));
      if (patternStr != null) {
        shiftPattern = patternStr.split(',').map((e) => int.parse(e)).toList();
      }
      
      // Load shift hours
      shiftHours['morning_start'] = _prefs.getString('morning_start') ?? '7:00 AM';
      shiftHours['morning_end'] = _prefs.getString('morning_end') ?? '3:00 PM';
      shiftHours['evening_start'] = _prefs.getString('evening_start') ?? '3:00 PM';
      shiftHours['evening_end'] = _prefs.getString('evening_end') ?? '11:00 PM';
      shiftHours['night_start'] = _prefs.getString('night_start') ?? '11:00 PM';
      shiftHours['night_end'] = _prefs.getString('night_end') ?? '7:00 AM';
      
      // Load cycle start date
      String? dateStr = _prefs.getString('cycle_start_date');
      if (dateStr != null) {
        cycleStartDate = DateTime.parse(dateStr);
      }
    });
  }

  Future<void> _saveColor(String key, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final a = (color.a * 255.0).round().clamp(0, 255);
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final argbInt = (a << 24) | (r << 16) | (g << 8) | b;
    await prefs.setString(key, argbInt.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'App Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              onChanged: (mode) {
                if (mode == null) return;
                setState(() {
                  _themeMode = mode;
                });
                widget.onThemeModeChanged(mode);
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Customize Shift Colors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Morning shift color
          ListTile(
            title: const Text('Morning Shift (7 AM - 3 PM)'),
            trailing: GestureDetector(
              onTap: () async {
                final color = await _showColorPicker(morningColor);
                if (color != null) {
                  setState(() {
                    morningColor = color;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: morningColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
              ),
            ),
          ),
          // Evening shift color
          ListTile(
            title: const Text('Evening Shift (3 PM - 11 PM)'),
            trailing: GestureDetector(
              onTap: () async {
                final color = await _showColorPicker(eveningColor);
                if (color != null) {
                  setState(() {
                    eveningColor = color;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: eveningColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
              ),
            ),
          ),
          // Night shift color
          ListTile(
            title: const Text('Night Shift (11 PM - 7 AM)'),
            trailing: GestureDetector(
              onTap: () async {
                final color = await _showColorPicker(nightColor);
                if (color != null) {
                  setState(() {
                    nightColor = color;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: nightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await _saveColor('color_morning', morningColor);
              await _saveColor('color_evening', eveningColor);
              await _saveColor('color_night', nightColor);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Colors saved successfully!')),
              );
            },
            child: const Text('Save Colors'),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Shift Pattern',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Current: ${shiftPattern.length}-day rotation',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          // Pattern editor
          ...List.generate(shiftPattern.length, (index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getDutyColorFromType(shiftPattern[index]),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: shiftPattern[index] == 3 ? Colors.black : Colors.white,
                  ),
                ),
              ),
              title: Text('Day ${index + 1}'),
              trailing: DropdownButton<int>(
                value: shiftPattern[index],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      shiftPattern[index] = value;
                    });
                  }
                },
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Morning')),
                  DropdownMenuItem(value: 1, child: Text('Evening')),
                  DropdownMenuItem(value: 2, child: Text('Night')),
                  DropdownMenuItem(value: 3, child: Text('Off')),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (shiftPattern.length < 14) {
                    setState(() {
                      shiftPattern.add(3); // Add Off day
                    });
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Day'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (shiftPattern.length > 1) {
                    setState(() {
                      shiftPattern.removeLast();
                    });
                  }
                },
                icon: const Icon(Icons.remove),
                label: const Text('Remove Day'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                shiftPattern = [0, 1, 2, 3, 3];
              });
            },
            child: const Text('Reset to Default (5-day)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              String patternStr = shiftPattern.join(',');
              await _prefs.setString('shift_pattern', patternStr);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift pattern saved!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save Pattern'),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Shift Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Morning shift hours
          ListTile(
            title: const Text('Morning Shift'),
            subtitle: Text('${shiftHours['morning_start']} - ${shiftHours['morning_end']}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editShiftHours('morning'),
            ),
          ),
          // Evening shift hours
          ListTile(
            title: const Text('Evening Shift'),
            subtitle: Text('${shiftHours['evening_start']} - ${shiftHours['evening_end']}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editShiftHours('evening'),
            ),
          ),
          // Night shift hours
          ListTile(
            title: const Text('Night Shift'),
            subtitle: Text('${shiftHours['night_start']} - ${shiftHours['night_end']}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editShiftHours('night'),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Cycle Start Date',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Today is Day ${_getTodayCycleDay()} of the pattern',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Set Today as Cycle Day'),
            trailing: DropdownButton<int>(
              value: todayCycleDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    todayCycleDay = value;
                  });
                }
              },
              items: List.generate(shiftPattern.length, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text('Day ${index + 1}'),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Calculate new cycle start date so that today is the selected day
              DateTime today = DateTime.now();
              DateTime todayOnly = DateTime(today.year, today.month, today.day);
              // If today should be Day X, then cycle start = today - (X-1) days
              cycleStartDate = todayOnly.subtract(Duration(days: todayCycleDay - 1));
              String dateStr = '${cycleStartDate.year}-${cycleStartDate.month.toString().padLeft(2, '0')}-${cycleStartDate.day.toString().padLeft(2, '0')}';
              await _prefs.setString('cycle_start_date', dateStr);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Today is now Day $todayCycleDay of the pattern!')),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Apply Cycle Day'),
          ),
        ],
      ),
    );
  }

  Color _getDutyColorFromType(int dutyType) {
    switch (dutyType) {
      case 0:
        return morningColor;
      case 1:
        return eveningColor;
      case 2:
        return nightColor;
      default:
        return Colors.white;
    }
  }

  int _getTodayCycleDay() {
    DateTime today = DateTime.now();
    DateTime todayOnly = DateTime(today.year, today.month, today.day);
    int daysSince = todayOnly.difference(cycleStartDate).inDays;
    int cycleLength = shiftPattern.length;
    int cycle = daysSince % cycleLength;
    if (cycle < 0) cycle += cycleLength;
    return cycle + 1; // 1-based
  }

  void _editShiftHours(String shiftType) {
    String startKey = '${shiftType}_start';
    String endKey = '${shiftType}_end';
    String startTime = shiftHours[startKey] ?? '';
    String endTime = shiftHours[endKey] ?? '';
    
    final startController = TextEditingController(text: startTime);
    final endController = TextEditingController(text: endTime);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${shiftType.substring(0, 1).toUpperCase()}${shiftType.substring(1)} Shift Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Start Time',
                hintText: 'e.g., 7:00 AM',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'End Time',
                hintText: 'e.g., 3:00 PM',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                shiftHours[startKey] = startController.text;
                shiftHours[endKey] = endController.text;
              });
              await _prefs.setString(startKey, startController.text);
              await _prefs.setString(endKey, endController.text);
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift hours saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<Color?> _showColorPicker(Color initialColor) async {
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPickerWidget(
            initialColor: initialColor,
            onColorChanged: (color) {
              Navigator.of(context).pop(color);
            },
          ),
        ),
      ),
    );
  }
}

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedColor,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          children: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.cyan,
            Colors.lime,
            Colors.indigo,
            Colors.lightBlueAccent,
            Colors.deepOrange,
            Colors.black,
          ]
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    widget.onColorChanged(color);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.black
                            : Colors.grey,
                        width: _selectedColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// Leave type enum
enum LeaveType { vacation, sickLeave, urgent }

class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, String> _leaveRecords = {}; // date -> leave type
  LeaveType _selectedLeaveType = LeaveType.vacation;

  @override
  void initState() {
    super.initState();
    _loadLeaveRecords();
  }

  Future<void> _loadLeaveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('leave_records') ?? '{}';
    setState(() {
      _leaveRecords = Map<String, String>.from(
        Map<String, dynamic>.from(
          Uri.splitQueryString(recordsJson).map((key, value) => MapEntry(key, value)),
        ),
      );
      // Better parsing for JSON-like storage
      final stored = prefs.getStringList('leave_records_list') ?? [];
      _leaveRecords = {};
      for (var entry in stored) {
        final parts = entry.split('|');
        if (parts.length == 2) {
          _leaveRecords[parts[0]] = parts[1];
        }
      }
    });
  }

  Future<void> _saveLeaveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _leaveRecords.entries.map((e) => '${e.key}|${e.value}').toList();
    await prefs.setStringList('leave_records_list', list);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getLeaveColor(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return Colors.blue;
      case 'sickLeave':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLeaveLabel(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return 'Vacation';
      case 'sickLeave':
        return 'Sick Leave';
      case 'urgent':
        return 'Urgent';
      default:
        return '';
    }
  }

  IconData _getLeaveIcon(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return Icons.beach_access;
      case 'sickLeave':
        return Icons.local_hospital;
      case 'urgent':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  void _toggleLeave(DateTime day) {
    final dateKey = _formatDate(day);
    final leaveTypeStr = _selectedLeaveType.name;
    
    setState(() {
      if (_leaveRecords[dateKey] == leaveTypeStr) {
        // Remove if same type clicked again
        _leaveRecords.remove(dateKey);
      } else {
        // Add or change leave type
        _leaveRecords[dateKey] = leaveTypeStr;
      }
    });
    _saveLeaveRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacation / Leave'),
      ),
      body: Column(
        children: [
          // Leave type selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLeaveTypeChip(LeaveType.vacation, 'Vacation', Colors.blue, Icons.beach_access),
                _buildLeaveTypeChip(LeaveType.sickLeave, 'Sick', Colors.orange, Icons.local_hospital),
                _buildLeaveTypeChip(LeaveType.urgent, 'Urgent', Colors.red, Icons.warning),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Tap a day to mark/unmark leave',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar
          Expanded(
            child: TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _toggleLeave(selectedDay);
              },
              calendarFormat: CalendarFormat.month,
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final dateKey = _formatDate(day);
                  final leaveType = _leaveRecords[dateKey];
                  
                  if (leaveType != null) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getLeaveColor(leaveType),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              day.day.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Icon(_getLeaveIcon(leaveType), size: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  final dateKey = _formatDate(day);
                  final leaveType = _leaveRecords[dateKey];
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: leaveType != null ? _getLeaveColor(leaveType) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: leaveType != null ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (leaveType != null)
                            Icon(_getLeaveIcon(leaveType), size: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Vacation', Colors.blue),
                _buildLegendItem('Sick Leave', Colors.orange),
                _buildLegendItem('Urgent', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeChip(LeaveType type, String label, Color color, IconData icon) {
    final isSelected = _selectedLeaveType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLeaveType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  Map<String, String> _leaveRecords = {};
  int _selectedYear = DateTime.now().year;
  List<int> _shiftPattern = [0, 1, 2, 3, 3];
  DateTime _cycleStartDate = DateTime(2026, 2, 1);
  String _selectedShift = 'A';
  
  final Map<String, int> _shiftOffsets = {
    'A': 0,
    'B': 1,
    'C': 2,
    'D': 3,
    'E': 4,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load leave records
    final stored = prefs.getStringList('leave_records_list') ?? [];
    
    // Load shift pattern
    final patternStr = prefs.getString('shift_pattern') ?? '0,1,2,3,3';
    final pattern = patternStr.split(',').map((e) => int.parse(e)).toList();
    
    // Load cycle start date
    final dateStr = prefs.getString('cycle_start_date') ?? '2026-02-01';
    final cycleDate = DateTime.parse(dateStr);
    
    // Load selected shift
    final shift = prefs.getString('selectedShift') ?? 'A';
    
    setState(() {
      _leaveRecords = {};
      for (var entry in stored) {
        final parts = entry.split('|');
        if (parts.length == 2) {
          _leaveRecords[parts[0]] = parts[1];
        }
      }
      _shiftPattern = pattern;
      _cycleStartDate = cycleDate;
      _selectedShift = shift;
    });
  }

  bool _isShiftDay(DateTime date) {
    final offset = _shiftOffsets[_selectedShift] ?? 0;
    final daysSince = date.difference(_cycleStartDate).inDays;
    int cycle = (daysSince + offset) % _shiftPattern.length;
    if (cycle < 0) cycle += _shiftPattern.length;
    final dutyType = _shiftPattern[cycle];
    return dutyType != 3; // Not a rest day
  }

  List<MapEntry<String, String>> _getFilteredRecords() {
    return _leaveRecords.entries
        .where((entry) => entry.key.startsWith('$_selectedYear-'))
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // Sort by date descending
  }

  int _countByType(String type) {
    return _leaveRecords.entries
        .where((e) => e.key.startsWith('$_selectedYear-') && e.value == type)
        .length;
  }

  Color _getLeaveColor(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return Colors.blue;
      case 'sickLeave':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLeaveLabel(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return 'Vacation';
      case 'sickLeave':
        return 'Sick Leave';
      case 'urgent':
        return 'Urgent';
      default:
        return '';
    }
  }

  IconData _getLeaveIcon(String? leaveType) {
    switch (leaveType) {
      case 'vacation':
        return Icons.beach_access;
      case 'sickLeave':
        return Icons.local_hospital;
      case 'urgent':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _formatDisplayDate(String dateKey) {
    try {
      final parts = dateKey.split('-');
      final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[int.parse(parts[1])]} ${int.parse(parts[2])}, ${parts[0]}';
    } catch (e) {
      return dateKey;
    }
  }

  int _getTotalScheduledShiftDays() {
    final now = DateTime.now();
    final startOfYear = DateTime(_selectedYear, 1, 1);
    DateTime endDate;
    
    if (_selectedYear < now.year) {
      // Past year - count full year
      final isLeapYear = (_selectedYear % 4 == 0 && _selectedYear % 100 != 0) || (_selectedYear % 400 == 0);
      endDate = DateTime(_selectedYear, 12, 31);
    } else if (_selectedYear == now.year) {
      // Current year - count days from Jan 1 to today
      endDate = now;
    } else {
      // Future year - no days yet
      return 0;
    }
    
    // Count only shift days (not rest days)
    int shiftDays = 0;
    DateTime current = startOfYear;
    while (!current.isAfter(endDate)) {
      if (_isShiftDay(current)) {
        shiftDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    return shiftDays;
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _getFilteredRecords();
    final vacationCount = _countByType('vacation');
    final sickCount = _countByType('sickLeave');
    final urgentCount = _countByType('urgent');
    final totalAbsences = vacationCount + sickCount + urgentCount;
    final totalScheduled = _getTotalScheduledShiftDays();
    final actualWorked = totalScheduled - totalAbsences;
    final percentage = totalScheduled > 0 ? (actualWorked / totalScheduled) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Records'),
      ),
      body: Column(
        children: [
          // Year selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                ),
              ],
            ),
          ),
          // Summary cards - Row 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Absences', totalAbsences, Colors.purple, Icons.event_busy)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Vacation', vacationCount, Colors.blue, Icons.beach_access)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Summary cards - Row 2
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: _buildSummaryCard('Sick', sickCount, Colors.orange, Icons.local_hospital)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Urgent', urgentCount, Colors.red, Icons.warning)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Actual Days Worked Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work, color: Colors.green, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Actual Days Worked ≈ $actualWorked',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalScheduled - $totalAbsences (vacation + sick + urgent)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    // Percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}% Attendance',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Absences are subtracted from total (approximate, not shift-specific).',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          // Records list
          Expanded(
            child: filteredRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No leave records for $_selectedYear',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getLeaveColor(record.value),
                          child: Icon(_getLeaveIcon(record.value), color: Colors.white, size: 20),
                        ),
                        title: Text(_formatDisplayDate(record.key)),
                        subtitle: Text(_getLeaveLabel(record.value)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _deleteRecord(record.key),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRecord(String dateKey) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Remove leave record for ${_formatDisplayDate(dateKey)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _leaveRecords.remove(dateKey);
      });
      final prefs = await SharedPreferences.getInstance();
      final list = _leaveRecords.entries.map((e) => '${e.key}|${e.value}').toList();
      await prefs.setStringList('leave_records_list', list);
    }
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dedicated From',
              style: TextStyle(fontSize: 24, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              'Abdullah Aldihani',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              '99074883',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


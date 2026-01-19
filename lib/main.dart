import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initNotifications();
  
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
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D Shift',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        onThemeChanged: _setThemeMode,
        currentTheme: _themeMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode currentTheme;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ShiftCalendarScreen(),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        currentTheme: widget.currentTheme,
      ),
      const InfoScreen(),
    ];
  }

@override
Widget build(BuildContext context) {
return Scaffold(
body: _screens[_currentIndex],
bottomNavigationBar: BottomNavigationBar(
currentIndex: _currentIndex,
onTap: (index) {
setState(() {
_currentIndex = index;
});
},
backgroundColor: Theme.of(context).scaffoldBackgroundColor,
selectedItemColor: Theme.of(context).primaryColor,
unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
  Map<String, Color> shiftColors = {
    'morning': Colors.lightBlueAccent,
    'evening': Colors.orange,
    'night': const Color(0xFF1F1F1F),
    'off': Colors.white,
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedShift();
    _loadCustomColors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload colors whenever this widget's context updates (e.g., tab switching)
    Future.microtask(() => _loadCustomColors());
  }

  Future<void> _loadSelectedShift() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedShift = _prefs.getString('selectedShift') ?? 'A';
    });
  }

  Future<void> _loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();
    final morningColorStr = prefs.getString('color_morning');
    final eveningColorStr = prefs.getString('color_evening');
    final nightColorStr = prefs.getString('color_night');

    if (mounted) {
      setState(() {
        if (morningColorStr != null) {
          shiftColors['morning'] = Color(int.parse(morningColorStr));
        } else {
          shiftColors['morning'] = Colors.lightBlueAccent;
        }
        if (eveningColorStr != null) {
          shiftColors['evening'] = Color(int.parse(eveningColorStr));
        } else {
          shiftColors['evening'] = Colors.orange;
        }
        if (nightColorStr != null) {
          shiftColors['night'] = Color(int.parse(nightColorStr));
        } else {
          shiftColors['night'] = const Color(0xFF1F1F1F);
        }
      });
    }
  }

  Future<void> _saveSelectedShift(String shift) async {
    await _prefs.setString('selectedShift', shift);
  }

int getCycleDay(DateTime date, int offset) {
final DateTime startDate = DateTime(2026, 2, 1);
int daysSince = date.difference(startDate).inDays;
int cycle = (daysSince + offset) % 5;
if (cycle < 0) cycle += 5;
return cycle;
}

String getDuty(DateTime date, String shift) {
int offset = shiftOffsets[shift] ?? 0;
int c = getCycleDay(date, offset);
switch (c) {
case 0:
return '7:00 AM - 3:00 PM';
case 1:
return '3:00 PM - 11:00 PM';
case 2:
return '11:00 PM - 7:00 AM (next day)';
default:
return 'Off';
}
}

Color getDutyColor(DateTime date, String shift) {
int offset = shiftOffsets[shift] ?? 0;
int c = getCycleDay(date, offset);
switch (c) {
case 0:
return shiftColors['morning'] ?? Colors.lightBlueAccent;
case 1:
return shiftColors['evening'] ?? Colors.orange;
case 2:
return shiftColors['night'] ?? Colors.black;
default:
return shiftColors['off'] ?? Colors.white;
}
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
calendarFormat: CalendarFormat.month,
onPageChanged: (focused) {
focusedDay = focused;
},
calendarBuilders: CalendarBuilders(
defaultBuilder: (context, day, focusedDay) {
Color color = getDutyColor(day, selectedShift);
return Container(
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
);
},
selectedBuilder: (context, day, focusedDay) {
Color color = getDutyColor(day, selectedShift);
return Container(
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
);
},
todayBuilder: (context, day, focusedDay) {
Color color = getDutyColor(day, selectedShift);
return Container(
margin: const EdgeInsets.all(4.0),
alignment: Alignment.center,
decoration: BoxDecoration(
color: color.withValues(alpha: 0.5),
shape: BoxShape.circle,
border: Border.all(color: Colors.black),
),
child: Text(
'${day.day}',
style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
),
);
},
),
),
const SizedBox(height: 20),
Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
Text(
'Today\'s Duty (${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}):',
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
Text(getDuty(DateTime.now(), selectedShift), style: const TextStyle(fontSize: 20)),
const SizedBox(height: 10),
                if (selectedDay != null)
                  Text(
                    'Selected Day Duty (${selectedDay!.year}-${selectedDay!.month}-${selectedDay!.day}):',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (selectedDay != null)
                  Text(
                    getDuty(selectedDay!, selectedShift),
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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

class SettingsScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode currentTheme;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  late ThemeMode _currentTheme;
  Map<String, Color> shiftColors = {
    'morning': Colors.lightBlueAccent,
    'evening': Colors.orange,
    'night': const Color(0xFF1F1F1F),
  };

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.currentTheme;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      final morningColorStr = _prefs.getString('color_morning');
      final eveningColorStr = _prefs.getString('color_evening');
      final nightColorStr = _prefs.getString('color_night');

      if (morningColorStr != null) {
        shiftColors['morning'] = Color(int.parse(morningColorStr));
      } else {
        shiftColors['morning'] = Colors.lightBlueAccent;
      }
      if (eveningColorStr != null) {
        shiftColors['evening'] = Color(int.parse(eveningColorStr));
      } else {
        shiftColors['evening'] = Colors.orange;
      }
      if (nightColorStr != null) {
        shiftColors['night'] = Color(int.parse(nightColorStr));
      } else {
        shiftColors['night'] = const Color(0xFF1F1F1F);
      }
    });
  }

  Future<void> _saveColor(String key, Color color) async {
    // Just update local state - will be saved when user clicks "Save Changes"
    setState(() {
      shiftColors[key] = color;
    });
  }

  void _showColorPicker(String shiftType) async {
    Color selectedColor = shiftColors[shiftType] ?? Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select $shiftType color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            children: [
              Colors.lightBlueAccent,
              Colors.orange,
              Colors.black,
              Colors.red,
              Colors.green,
              Colors.purple,
              Colors.pink,
              Colors.amber,
            ]
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      _saveColor(shiftType, color);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: selectedColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_brightness),
              ),
            ],
            selected: <ThemeMode>{_currentTheme},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              setState(() {
                _currentTheme = newSelection.first;
                _prefs.setBool('darkMode', newSelection.first == ThemeMode.dark);
              });
              widget.onThemeChanged(_currentTheme);
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'Shift Colors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildColorSetting('Morning (7:00 AM - 3:00 PM)', 'morning'),
          _buildColorSetting('Evening (3:00 PM - 11:00 PM)', 'evening'),
          _buildColorSetting('Night (11:00 PM - 7:00 AM)', 'night'),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              // Convert colors to ARGB int values using toARGB32()
              final morningValue = (shiftColors['morning']!.a.toInt() << 24) |
                  (shiftColors['morning']!.r.toInt() << 16) |
                  (shiftColors['morning']!.g.toInt() << 8) |
                  shiftColors['morning']!.b.toInt();
              final eveningValue = (shiftColors['evening']!.a.toInt() << 24) |
                  (shiftColors['evening']!.r.toInt() << 16) |
                  (shiftColors['evening']!.g.toInt() << 8) |
                  shiftColors['evening']!.b.toInt();
              final nightValue = (shiftColors['night']!.a.toInt() << 24) |
                  (shiftColors['night']!.r.toInt() << 16) |
                  (shiftColors['night']!.g.toInt() << 8) |
                  shiftColors['night']!.b.toInt();
              
              await _prefs.setString('color_morning', morningValue.toString());
              await _prefs.setString('color_evening', eveningValue.toString());
              await _prefs.setString('color_night', nightValue.toString());
              
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Colors saved successfully!')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSetting(String label, String shiftType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          GestureDetector(
            onTap: () => _showColorPicker(shiftType),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: shiftColors[shiftType] ?? Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


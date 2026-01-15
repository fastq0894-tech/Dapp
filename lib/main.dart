import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'D Shift',
theme: ThemeData(primarySwatch: Colors.blue),
home: const HomeScreen(),
);
}
}

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
int _currentIndex = 0;

final List<Widget> _screens = [
const ShiftCalendarScreen(),
const InfoScreen(),
];

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
items: const [
BottomNavigationBarItem(
icon: Icon(Icons.calendar_today),
label: 'Calendar',
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
'A': 0,
'B': 1,
'C': 2,
'D': 3,
'F': 4,
};

late SharedPreferences _prefs;

@override
void initState() {
super.initState();
_loadSelectedShift();
}

Future<void> _loadSelectedShift() async {
_prefs = await SharedPreferences.getInstance();
setState(() {
selectedShift = _prefs.getString('selectedShift') ?? 'A';
});
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
return Colors.lightBlueAccent;
case 1:
return Colors.orange;
case 2:
return Colors.black;
default:
return Colors.grey;
}
}

@override
Widget build(BuildContext context) {
selectedDay ??= focusedDay;

return Scaffold(
appBar: AppBar(title: const Text('D Shift Schedule')),
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
color: color.withOpacity(0.3),
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
color: color.withOpacity(0.5),
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
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
if (selectedDay != null) Text(getDuty(selectedDay!, selectedShift), style: const TextStyle(fontSize: 20)),
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
],
),
),
);
}
}
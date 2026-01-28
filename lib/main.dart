import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'dart:async';
import 'dart:math';

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

// Pixel Art Animal Types
enum PixelAnimal { cat, bird, monkey, eagle, horse, rabbit, fox, frog, owl, penguin }

// Pixel Art Animal Painter - Ultra Detailed 24x24 Version
class PixelAnimalPainter extends CustomPainter {
  final PixelAnimal animal;
  final Color color;
  final bool facingRight;
  final int frame; // Animation frame 0 or 1

  PixelAnimalPainter({
    required this.animal,
    required this.color,
    this.facingRight = true,
    this.frame = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 24;
    
    void drawPixel(int x, int y, Color c) {
      final px = facingRight ? x : 23 - x;
      canvas.drawRect(
        Rect.fromLTWH(px * pixelSize, y * pixelSize, pixelSize, pixelSize),
        Paint()..color = c,
      );
    }
    
    // Helper colors
    final mainColor = color;
    final darkColor = Color.fromRGBO(
      (color.r * 255 * 0.6).round(),
      (color.g * 255 * 0.6).round(),
      (color.b * 255 * 0.6).round(),
      1,
    );
    final lightColor = Color.fromRGBO(
      ((color.r * 255 + (255 - color.r * 255) * 0.4)).round().clamp(0, 255),
      ((color.g * 255 + (255 - color.g * 255) * 0.4)).round().clamp(0, 255),
      ((color.b * 255 + (255 - color.b * 255) * 0.4)).round().clamp(0, 255),
      1,
    );
    const white = Colors.white;
    const black = Colors.black;
    const pink = Colors.pink;

    switch (animal) {
      case PixelAnimal.cat:
        // Ears (outer) - scaled for 24x24
        for (int x = 4; x <= 6; x++) drawPixel(x, 0, mainColor);
        for (int x = 16; x <= 18; x++) drawPixel(x, 0, mainColor);
        for (int x = 3; x <= 7; x++) drawPixel(x, 1, mainColor);
        for (int x = 15; x <= 19; x++) drawPixel(x, 1, mainColor);
        for (int x = 3; x <= 7; x++) drawPixel(x, 2, mainColor);
        for (int x = 15; x <= 19; x++) drawPixel(x, 2, mainColor);
        // Ears (inner pink)
        drawPixel(5, 1, pink); drawPixel(5, 2, pink);
        drawPixel(17, 1, pink); drawPixel(17, 2, pink);
        // Head
        for (int x = 4; x <= 18; x++) drawPixel(x, 3, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 4, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 5, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 6, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 7, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 8, mainColor);
        // Eyes (white part)
        for (int y = 4; y <= 6; y++) { drawPixel(6, y, white); drawPixel(7, y, white); drawPixel(8, y, white); }
        for (int y = 4; y <= 6; y++) { drawPixel(14, y, white); drawPixel(15, y, white); drawPixel(16, y, white); }
        // Pupils
        drawPixel(7, 5, black); drawPixel(8, 5, black);
        drawPixel(14, 5, black); drawPixel(15, 5, black);
        // Eye shine
        drawPixel(6, 4, Color(0xFFADD8E6));
        drawPixel(14, 4, Color(0xFFADD8E6));
        // Nose
        drawPixel(10, 7, pink); drawPixel(11, 7, pink); drawPixel(12, 7, pink);
        drawPixel(11, 8, pink);
        // Whisker dots
        drawPixel(5, 7, darkColor); drawPixel(6, 7, darkColor);
        drawPixel(16, 7, darkColor); drawPixel(17, 7, darkColor);
        // Body
        for (int x = 4; x <= 18; x++) drawPixel(x, 9, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 10, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 11, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 12, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 13, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 14, mainColor);
        // Belly (lighter)
        for (int x = 7; x <= 15; x++) drawPixel(x, 10, lightColor);
        for (int x = 7; x <= 15; x++) drawPixel(x, 11, lightColor);
        for (int x = 8; x <= 14; x++) drawPixel(x, 12, lightColor);
        // Legs (animated)
        if (frame == 0) {
          for (int y = 15; y <= 18; y++) { drawPixel(5, y, mainColor); drawPixel(6, y, mainColor); }
          for (int y = 15; y <= 18; y++) { drawPixel(16, y, mainColor); drawPixel(17, y, mainColor); }
          drawPixel(5, 19, darkColor); drawPixel(6, 19, darkColor);
          drawPixel(16, 19, darkColor); drawPixel(17, 19, darkColor);
        } else {
          for (int y = 15; y <= 18; y++) { drawPixel(6, y, mainColor); drawPixel(7, y, mainColor); }
          for (int y = 15; y <= 18; y++) { drawPixel(15, y, mainColor); drawPixel(16, y, mainColor); }
          drawPixel(6, 19, darkColor); drawPixel(7, 19, darkColor);
          drawPixel(15, 19, darkColor); drawPixel(16, 19, darkColor);
        }
        // Tail (curved up)
        for (int y = 10; y <= 12; y++) drawPixel(20, y, mainColor);
        drawPixel(21, 9, mainColor); drawPixel(21, 10, mainColor);
        drawPixel(22, 7, mainColor); drawPixel(22, 8, mainColor);
        drawPixel(23, 6, mainColor);
        break;

      case PixelAnimal.bird:
        const yellow = Colors.amber;
        // Crest/head feathers - 24x24
        for (int x = 14; x <= 17; x++) drawPixel(x, 0, mainColor);
        for (int x = 13; x <= 17; x++) drawPixel(x, 1, mainColor);
        for (int x = 12; x <= 16; x++) drawPixel(x, 2, mainColor);
        // Head
        for (int x = 10; x <= 17; x++) drawPixel(x, 3, mainColor);
        for (int x = 9; x <= 17; x++) drawPixel(x, 4, mainColor);
        for (int x = 9; x <= 16; x++) drawPixel(x, 5, mainColor);
        for (int x = 8; x <= 15; x++) drawPixel(x, 6, mainColor);
        // Eye
        drawPixel(14, 4, white); drawPixel(15, 4, white);
        drawPixel(14, 5, white); drawPixel(15, 5, white);
        drawPixel(15, 5, black);
        // Eye shine
        drawPixel(14, 4, Color(0xFFADD8E6));
        // Beak
        for (int x = 18; x <= 21; x++) drawPixel(x, 4, yellow);
        for (int x = 18; x <= 22; x++) drawPixel(x, 5, yellow);
        for (int x = 18; x <= 21; x++) drawPixel(x, 6, yellow);
        drawPixel(23, 5, yellow);
        // Body
        for (int x = 5; x <= 15; x++) drawPixel(x, 7, mainColor);
        for (int x = 4; x <= 14; x++) drawPixel(x, 8, mainColor);
        for (int x = 4; x <= 13; x++) drawPixel(x, 9, mainColor);
        for (int x = 4; x <= 12; x++) drawPixel(x, 10, mainColor);
        for (int x = 5; x <= 11; x++) drawPixel(x, 11, mainColor);
        // Belly (lighter)
        for (int x = 8; x <= 12; x++) drawPixel(x, 8, lightColor);
        for (int x = 7; x <= 11; x++) drawPixel(x, 9, lightColor);
        for (int x = 6; x <= 10; x++) drawPixel(x, 10, lightColor);
        // Wing (animated)
        if (frame == 0) {
          // Wing up
          for (int x = 0; x <= 5; x++) drawPixel(x, 2, darkColor);
          for (int x = 0; x <= 6; x++) drawPixel(x, 3, mainColor);
          for (int x = 1; x <= 7; x++) drawPixel(x, 4, mainColor);
          for (int x = 2; x <= 7; x++) drawPixel(x, 5, mainColor);
          drawPixel(0, 1, darkColor); drawPixel(1, 1, darkColor);
        } else {
          // Wing down
          for (int x = 2; x <= 5; x++) drawPixel(x, 10, darkColor);
          for (int x = 1; x <= 6; x++) drawPixel(x, 11, mainColor);
          for (int x = 0; x <= 5; x++) drawPixel(x, 12, mainColor);
          drawPixel(0, 13, darkColor); drawPixel(1, 13, darkColor);
        }
        // Tail feathers
        drawPixel(1, 9, darkColor); drawPixel(2, 9, mainColor);
        drawPixel(0, 10, darkColor); drawPixel(1, 10, darkColor);
        drawPixel(0, 11, darkColor);
        // Legs
        for (int y = 12; y <= 15; y++) { drawPixel(7, y, yellow); drawPixel(8, y, yellow); }
        drawPixel(6, 16, yellow); drawPixel(7, 16, yellow); drawPixel(8, 16, yellow); drawPixel(9, 16, yellow);
        for (int y = 12; y <= 15; y++) { drawPixel(10, y, yellow); drawPixel(11, y, yellow); }
        drawPixel(9, 16, yellow); drawPixel(10, 16, yellow); drawPixel(11, 16, yellow); drawPixel(12, 16, yellow);
        break;

      case PixelAnimal.monkey:
        const skinColor = Color(0xFFDEB887); // Tan/skin
        const darkBrown = Color(0xFF5D4037);
        // Ears - 24x24
        drawPixel(2, 4, skinColor); drawPixel(2, 5, skinColor); drawPixel(2, 6, skinColor);
        drawPixel(19, 4, skinColor); drawPixel(19, 5, skinColor); drawPixel(19, 6, skinColor);
        // Head (fur)
        for (int x = 5; x <= 16; x++) drawPixel(x, 1, mainColor);
        for (int x = 4; x <= 17; x++) drawPixel(x, 2, mainColor);
        for (int x = 3; x <= 18; x++) drawPixel(x, 3, mainColor);
        drawPixel(3, 4, mainColor); drawPixel(3, 5, mainColor); drawPixel(3, 6, mainColor);
        drawPixel(18, 4, mainColor); drawPixel(18, 5, mainColor); drawPixel(18, 6, mainColor);
        for (int x = 4; x <= 17; x++) drawPixel(x, 7, mainColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 8, mainColor);
        // Face (skin)
        for (int x = 5; x <= 16; x++) drawPixel(x, 4, skinColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 5, skinColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 6, skinColor);
        for (int x = 6; x <= 15; x++) drawPixel(x, 7, skinColor);
        // Eyes
        for (int y = 4; y <= 5; y++) { drawPixel(6, y, white); drawPixel(7, y, white); drawPixel(8, y, white); }
        for (int y = 4; y <= 5; y++) { drawPixel(13, y, white); drawPixel(14, y, white); drawPixel(15, y, white); }
        drawPixel(7, 5, black); drawPixel(8, 5, black);
        drawPixel(13, 5, black); drawPixel(14, 5, black);
        // Nose & mouth
        drawPixel(9, 6, darkBrown); drawPixel(10, 6, darkBrown); drawPixel(11, 6, darkBrown); drawPixel(12, 6, darkBrown);
        drawPixel(10, 7, darkBrown); drawPixel(11, 7, darkBrown);
        // Body
        for (int x = 6; x <= 15; x++) drawPixel(x, 9, mainColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 10, mainColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 11, mainColor);
        for (int x = 5; x <= 16; x++) drawPixel(x, 12, mainColor);
        for (int x = 6; x <= 15; x++) drawPixel(x, 13, mainColor);
        // Belly
        for (int x = 8; x <= 13; x++) drawPixel(x, 10, skinColor);
        for (int x = 8; x <= 13; x++) drawPixel(x, 11, skinColor);
        for (int x = 9; x <= 12; x++) drawPixel(x, 12, skinColor);
        // Arms (animated)
        if (frame == 0) {
          drawPixel(4, 9, mainColor); drawPixel(3, 8, mainColor); drawPixel(2, 7, mainColor); drawPixel(1, 6, skinColor); drawPixel(0, 5, skinColor);
          drawPixel(17, 9, mainColor); drawPixel(18, 8, mainColor); drawPixel(19, 7, mainColor); drawPixel(20, 6, skinColor); drawPixel(21, 5, skinColor);
        } else {
          drawPixel(4, 11, mainColor); drawPixel(3, 12, mainColor); drawPixel(2, 13, mainColor); drawPixel(1, 14, skinColor); drawPixel(0, 15, skinColor);
          drawPixel(17, 11, mainColor); drawPixel(18, 12, mainColor); drawPixel(19, 13, mainColor); drawPixel(20, 14, skinColor); drawPixel(21, 15, skinColor);
        }
        // Legs
        for (int y = 14; y <= 18; y++) { drawPixel(7, y, mainColor); drawPixel(8, y, mainColor); }
        drawPixel(7, 19, skinColor); drawPixel(8, 19, skinColor);
        for (int y = 14; y <= 18; y++) { drawPixel(13, y, mainColor); drawPixel(14, y, mainColor); }
        drawPixel(13, 19, skinColor); drawPixel(14, 19, skinColor);
        // Tail (curled)
        drawPixel(17, 13, mainColor); drawPixel(18, 13, mainColor);
        drawPixel(19, 12, mainColor); drawPixel(20, 12, mainColor);
        drawPixel(21, 13, mainColor); drawPixel(22, 14, mainColor);
        drawPixel(22, 15, mainColor); drawPixel(21, 16, mainColor);
        drawPixel(20, 17, mainColor);
        break;

      case PixelAnimal.eagle:
        const whiteEagle = Colors.white;
        const yellowBeak = Color(0xFFFFD600);
        const darkWing = Color(0xFF3E2723);
        // White head - 24x24
        for (int x = 13; x <= 18; x++) drawPixel(x, 0, whiteEagle);
        for (int x = 12; x <= 19; x++) drawPixel(x, 1, whiteEagle);
        for (int x = 12; x <= 20; x++) drawPixel(x, 2, whiteEagle);
        for (int x = 12; x <= 19; x++) drawPixel(x, 3, whiteEagle);
        for (int x = 13; x <= 18; x++) drawPixel(x, 4, whiteEagle);
        // Eye
        drawPixel(16, 2, black); drawPixel(17, 2, black);
        drawPixel(16, 3, black);
        // Eye ring
        drawPixel(15, 2, Color(0xFFFFEB3B));
        // Hooked beak
        for (int x = 20; x <= 23; x++) drawPixel(x, 3, yellowBeak);
        for (int x = 20; x <= 22; x++) drawPixel(x, 4, yellowBeak);
        for (int x = 21; x <= 22; x++) drawPixel(x, 5, yellowBeak);
        drawPixel(22, 6, yellowBeak);
        // Body (brown)
        for (int x = 8; x <= 17; x++) drawPixel(x, 5, mainColor);
        for (int x = 7; x <= 16; x++) drawPixel(x, 6, mainColor);
        for (int x = 6; x <= 15; x++) drawPixel(x, 7, mainColor);
        for (int x = 6; x <= 14; x++) drawPixel(x, 8, mainColor);
        for (int x = 7; x <= 13; x++) drawPixel(x, 9, mainColor);
        for (int x = 8; x <= 12; x++) drawPixel(x, 10, mainColor);
        // Wings (animated - majestic wingspan)
        if (frame == 0) {
          // Wings up
          for (int x = 0; x <= 7; x++) drawPixel(x, 2, darkWing);
          for (int x = 0; x <= 8; x++) drawPixel(x, 3, mainColor);
          for (int x = 1; x <= 9; x++) drawPixel(x, 4, mainColor);
          for (int x = 2; x <= 8; x++) drawPixel(x, 5, mainColor);
          drawPixel(0, 0, darkWing); drawPixel(1, 0, darkWing); drawPixel(0, 1, darkWing); drawPixel(1, 1, darkWing);
          // Right side hint
          for (int x = 17; x <= 21; x++) drawPixel(x, 6, mainColor);
          drawPixel(20, 5, darkWing); drawPixel(21, 5, darkWing);
        } else {
          // Wings down
          for (int x = 0; x <= 7; x++) drawPixel(x, 8, darkWing);
          for (int x = 0; x <= 8; x++) drawPixel(x, 7, mainColor);
          for (int x = 1; x <= 8; x++) drawPixel(x, 6, mainColor);
          for (int x = 2; x <= 7; x++) drawPixel(x, 5, mainColor);
          drawPixel(0, 9, darkWing); drawPixel(1, 9, darkWing); drawPixel(0, 10, darkWing);
          // Right side
          for (int x = 15; x <= 21; x++) drawPixel(x, 9, mainColor);
          drawPixel(20, 10, darkWing); drawPixel(21, 10, darkWing);
        }
        // Tail feathers
        drawPixel(5, 9, mainColor); drawPixel(4, 10, darkWing); drawPixel(5, 10, mainColor);
        drawPixel(3, 11, darkWing); drawPixel(4, 11, darkWing); drawPixel(5, 11, mainColor);
        drawPixel(3, 12, darkWing); drawPixel(4, 12, darkWing);
        // Talons (yellow)
        for (int y = 11; y <= 14; y++) { drawPixel(9, y, yellowBeak); drawPixel(10, y, yellowBeak); }
        drawPixel(8, 15, yellowBeak); drawPixel(9, 15, yellowBeak); drawPixel(10, 15, yellowBeak); drawPixel(11, 15, yellowBeak);
        for (int y = 11; y <= 14; y++) { drawPixel(12, y, yellowBeak); drawPixel(13, y, yellowBeak); }
        drawPixel(11, 15, yellowBeak); drawPixel(12, 15, yellowBeak); drawPixel(13, 15, yellowBeak); drawPixel(14, 15, yellowBeak);
        break;

      case PixelAnimal.horse:
        const darkMane = Color(0xFF1A1A1A);
        // Ears - 24x24
        for (int x = 16; x <= 18; x++) drawPixel(x, 0, mainColor);
        for (int x = 15; x <= 19; x++) drawPixel(x, 1, mainColor);
        // Head
        for (int x = 14; x <= 20; x++) drawPixel(x, 2, mainColor);
        for (int x = 14; x <= 21; x++) drawPixel(x, 3, mainColor);
        for (int x = 15; x <= 22; x++) drawPixel(x, 4, mainColor);
        for (int x = 16; x <= 23; x++) drawPixel(x, 5, mainColor);
        for (int x = 17; x <= 23; x++) drawPixel(x, 6, mainColor);
        // Eye
        drawPixel(18, 3, white); drawPixel(19, 3, white);
        drawPixel(18, 4, white); drawPixel(19, 4, black);
        // Nostril
        drawPixel(22, 6, darkColor); drawPixel(23, 6, darkColor);
        // Mane (flowing)
        for (int y = 0; y <= 2; y++) { drawPixel(13, y, darkMane); drawPixel(14, y, darkMane); }
        for (int y = 2; y <= 4; y++) { drawPixel(11, y, darkMane); drawPixel(12, y, darkMane); drawPixel(13, y, darkMane); }
        for (int y = 4; y <= 6; y++) { drawPixel(9, y, darkMane); drawPixel(10, y, darkMane); drawPixel(11, y, darkMane); }
        for (int y = 6; y <= 7; y++) { drawPixel(8, y, darkMane); drawPixel(9, y, darkMane); }
        // Neck
        for (int x = 11; x <= 16; x++) drawPixel(x, 7, mainColor);
        for (int x = 10; x <= 15; x++) drawPixel(x, 8, mainColor);
        // Body
        for (int x = 5; x <= 16; x++) drawPixel(x, 9, mainColor);
        for (int x = 4; x <= 16; x++) drawPixel(x, 10, mainColor);
        for (int x = 4; x <= 15; x++) drawPixel(x, 11, mainColor);
        for (int x = 4; x <= 14; x++) drawPixel(x, 12, mainColor);
        for (int x = 5; x <= 13; x++) drawPixel(x, 13, mainColor);
        // Legs (animated)
        if (frame == 0) {
          // Running pose 1
          for (int y = 14; y <= 19; y++) { drawPixel(5, y, mainColor); drawPixel(6, y, mainColor); }
          drawPixel(5, 20, darkColor); drawPixel(6, 20, darkColor);
          for (int y = 14; y <= 19; y++) { drawPixel(11, y, mainColor); drawPixel(12, y, mainColor); }
          drawPixel(11, 20, darkColor); drawPixel(12, 20, darkColor);
        } else {
          // Running pose 2
          for (int y = 14; y <= 19; y++) { drawPixel(6, y, mainColor); drawPixel(7, y, mainColor); }
          drawPixel(6, 20, darkColor); drawPixel(7, 20, darkColor);
          for (int y = 14; y <= 19; y++) { drawPixel(10, y, mainColor); drawPixel(11, y, mainColor); }
          drawPixel(10, 20, darkColor); drawPixel(11, 20, darkColor);
        }
        // Tail (flowing)
        drawPixel(2, 10, darkMane); drawPixel(3, 10, darkMane);
        drawPixel(1, 11, darkMane); drawPixel(2, 11, darkMane); drawPixel(3, 11, darkMane);
        drawPixel(0, 12, darkMane); drawPixel(1, 12, darkMane); drawPixel(2, 12, darkMane);
        if (frame == 0) {
          drawPixel(0, 13, darkMane); drawPixel(1, 13, darkMane);
          drawPixel(0, 14, darkMane);
        } else {
          drawPixel(1, 13, darkMane); drawPixel(2, 13, darkMane);
          drawPixel(1, 14, darkMane);
        }
        break;

      case PixelAnimal.rabbit:
        const pinkInner = Color(0xFFFFB6C1);
        // Long ears - 24x24
        for (int y = 0; y <= 5; y++) { drawPixel(7, y, mainColor); drawPixel(8, y, mainColor); drawPixel(9, y, mainColor); }
        for (int y = 0; y <= 5; y++) { drawPixel(13, y, mainColor); drawPixel(14, y, mainColor); drawPixel(15, y, mainColor); }
        // Inner ear pink
        for (int y = 1; y <= 4; y++) { drawPixel(8, y, pinkInner); drawPixel(14, y, pinkInner); }
        // Head
        for (int x = 6; x <= 16; x++) drawPixel(x, 6, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 7, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 8, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 9, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 10, mainColor);
        for (int x = 6; x <= 16; x++) drawPixel(x, 11, mainColor);
        // Eyes
        for (int y = 7; y <= 9; y++) { drawPixel(7, y, white); drawPixel(8, y, white); drawPixel(9, y, white); }
        for (int y = 7; y <= 9; y++) { drawPixel(13, y, white); drawPixel(14, y, white); drawPixel(15, y, white); }
        drawPixel(8, 8, black); drawPixel(9, 8, black);
        drawPixel(13, 8, black); drawPixel(14, 8, black);
        // Nose & mouth
        drawPixel(10, 9, pinkInner); drawPixel(11, 9, pinkInner); drawPixel(12, 9, pinkInner);
        drawPixel(10, 10, darkColor); drawPixel(11, 10, pinkInner); drawPixel(12, 10, darkColor);
        // Whiskers (dots)
        drawPixel(4, 9, darkColor); drawPixel(5, 9, darkColor);
        drawPixel(17, 9, darkColor); drawPixel(18, 9, darkColor);
        // Body
        for (int x = 6; x <= 16; x++) drawPixel(x, 12, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 13, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 14, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 15, mainColor);
        for (int x = 6; x <= 16; x++) drawPixel(x, 16, mainColor);
        // Fluffy tail
        for (int y = 14; y <= 16; y++) { drawPixel(18, y, white); drawPixel(19, y, white); drawPixel(20, y, white); }
        drawPixel(19, 13, white); drawPixel(19, 17, white);
        // Legs (hopping animation)
        if (frame == 0) {
          // Crouched
          for (int y = 17; y <= 18; y++) { drawPixel(6, y, mainColor); drawPixel(7, y, mainColor); drawPixel(8, y, mainColor); }
          for (int y = 17; y <= 18; y++) { drawPixel(14, y, mainColor); drawPixel(15, y, mainColor); drawPixel(16, y, mainColor); }
        } else {
          // Extended
          for (int y = 17; y <= 20; y++) { drawPixel(5, y, mainColor); drawPixel(6, y, mainColor); }
          for (int y = 17; y <= 20; y++) { drawPixel(16, y, mainColor); drawPixel(17, y, mainColor); }
        }
        break;

      case PixelAnimal.fox:
        const whiteChest = Colors.white;
        const blackNose = Colors.black;
        // Ears (pointed) - 24x24
        for (int y = 0; y <= 2; y++) { drawPixel(4, y, mainColor); drawPixel(5, y, mainColor); drawPixel(6, y, mainColor); }
        for (int y = 0; y <= 2; y++) { drawPixel(15, y, mainColor); drawPixel(16, y, mainColor); drawPixel(17, y, mainColor); }
        // Inner ear
        drawPixel(5, 1, darkColor); drawPixel(5, 2, darkColor);
        drawPixel(16, 1, darkColor); drawPixel(16, 2, darkColor);
        // Head
        for (int x = 5; x <= 17; x++) drawPixel(x, 3, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 4, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 5, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 6, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 7, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 8, mainColor);
        // White muzzle
        for (int x = 8; x <= 14; x++) drawPixel(x, 6, whiteChest);
        for (int x = 9; x <= 13; x++) drawPixel(x, 7, whiteChest);
        for (int x = 10; x <= 12; x++) drawPixel(x, 8, whiteChest);
        // Eyes
        for (int y = 4; y <= 5; y++) { drawPixel(6, y, white); drawPixel(7, y, white); drawPixel(8, y, white); }
        for (int y = 4; y <= 5; y++) { drawPixel(14, y, white); drawPixel(15, y, white); drawPixel(16, y, white); }
        drawPixel(7, 5, black); drawPixel(8, 5, black);
        drawPixel(14, 5, black); drawPixel(15, 5, black);
        // Eye shine
        drawPixel(6, 4, Color(0xFFADD8E6)); drawPixel(14, 4, Color(0xFFADD8E6));
        // Nose
        drawPixel(10, 6, blackNose); drawPixel(11, 6, blackNose); drawPixel(12, 6, blackNose);
        // Body
        for (int x = 5; x <= 17; x++) drawPixel(x, 9, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 10, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 11, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 12, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 13, mainColor);
        // White chest/belly
        for (int x = 8; x <= 14; x++) drawPixel(x, 9, whiteChest);
        for (int x = 8; x <= 14; x++) drawPixel(x, 10, whiteChest);
        for (int x = 9; x <= 13; x++) drawPixel(x, 11, whiteChest);
        for (int x = 10; x <= 12; x++) drawPixel(x, 12, whiteChest);
        // Legs
        if (frame == 0) {
          for (int y = 14; y <= 18; y++) { drawPixel(5, y, mainColor); drawPixel(6, y, mainColor); }
          drawPixel(5, 19, black); drawPixel(6, 19, black);
          for (int y = 14; y <= 18; y++) { drawPixel(15, y, mainColor); drawPixel(16, y, mainColor); }
          drawPixel(15, 19, black); drawPixel(16, 19, black);
        } else {
          for (int y = 14; y <= 18; y++) { drawPixel(6, y, mainColor); drawPixel(7, y, mainColor); }
          drawPixel(6, 19, black); drawPixel(7, 19, black);
          for (int y = 14; y <= 18; y++) { drawPixel(14, y, mainColor); drawPixel(15, y, mainColor); }
          drawPixel(14, 19, black); drawPixel(15, 19, black);
        }
        // Fluffy tail with white tip
        drawPixel(19, 10, mainColor); drawPixel(20, 9, mainColor); drawPixel(20, 10, mainColor);
        drawPixel(21, 8, mainColor); drawPixel(21, 9, mainColor); drawPixel(21, 10, mainColor);
        drawPixel(22, 7, mainColor); drawPixel(22, 8, mainColor);
        drawPixel(23, 6, whiteChest); drawPixel(23, 7, whiteChest); drawPixel(22, 9, whiteChest);
        break;

      case PixelAnimal.frog:
        const lightGreen = Color(0xFF90EE90);
        const frogYellow = Color(0xFFFFEB3B);
        // Big eyes (bulging) - 24x24
        for (int x = 4; x <= 8; x++) drawPixel(x, 0, mainColor);
        for (int x = 14; x <= 18; x++) drawPixel(x, 0, mainColor);
        for (int x = 3; x <= 9; x++) drawPixel(x, 1, mainColor);
        for (int x = 13; x <= 19; x++) drawPixel(x, 1, mainColor);
        // Eye whites and pupils
        for (int y = 0; y <= 1; y++) { drawPixel(5, y, white); drawPixel(6, y, white); drawPixel(7, y, white); }
        for (int y = 0; y <= 1; y++) { drawPixel(15, y, white); drawPixel(16, y, white); drawPixel(17, y, white); }
        drawPixel(6, 1, black); drawPixel(7, 1, black);
        drawPixel(15, 1, black); drawPixel(16, 1, black);
        // Head
        for (int x = 4; x <= 18; x++) drawPixel(x, 2, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 3, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 4, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 5, mainColor);
        // Mouth line
        for (int x = 6; x <= 16; x++) drawPixel(x, 5, darkColor);
        // Light belly on head
        for (int x = 7; x <= 15; x++) drawPixel(x, 4, lightGreen);
        // Body
        for (int x = 4; x <= 18; x++) drawPixel(x, 6, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 7, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 8, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 9, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 10, mainColor);
        // Yellow belly
        for (int x = 7; x <= 15; x++) drawPixel(x, 7, frogYellow);
        for (int x = 7; x <= 15; x++) drawPixel(x, 8, frogYellow);
        for (int x = 8; x <= 14; x++) drawPixel(x, 9, frogYellow);
        // Front legs
        drawPixel(2, 7, mainColor); drawPixel(1, 8, mainColor); drawPixel(0, 9, mainColor);
        drawPixel(20, 7, mainColor); drawPixel(21, 8, mainColor); drawPixel(22, 9, mainColor);
        // Back legs (jumping animation)
        if (frame == 0) {
          // Crouched
          drawPixel(3, 11, mainColor); drawPixel(2, 12, mainColor); drawPixel(1, 13, mainColor); drawPixel(0, 14, mainColor);
          drawPixel(19, 11, mainColor); drawPixel(20, 12, mainColor); drawPixel(21, 13, mainColor); drawPixel(22, 14, mainColor);
          // Webbed feet
          drawPixel(0, 15, mainColor); drawPixel(1, 15, mainColor); drawPixel(2, 15, mainColor);
          drawPixel(20, 15, mainColor); drawPixel(21, 15, mainColor); drawPixel(22, 15, mainColor);
        } else {
          // Extended jump
          drawPixel(2, 11, mainColor); drawPixel(1, 12, mainColor); drawPixel(0, 13, mainColor);
          drawPixel(0, 14, mainColor); drawPixel(0, 15, mainColor); drawPixel(0, 16, mainColor);
          drawPixel(20, 11, mainColor); drawPixel(21, 12, mainColor); drawPixel(22, 13, mainColor);
          drawPixel(22, 14, mainColor); drawPixel(22, 15, mainColor); drawPixel(22, 16, mainColor);
          // Webbed feet spread
          drawPixel(0, 17, mainColor); drawPixel(1, 17, mainColor); drawPixel(2, 17, mainColor);
          drawPixel(20, 17, mainColor); drawPixel(21, 17, mainColor); drawPixel(22, 17, mainColor);
        }
        break;

      case PixelAnimal.owl:
        const cream = Color(0xFFFFF8DC);
        const darkBrown = Color(0xFF3E2723);
        const owlYellow = Color(0xFFFFD700);
        // Ear tufts - 24x24
        for (int y = 0; y <= 2; y++) { drawPixel(4, y, mainColor); drawPixel(5, y, mainColor); }
        for (int y = 0; y <= 2; y++) { drawPixel(17, y, mainColor); drawPixel(18, y, mainColor); }
        drawPixel(6, 1, mainColor); drawPixel(6, 2, mainColor);
        drawPixel(16, 1, mainColor); drawPixel(16, 2, mainColor);
        // Head
        for (int x = 5; x <= 17; x++) drawPixel(x, 3, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 4, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 5, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 6, mainColor);
        for (int x = 3; x <= 19; x++) drawPixel(x, 7, mainColor);
        for (int x = 4; x <= 18; x++) drawPixel(x, 8, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 9, mainColor);
        // Facial disc (lighter)
        for (int x = 5; x <= 9; x++) { drawPixel(x, 5, cream); drawPixel(x, 6, cream); }
        for (int x = 13; x <= 17; x++) { drawPixel(x, 5, cream); drawPixel(x, 6, cream); }
        // Big eyes
        for (int y = 5; y <= 7; y++) { drawPixel(6, y, white); drawPixel(7, y, white); drawPixel(8, y, white); drawPixel(9, y, white); }
        for (int y = 5; y <= 7; y++) { drawPixel(13, y, white); drawPixel(14, y, white); drawPixel(15, y, white); drawPixel(16, y, white); }
        // Yellow iris
        drawPixel(7, 6, owlYellow); drawPixel(8, 6, owlYellow);
        drawPixel(14, 6, owlYellow); drawPixel(15, 6, owlYellow);
        // Pupils
        drawPixel(8, 6, black); drawPixel(14, 6, black);
        // Beak
        drawPixel(10, 7, darkBrown); drawPixel(11, 7, darkBrown); drawPixel(12, 7, darkBrown);
        drawPixel(11, 8, darkBrown);
        // Body
        for (int x = 6; x <= 16; x++) drawPixel(x, 10, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 11, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 12, mainColor);
        for (int x = 5; x <= 17; x++) drawPixel(x, 13, mainColor);
        for (int x = 6; x <= 16; x++) drawPixel(x, 14, mainColor);
        // Chest pattern
        for (int x = 8; x <= 14; x++) drawPixel(x, 10, cream);
        for (int x = 8; x <= 14; x++) drawPixel(x, 11, cream);
        for (int x = 9; x <= 13; x++) drawPixel(x, 12, cream);
        for (int x = 10; x <= 12; x++) drawPixel(x, 13, cream);
        // Chest spots
        drawPixel(9, 11, mainColor); drawPixel(11, 11, mainColor); drawPixel(13, 11, mainColor);
        drawPixel(10, 12, mainColor); drawPixel(12, 12, mainColor);
        // Wings (animated)
        if (frame == 0) {
          // Wings tucked
          for (int y = 10; y <= 13; y++) { drawPixel(4, y, darkBrown); drawPixel(5, y, mainColor); }
          for (int y = 10; y <= 13; y++) { drawPixel(17, y, mainColor); drawPixel(18, y, darkBrown); }
        } else {
          // Wings spread
          for (int y = 8; y <= 11; y++) { drawPixel(2, y, darkBrown); drawPixel(3, y, mainColor); }
          drawPixel(1, 7, darkBrown); drawPixel(0, 6, darkBrown); drawPixel(1, 8, mainColor); drawPixel(0, 7, mainColor);
          for (int y = 8; y <= 11; y++) { drawPixel(19, y, mainColor); drawPixel(20, y, darkBrown); }
          drawPixel(21, 7, darkBrown); drawPixel(22, 6, darkBrown); drawPixel(21, 8, mainColor); drawPixel(22, 7, mainColor);
        }
        // Feet/talons
        for (int y = 15; y <= 17; y++) { drawPixel(8, y, darkBrown); drawPixel(9, y, darkBrown); }
        for (int y = 15; y <= 17; y++) { drawPixel(13, y, darkBrown); drawPixel(14, y, darkBrown); }
        drawPixel(7, 18, darkBrown); drawPixel(8, 18, darkBrown); drawPixel(9, 18, darkBrown); drawPixel(10, 18, darkBrown);
        drawPixel(12, 18, darkBrown); drawPixel(13, 18, darkBrown); drawPixel(14, 18, darkBrown); drawPixel(15, 18, darkBrown);
        break;

      case PixelAnimal.penguin:
        const penguinWhite = Colors.white;
        const penguinOrange = Color(0xFFFF8C00);
        const penguinBlack = Colors.black;
        // Head (black) - 24x24
        for (int x = 8; x <= 14; x++) drawPixel(x, 0, penguinBlack);
        for (int x = 6; x <= 16; x++) drawPixel(x, 1, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 2, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 3, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 4, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 5, penguinBlack);
        for (int x = 6; x <= 16; x++) drawPixel(x, 6, penguinBlack);
        // White face patch
        for (int x = 8; x <= 14; x++) drawPixel(x, 3, penguinWhite);
        for (int x = 8; x <= 14; x++) drawPixel(x, 4, penguinWhite);
        for (int x = 9; x <= 13; x++) drawPixel(x, 5, penguinWhite);
        // Eyes
        drawPixel(9, 3, penguinBlack); drawPixel(10, 3, penguinBlack);
        drawPixel(12, 3, penguinBlack); drawPixel(13, 3, penguinBlack);
        // Eye shine
        drawPixel(9, 3, Color(0xFF4169E1));
        drawPixel(13, 3, Color(0xFF4169E1));
        // Beak
        drawPixel(10, 5, penguinOrange); drawPixel(11, 5, penguinOrange); drawPixel(12, 5, penguinOrange);
        drawPixel(10, 6, penguinOrange); drawPixel(11, 6, penguinOrange); drawPixel(12, 6, penguinOrange);
        // Body
        for (int x = 6; x <= 16; x++) drawPixel(x, 7, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 8, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 9, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 10, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 11, penguinBlack);
        for (int x = 5; x <= 17; x++) drawPixel(x, 12, penguinBlack);
        for (int x = 6; x <= 16; x++) drawPixel(x, 13, penguinBlack);
        for (int x = 7; x <= 15; x++) drawPixel(x, 14, penguinBlack);
        // White belly
        for (int x = 8; x <= 14; x++) drawPixel(x, 7, penguinWhite);
        for (int x = 7; x <= 15; x++) drawPixel(x, 8, penguinWhite);
        for (int x = 7; x <= 15; x++) drawPixel(x, 9, penguinWhite);
        for (int x = 7; x <= 15; x++) drawPixel(x, 10, penguinWhite);
        for (int x = 7; x <= 15; x++) drawPixel(x, 11, penguinWhite);
        for (int x = 8; x <= 14; x++) drawPixel(x, 12, penguinWhite);
        for (int x = 9; x <= 13; x++) drawPixel(x, 13, penguinWhite);
        // Flippers (animated - waddling)
        if (frame == 0) {
          // Flippers out
          for (int y = 8; y <= 12; y++) { drawPixel(3, y, penguinBlack); drawPixel(4, y, penguinBlack); }
          for (int y = 8; y <= 12; y++) { drawPixel(18, y, penguinBlack); drawPixel(19, y, penguinBlack); }
          drawPixel(2, 10, penguinBlack); drawPixel(2, 11, penguinBlack);
          drawPixel(20, 10, penguinBlack); drawPixel(20, 11, penguinBlack);
        } else {
          // Flippers down
          for (int y = 9; y <= 14; y++) { drawPixel(4, y, penguinBlack); drawPixel(5, y, penguinBlack); }
          for (int y = 9; y <= 14; y++) { drawPixel(17, y, penguinBlack); drawPixel(18, y, penguinBlack); }
          drawPixel(3, 13, penguinBlack); drawPixel(3, 14, penguinBlack);
          drawPixel(19, 13, penguinBlack); drawPixel(19, 14, penguinBlack);
        }
        // Feet
        for (int x = 8; x <= 10; x++) { drawPixel(x, 15, penguinOrange); drawPixel(x, 16, penguinOrange); }
        for (int x = 12; x <= 14; x++) { drawPixel(x, 15, penguinOrange); drawPixel(x, 16, penguinOrange); }
        drawPixel(7, 17, penguinOrange); drawPixel(8, 17, penguinOrange); drawPixel(9, 17, penguinOrange); drawPixel(10, 17, penguinOrange); drawPixel(11, 17, penguinOrange);
        drawPixel(11, 17, penguinOrange); drawPixel(12, 17, penguinOrange); drawPixel(13, 17, penguinOrange); drawPixel(14, 17, penguinOrange); drawPixel(15, 17, penguinOrange);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PixelAnimalPainter oldDelegate) {
    return oldDelegate.frame != frame || oldDelegate.facingRight != facingRight;
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  
  // Easter egg variables
  Timer? _easterEggTimer;
  bool _showAnimal = false;
  PixelAnimal _currentAnimal = PixelAnimal.cat;
  Color _animalColor = Colors.orange;
  late AnimationController _jumpController;
  late AnimationController _frameController;
  final Random _random = Random();
  
  // Jump positions (will be calculated based on screen)
  List<Offset> _jumpPositions = [];
  int _currentJumpIndex = 0;
  bool _facingRight = true;
  
  // Animal colors
  final Map<PixelAnimal, Color> _animalColors = {
    PixelAnimal.cat: Colors.orange,
    PixelAnimal.bird: Colors.blue,
    PixelAnimal.monkey: Colors.brown,
    PixelAnimal.eagle: Colors.amber.shade800,
    PixelAnimal.horse: Colors.brown.shade700,
    PixelAnimal.rabbit: Colors.grey.shade400,
    PixelAnimal.fox: Colors.deepOrange,
    PixelAnimal.frog: Colors.green,
    PixelAnimal.owl: Colors.brown.shade600,
    PixelAnimal.penguin: Color(0xFF1C1C1C), // Dark color - penguin uses its own black/white
  };

  @override
  void initState() {
    super.initState();
    _initEasterEgg();
  }

  void _initEasterEgg() {
    // Main jump animation controller - 3 seconds total
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Frame animation for walking/flying animation
    _frameController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat(reverse: true);
    
    _jumpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showAnimal = false;
        });
      }
    });
    
    // Start the 20-second timer for the easter egg
    _easterEggTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _triggerEasterEgg();
    });
    
    // Trigger first one after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _triggerEasterEgg();
    });
  }

  void _triggerEasterEgg() {
    if (!mounted) return;
    
    // Random animal
    final animals = PixelAnimal.values;
    _currentAnimal = animals[_random.nextInt(animals.length)];
    _animalColor = _animalColors[_currentAnimal] ?? Colors.orange;
    
    // Generate jump positions based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Randomly choose entry direction (left or right)
    final enterFromLeft = _random.nextBool();
    
    // Generate random jump points across the screen that work on any tab
    final List<Offset> middleJumps = [];
    final numJumps = 4 + _random.nextInt(3); // 4-6 jumps
    
    for (int i = 0; i < numJumps; i++) {
      middleJumps.add(Offset(
        screenWidth * (0.1 + _random.nextDouble() * 0.8), // 10% to 90% of width
        screenHeight * (0.1 + _random.nextDouble() * 0.6), // 10% to 70% of height
      ));
    }
    
    // Sort by x position for more natural movement
    if (enterFromLeft) {
      middleJumps.sort((a, b) => a.dx.compareTo(b.dx));
    } else {
      middleJumps.sort((a, b) => b.dx.compareTo(a.dx));
    }
    
    // Create full jump path with entry and exit
    _jumpPositions = [
      // Start off-screen
      Offset(enterFromLeft ? -50 : screenWidth + 50, screenHeight * (0.2 + _random.nextDouble() * 0.3)),
      // Jump through random positions
      ...middleJumps,
      // Exit off-screen (opposite side)
      Offset(enterFromLeft ? screenWidth + 50 : -50, screenHeight * (0.2 + _random.nextDouble() * 0.3)),
    ];
    
    _currentJumpIndex = 0;
    _facingRight = enterFromLeft;
    
    setState(() {
      _showAnimal = true;
    });
    
    _jumpController.reset();
    _jumpController.forward();
  }

  Offset _getCurrentPosition(double progress) {
    if (_jumpPositions.isEmpty) return Offset.zero;
    
    final totalJumps = _jumpPositions.length - 1;
    final jumpProgress = progress * totalJumps;
    final currentJump = jumpProgress.floor().clamp(0, totalJumps - 1);
    final jumpFraction = jumpProgress - currentJump;
    
    final start = _jumpPositions[currentJump];
    final end = _jumpPositions[(currentJump + 1).clamp(0, _jumpPositions.length - 1)];
    
    // Update facing direction
    if (end.dx > start.dx) {
      _facingRight = true;
    } else if (end.dx < start.dx) {
      _facingRight = false;
    }
    
    // Interpolate position with arc (parabolic jump)
    final x = start.dx + (end.dx - start.dx) * jumpFraction;
    final baseY = start.dy + (end.dy - start.dy) * jumpFraction;
    // Add arc - highest at middle of jump
    final arcHeight = -80 * sin(jumpFraction * pi);
    final y = baseY + arcHeight;
    
    return Offset(x, y);
  }

  @override
  void dispose() {
    _easterEggTimer?.cancel();
    _jumpController.dispose();
    _frameController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          screens[_currentIndex],
          // Easter egg pixelated animal overlay - IgnorePointer lets touches pass through
          if (_showAnimal)
            AnimatedBuilder(
              animation: Listenable.merge([_jumpController, _frameController]),
              builder: (context, child) {
                final position = _getCurrentPosition(_jumpController.value);
                final frame = (_frameController.value > 0.5) ? 1 : 0;
                
                return Positioned(
                  left: position.dx - 24,
                  top: position.dy - 24,
                  child: IgnorePointer(
                    child: CustomPaint(
                      size: const Size(48, 48),
                      painter: PixelAnimalPainter(
                        animal: _currentAnimal,
                        color: _animalColor,
                        facingRight: _facingRight,
                        frame: frame,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
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
    
    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) return;
    
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
    _getNote(date).then((existingNote) {
      if (!mounted) return;
      String noteText = existingNote ?? '';
      final hasExistingNote = existingNote != null && existingNote.isNotEmpty;
      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Note for ${date.day}/${date.month}/${date.year}'),
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
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                if (hasExistingNote)
                  TextButton(
                    onPressed: () async {
                      await _saveNote(date, '');
                      setState(() {});
                      if (mounted) Navigator.pop(dialogContext);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () async {
                    await _saveNote(date, noteText);
                    setState(() {});
                    if (mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
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
                // Check if it's an off day (white/light color) to use black text
                bool isOffDay = color == Colors.white || color.computeLuminance() > 0.7;
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
                            color: isOffDay ? Colors.grey.shade300 : color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isOffDay ? Colors.grey.shade600 : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: isOffDay ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                bool isOffDay = color == Colors.white || color.computeLuminance() > 0.7;
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
                            color: isOffDay ? Colors.grey.shade200 : color.withValues(alpha: 0.5),
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
                  Builder(
                    builder: (context) {
                      final todayColor = getDutyColor(DateTime.now(), selectedShift);
                      final isOffDay = todayColor == Colors.white || todayColor.computeLuminance() > 0.7;
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isOffDay 
                              ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100)
                              : todayColor.withValues(alpha: 0.2),
                          border: Border.all(
                            color: isOffDay 
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : todayColor,
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
                                color: isOffDay 
                                    ? (isDarkMode ? Colors.white : Colors.black)
                                    : todayColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getDuty(DateTime.now(), selectedShift),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Selected Day Duty Card
                  if (selectedDay != null && !isSameDay(selectedDay, DateTime.now()))
                    Builder(
                      builder: (context) {
                        final selectedColor = getDutyColor(selectedDay!, selectedShift);
                        final isOffDay = selectedColor == Colors.white || selectedColor.computeLuminance() > 0.7;
                        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isOffDay 
                                ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100)
                                : selectedColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: isOffDay 
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : selectedColor.withValues(alpha: 0.6),
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
                                  color: isOffDay 
                                      ? (isDarkMode ? Colors.white : Colors.black)
                                      : selectedColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getDuty(selectedDay!, selectedShift),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
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
  
  // Notification setting
  bool _notificationsEnabled = true;

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
      
      // Load notification setting
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
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
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text(
              'A reminder will be sent 1 hour before shift and 2 hours after shift',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('notifications_enabled', value);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value 
                    ? 'Notifications enabled' 
                    : 'Notifications disabled'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Customize Shift Colors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Morning shift color
          ListTile(
            title: const Text('Morning Shift'),
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
            title: const Text('Evening Shift'),
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
            title: const Text('Night Shift'),
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
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Reset app to default settings'),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will reset the app to its default settings and delete:\n\n'
          '• All saved notes\n'
          '• Custom shift colors\n'
          '• Shift pattern settings\n'
          '• Shift hours\n'
          '• Vacation records\n'
          '• Time clock records\n'
          '• All preferences\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    // Clear all SharedPreferences data
    await _prefs.clear();
    
    // Reset to default values - use ARGB format matching _saveColor method
    await _prefs.setString('color_morning', _colorToArgbString(Colors.blue));
    await _prefs.setString('color_evening', _colorToArgbString(Colors.orange));
    await _prefs.setString('color_night', _colorToArgbString(Colors.black));
    await _prefs.setString('shift_pattern', '0,1,2,3,3');
    await _prefs.setString('morning_start', '7:00 AM');
    await _prefs.setString('morning_end', '3:00 PM');
    await _prefs.setString('evening_start', '3:00 PM');
    await _prefs.setString('evening_end', '11:00 PM');
    await _prefs.setString('night_start', '11:00 PM');
    await _prefs.setString('night_end', '7:00 AM');
    await _prefs.setString('cycle_start_date', '2026-02-01');
    await _prefs.setString('selectedShift', 'A');
    await _prefs.setBool('notifications_enabled', true);
    await _prefs.setString('theme_mode', 'system');
    
    // Reset theme to system
    widget.onThemeModeChanged(ThemeMode.system);
    
    // Reload settings
    await _loadSettings();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data cleared! App reset to defaults.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _colorToArgbString(Color color) {
    final a = (color.a * 255.0).round().clamp(0, 255);
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final argbInt = (a << 24) | (r << 16) | (g << 8) | b;
    return argbInt.toString();
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

  TimeOfDay _parseTimeString(String timeStr) {
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
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _editShiftHours(String shiftType) async {
    String startKey = '${shiftType}_start';
    String endKey = '${shiftType}_end';
    String startTimeStr = shiftHours[startKey] ?? '7:00 AM';
    String endTimeStr = shiftHours[endKey] ?? '3:00 PM';
    
    TimeOfDay startTime = _parseTimeString(startTimeStr);
    TimeOfDay endTime = _parseTimeString(endTimeStr);
    
    // Show start time picker
    final TimeOfDay? newStartTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Select Start Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (newStartTime == null || !mounted) return;
    
    // Show end time picker
    final TimeOfDay? newEndTime = await showTimePicker(
      context: context,
      initialTime: endTime,
      helpText: 'Select End Time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (newEndTime == null || !mounted) return;
    
    // Save the new times
    String newStartStr = _formatTimeOfDay(newStartTime);
    String newEndStr = _formatTimeOfDay(newEndTime);
    
    setState(() {
      shiftHours[startKey] = newStartStr;
      shiftHours[endKey] = newEndStr;
    });
    
    await _prefs.setString(startKey, newStartStr);
    await _prefs.setString(endKey, newEndStr);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shift hours saved!')),
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
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _vacationFirstDate; // For vacation range selection
  Map<String, String> _leaveRecords = {}; // date -> leave type
  LeaveType _selectedLeaveType = LeaveType.vacation;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  
  // Shift pattern data
  String _selectedShift = 'A';
  List<int> _shiftPattern = [0, 1, 2, 3, 3];
  DateTime _cycleStartDate = DateTime(2026, 2, 1);
  Map<String, Color> _shiftColors = {
    'morning': Colors.blue,
    'evening': Colors.orange,
    'night': Colors.black,
    'off': Colors.white,
  };
  Map<String, int> _shiftOffsets = {
    'A': 2,
    'B': 3,
    'C': 4,
    'D': 0,
    'F': 1,
  };

  @override
  void initState() {
    super.initState();
    _loadLeaveRecords();
    _loadShiftSettings();
  }

  Future<void> _loadShiftSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedShift = prefs.getString('selectedShift') ?? 'A';
      
      // Load shift pattern
      String? patternStr = prefs.getString('shift_pattern');
      if (patternStr != null) {
        _shiftPattern = patternStr.split(',').map((e) => int.parse(e)).toList();
      }
      
      // Load cycle start date
      String? dateStr = prefs.getString('cycle_start_date');
      if (dateStr != null) {
        _cycleStartDate = DateTime.parse(dateStr);
      }
      
      // Load custom colors
      String? morning = prefs.getString('color_morning');
      String? evening = prefs.getString('color_evening');
      String? night = prefs.getString('color_night');
      if (morning != null) _shiftColors['morning'] = Color(int.parse(morning));
      if (evening != null) _shiftColors['evening'] = Color(int.parse(evening));
      if (night != null) _shiftColors['night'] = Color(int.parse(night));
    });
  }

  int _getCycleDay(DateTime date) {
    int offset = _shiftOffsets[_selectedShift] ?? 0;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedCycleStart = DateTime(_cycleStartDate.year, _cycleStartDate.month, _cycleStartDate.day);
    int daysSince = normalizedDate.difference(normalizedCycleStart).inDays;
    int cycleLength = _shiftPattern.length;
    int cycle = (daysSince + offset) % cycleLength;
    if (cycle < 0) cycle += cycleLength;
    return cycle;
  }

  Color _getDutyColor(DateTime date) {
    int c = _getCycleDay(date);
    int dutyType = _shiftPattern[c];
    switch (dutyType) {
      case 0:
        return _shiftColors['morning']!;
      case 1:
        return _shiftColors['evening']!;
      case 2:
        return _shiftColors['night']!;
      default:
        return _shiftColors['off']!;
    }
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

  void _toggleSingleDay(DateTime day) {
    final dateKey = _formatDate(day);
    final leaveTypeStr = _selectedLeaveType.name;
    
    // For vacation, support range selection with two taps
    if (_selectedLeaveType == LeaveType.vacation) {
      if (_vacationFirstDate == null) {
        // First tap - mark as start of range or toggle if already has leave
        if (_leaveRecords.containsKey(dateKey)) {
          setState(() {
            _leaveRecords.remove(dateKey);
          });
          _saveLeaveRecords();
        } else {
          setState(() {
            _vacationFirstDate = day;
            _leaveRecords[dateKey] = leaveTypeStr;
          });
          _saveLeaveRecords();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap another date to fill range, or tap same date again to confirm single day'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Second tap - fill range between first and second date
        DateTime start = _vacationFirstDate!.isBefore(day) ? _vacationFirstDate! : day;
        DateTime end = _vacationFirstDate!.isBefore(day) ? day : _vacationFirstDate!;
        
        DateTime current = start;
        while (!current.isAfter(end)) {
          final key = _formatDate(current);
          _leaveRecords[key] = leaveTypeStr;
          current = current.add(const Duration(days: 1));
        }
        
        final days = end.difference(start).inDays + 1;
        setState(() {
          _vacationFirstDate = null;
        });
        _saveLeaveRecords();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $days day(s) of Vacation'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // For sick leave and urgent - only single day toggle
      setState(() {
        if (_leaveRecords.containsKey(dateKey)) {
          _leaveRecords.remove(dateKey);
        } else {
          _leaveRecords[dateKey] = leaveTypeStr;
        }
      });
      _saveLeaveRecords();
    }
  }

  void _addLeaveRange(DateTime start, DateTime end) {
    final leaveTypeStr = _selectedLeaveType.name;
    DateTime current = start;
    
    while (!current.isAfter(end)) {
      final dateKey = _formatDate(current);
      _leaveRecords[dateKey] = leaveTypeStr;
      current = current.add(const Duration(days: 1));
    }
    
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
    });
    _saveLeaveRecords();
    
    final days = end.difference(start).inDays + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $days day(s) of ${_getLeaveLabel(leaveTypeStr)}'),
        duration: const Duration(seconds: 2),
      ),
    );
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedLeaveType == LeaveType.vacation
                        ? 'Tap 2 dates to fill range • Tap marked day to remove'
                        : 'Tap to add/remove single day',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Calendar with range selection
          Expanded(
            child: TableCalendar(
              firstDay: DateTime(2020, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                
                // When both start and end are selected, add leave for range immediately
                if (start != null && end != null) {
                  _addLeaveRange(start, end);
                } else {
                  setState(() {
                    _rangeStart = start;
                    _rangeEnd = end;
                  });
                }
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Single tap = toggle leave for that day
                setState(() {
                  _rangeStart = null;
                  _rangeEnd = null;
                  _focusedDay = focusedDay;
                });
                _toggleSingleDay(selectedDay);
              },
              calendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                rangeHighlightColor: _getLeaveColor(_selectedLeaveType.name).withValues(alpha: 0.3),
                rangeStartDecoration: BoxDecoration(
                  color: _getLeaveColor(_selectedLeaveType.name),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: _getLeaveColor(_selectedLeaveType.name),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final dateKey = _formatDate(day);
                  final leaveType = _leaveRecords[dateKey];
                  final dutyColor = _getDutyColor(day);
                  
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
                  // Show shift color for days without leave
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: dutyColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final dateKey = _formatDate(day);
                  final leaveType = _leaveRecords[dateKey];
                  final dutyColor = _getDutyColor(day);
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: leaveType != null ? _getLeaveColor(leaveType) : dutyColor.withValues(alpha: 0.3),
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
                              color: leaveType != null ? Colors.white : Colors.black,
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
          _vacationFirstDate = null; // Clear pending vacation range when switching types
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
    'A': 2,
    'B': 3,
    'C': 4,
    'D': 0,
    'F': 1,
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
    return dutyType != 3; // Not a rest day (off day)
  }

  List<MapEntry<String, String>> _getFilteredRecords() {
    return _leaveRecords.entries
        .where((entry) => entry.key.startsWith('$_selectedYear-'))
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // Sort by date descending
  }

  int _countByType(String type, {bool onlyPastDates = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _leaveRecords.entries
        .where((e) => e.key.startsWith('$_selectedYear-') && e.value == type)
        .where((e) {
          // Only count if it's a shift day (not an off day)
          try {
            final parts = e.key.split('-');
            final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
            
            // If onlyPastDates is true, exclude future dates
            if (onlyPastDates && date.isAfter(today)) {
              return false;
            }
            
            return _isShiftDay(date);
          } catch (_) {
            return false;
          }
        })
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
    // For display cards - show all counts for the year
    final vacationCount = _countByType('vacation');
    final sickCount = _countByType('sickLeave');
    final urgentCount = _countByType('urgent');
    
    // For actual worked calculation - only count past/today absences (excluding vacation)
    final sickCountPast = _countByType('sickLeave', onlyPastDates: true);
    final urgentCountPast = _countByType('urgent', onlyPastDates: true);
    final absencesForWorked = sickCountPast + urgentCountPast; // Don't count vacation as absence from work
    
    final totalAbsences = vacationCount + sickCount + urgentCount;
    final totalScheduled = _getTotalScheduledShiftDays();
    final actualWorked = totalScheduled - absencesForWorked;
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
                      '$totalScheduled scheduled - $totalAbsences absences on work days',
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
                      'Only excludes off days from shift pattern',
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


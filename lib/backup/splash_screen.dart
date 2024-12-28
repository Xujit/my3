import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_list_screen.dart';
import 'profile_setup_screen.dart';


class SplashScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const SplashScreen({super.key, required this.onThemeChanged});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isProfileCompleted = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isCompleted = prefs.getBool('isProfileCompleted') ?? false;

    setState(() {
      _isProfileCompleted = isCompleted;
    });

    // Navigate to appropriate screen
    Future.delayed(Duration(seconds: 2), () {
      if (isCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserListScreen(
            onThemeChanged: (ThemeMode themeMode) {
              if (!mounted) return;
              setState(() {
                _themeMode = themeMode;
              });
            },
          )),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupScreen(
            onThemeChanged: (ThemeMode themeMode) {
              if (!mounted) return;
              setState(() {
                _themeMode = themeMode;
              });
            },
          )),
        );
      }
    });
  }

  @override
  void dispose() {
   // _controller.dispose(); // Example: Dispose controllers if used
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

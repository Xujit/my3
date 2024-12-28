import 'package:flutter/material.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: My3App(),
    ),
  );
}

class My3App extends StatefulWidget {
  const My3App({super.key});

  @override
  My3AppState createState() => My3AppState();
}

class My3AppState extends State<My3App> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        onThemeChanged: (ThemeMode themeMode) {
          setState(() {
            _themeMode = themeMode;
          });
        },
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(color: Colors.grey.shade800),
      ),
      themeMode: _themeMode,
    );
  }
}




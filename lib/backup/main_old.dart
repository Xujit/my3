import 'package:flutter/material.dart';
import 'user_list_screen1.dart'; // Import the UserListScreen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User List App',
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
      themeMode: ThemeMode.system, // You can adjust this to `ThemeMode.dark` or `ThemeMode.light` for testing.
      home: UserListScreen(), // Set UserListScreen as the main screen
    );
  }
}

import 'package:flutter/material.dart';
import 'backup/user_search_delegate.dart';

class AppBarActions extends StatelessWidget {
  final Function onThemeChanged;
  final Function onSearch;
  final Function onSync;

  const AppBarActions({
    Key? key,
    required this.onThemeChanged,
    required this.onSearch,
    required this.onSync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.sync),
          tooltip: "Sync Data",
          onPressed: onSync(),
        ),
        IconButton(
          icon: Icon(Icons.search),
          tooltip: "Search Users",
          onPressed: () => onSearch(),
        ),
        PopupMenuButton<ThemeMode>(
          onSelected: (themeMode) => onThemeChanged(themeMode),
          icon: Icon(Icons.brightness_6),
          itemBuilder: (context) => [
            PopupMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
            PopupMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
            PopupMenuItem(value: ThemeMode.system, child: Text('System Default')),
          ],
        ),
      ],
    );
  }
}

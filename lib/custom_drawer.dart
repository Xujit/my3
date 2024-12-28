import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final dynamic loggedInUser;
  final Function onEditProfile;
  final Function onNavigateTo;

  const CustomDrawer({
    Key? key,
    required this.loggedInUser,
    required this.onEditProfile,
    required this.onNavigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade200, Colors.purple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(loggedInUser['name'], style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.0),
                Text(loggedInUser['phone'], style: TextStyle(color: Colors.white70, fontSize: 14.0)),
                SizedBox(height: 4.0),
                Text(loggedInUser['email'], style: TextStyle(color: Colors.white70, fontSize: 14.0)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => onNavigateTo('home'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => onNavigateTo('settings'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () => onNavigateTo('about'),
          ),
        ],
      ),
    );
  }
}

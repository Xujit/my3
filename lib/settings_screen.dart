import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Tags',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: userProvider.predefinedTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    userProvider.removeTag(tag);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Add Tag',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_tagController.text.isNotEmpty) {
                  userProvider.addTag(_tagController.text);
                  _tagController.clear();
                  setState(() {});
                }
              },
              child: Text('Add Tag'),
            ),
          ],
        ),
      ),
    );
  }
}

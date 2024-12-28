import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class EditProfileScreen extends StatelessWidget {
  final Map<String, String> user;

  EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: user['name']);
    final phoneController = TextEditingController(text: user['phone']);
    final emailController = TextEditingController(text: user['email']);

    final userProvider = Provider.of<UserProvider>(context, listen: false);


    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Save updated profile to SharedPreferences
                await userProvider.updateUserProfile(
                  nameController.text,
                  phoneController.text,
                  emailController.text,
                );

                // Pop back to the previous screen
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

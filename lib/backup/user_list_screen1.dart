import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import the database helper class

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    List<Map<String, dynamic>> userList = await DatabaseHelper().fetchUsers();
    setState(() {
      users = userList;
    });
  }

  void _addUser(String name, String mobile, bool isFavorite, String tags, String comments) async {
    await DatabaseHelper().insertUser({
      'name': name,
      'mobile': mobile,
      'isFavorite': isFavorite ? 1 : 0,
      'tags': tags,
      'comments': comments,
    });
    _loadUsers(); // Refresh the list after adding
  }

  void _deleteUser(int id) async {
    await DatabaseHelper().deleteUser(id);
    _loadUsers(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          var user = users[index];
          return ListTile(
            title: Text(user['name']),
            subtitle: Text('Mobile: ${user['mobile']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteUser(user['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add user creation logic (e.g., show a form dialog)
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

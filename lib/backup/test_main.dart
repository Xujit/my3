import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> users = [
    {'name': 'John Doe', 'mobile': '1234567890', 'isFavorite': false, 'tags': ['Friend', 'Work']},
    {'name': 'Jane Smith', 'mobile': '9876543210', 'isFavorite': true, 'tags': ['Family']},
    {'name': 'Alice Johnson', 'mobile': '5556667778', 'isFavorite': false, 'tags': ['Work']},
    {'name': 'Bob Brown', 'mobile': '4445556667', 'isFavorite': true, 'tags': ['Gym']},
  ];

  String selectedFilter = 'All';

  List<String> predefinedTags = ['Friend', 'Work', 'Family', 'Gym'];
  List<String> combinedFilters = ['All', 'Favorites', ...['Friend', 'Work', 'Family', 'Gym']];

  List<Map<String, dynamic>> getFilteredUsers() {
    List<Map<String, dynamic>> filteredUsers = users;

    if (selectedFilter == 'Favorites') {
      filteredUsers = filteredUsers.where((user) => user['isFavorite']).toList();
    } else if (predefinedTags.contains(selectedFilter)) {
      filteredUsers = filteredUsers.where((user) => user['tags'].contains(selectedFilter)).toList();
    }

    return filteredUsers;
  }

  void toggleFavorite(int index) {
    setState(() {
      users[index]['isFavorite'] = !users[index]['isFavorite'];
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  void showAddUserModal(BuildContext context) {
    final _nameController = TextEditingController();
    final _mobileController = TextEditingController();
    List<String> selectedTags = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New User', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.0),
              Text('Select Tags:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: predefinedTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: selectedTags.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty && _mobileController.text.isNotEmpty) {
                        setState(() {
                          users.add({
                            'name': _nameController.text,
                            'mobile': _mobileController.text,
                            'isFavorite': false,
                            'tags': List.from(selectedTags),
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add User'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  icon: Icon(Icons.filter_list),
                  items: combinedFilters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () => showAddUserModal(context),
                  child: Text('Add User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredUsers().length,
              itemBuilder: (context, index) {
                var filteredUsers = getFilteredUsers();
                return ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.phone),
                    color: Colors.blue,
                    onPressed: () => _makePhoneCall(filteredUsers[index]['mobile']),
                  ),
                  title: Text(filteredUsers[index]['name']),
                  subtitle: Text('Tags: ${filteredUsers[index]['tags'].join(', ')}'),
                  trailing: IconButton(
                    icon: Icon(
                      filteredUsers[index]['isFavorite'] ? Icons.star : Icons.star_border,
                      color: filteredUsers[index]['isFavorite'] ? Colors.yellow : null,
                    ),
                    onPressed: () {
                      toggleFavorite(users.indexOf(filteredUsers[index]));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

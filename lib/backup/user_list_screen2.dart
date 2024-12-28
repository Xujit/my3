import 'database_helper.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

class UserListScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const UserListScreen({super.key, required this.onThemeChanged});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {

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

  void _updateUser(String name, String mobile, bool isFavorite, String tags, String comments) async {
    await DatabaseHelper().updateUser({
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

  List<Map<String, dynamic>> users =[];

  String selectedFilter = 'All';
  List<String> predefinedTags = ['Friend', 'Work', 'Family', 'Gym'];
  List<String> combinedFilters = ['All', 'Favorites', ...['Friend', 'Work', 'Family', 'Gym']];

  // Search-related state
  String searchQuery = '';

  List<Map<String, dynamic>> getFilteredUsers() {
    List<Map<String, dynamic>> filteredUsers = users;

    // Filter based on search query
    if (searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            user['mobile'].contains(searchQuery);
      }).toList();
    }

    // Apply filter based on tags or favorites
    if (selectedFilter == 'Favorites') {
      filteredUsers = filteredUsers.where((user) => user['isFavorite']).toList();
    } else if (predefinedTags.contains(selectedFilter)) {
      filteredUsers = filteredUsers.where((user) => user['tags'].contains(selectedFilter)).toList();
    }

    return filteredUsers;
  }

  void toggleFavorite(int index) {
    setState(() {
      //users[index]['isFavorite'] = users[index]['isFavorite'] == 1 ? 0 : 1;
    });
    _updateUser(
      users[index]['name'],
      users[index]['mobile'],
      users[index]['isFavorite'] == 1,
      users[index]['tags'],
      users[index]['comments'],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrlString(phoneUri.toString())) {
      await launchUrlString(phoneUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  void showAddUserModal(BuildContext context) {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
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
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: mobileController,
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
                      if (nameController.text.isNotEmpty && mobileController.text.isNotEmpty) {
                        setState(() {
                          _addUser(
                              nameController.text,
                              mobileController.text,
                              false,
                              '',
                              ''
                          );
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

  void showEditUserModal(BuildContext context, int index) {
    final nameController = TextEditingController(text: users[index]['name']);
    final mobileController = TextEditingController(text: users[index]['mobile']);
    List<String> selectedTags = List.from(users[index]['tags']);
    final commentsController = TextEditingController(text: users[index]['comments']);

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
              Text('Edit User', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.0),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: mobileController,
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
              TextFormField(
                controller: commentsController,
                decoration: InputDecoration(labelText: 'Comments'),
                maxLines: 4,
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _updateUser(nameController.text,
                            mobileController.text,
                            false, '', commentsController.text);
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Save Changes'),
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

  void confirmDeleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _deleteUser(users[index]['id']);
                  //users.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Don't remove the user if Cancel is clicked
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leads'),
        actions: [
          PopupMenuButton<ThemeMode>(
            onSelected: widget.onThemeChanged,
            icon: Icon(Icons.brightness_6),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light Mode'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark Mode'),
              ),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System Default'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: UserSearchDelegate(users),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
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
                  return Dismissible(
                    key: Key(filteredUsers[index]['name']),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      confirmDeleteUser(index); // Show confirmation dialog on swipe
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.phone),
                        color: Colors.blue,
                        onPressed: () => _makePhoneCall(filteredUsers[index]['mobile']),
                      ),
                      title: InkWell(
                        onTap: () => showEditUserModal(context, index),
                        child: Text(filteredUsers[index]['name']),
                      ),
                      subtitle: Text('Last Called: ${filteredUsers[index]['comments']}'),
                      trailing: IconButton(
                        icon: Icon(
                          filteredUsers[index]['isFavorite']==1 ? Icons.star : Icons.star_border,
                          color: filteredUsers[index]['isFavorite']==1 ? Colors.yellow : null,
                        ),
                        onPressed: () {
                          toggleFavorite(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class UserSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> users;

  UserSearchDelegate(this.users);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';  // Clear the query when the clear button is pressed
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search when back button is pressed
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = users.where((user) {
      return user['name'].toLowerCase().contains(query.toLowerCase()) ||
          user['mobile'].contains(query);
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var user = results[index];
        return ListTile(
          title: Text(user['name']),
          subtitle: Text(user['mobile']),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = users.where((user) {
      return user['name'].toLowerCase().contains(query.toLowerCase()) ||
          user['mobile'].contains(query);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var user = suggestions[index];
        return ListTile(
          title: Text(user['name']),
          subtitle: Text(user['mobile']),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'edit_profile_screen.dart';
import 'user_search_delegate.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'api_service.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const UserListScreen({super.key, required this.onThemeChanged});

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {

  final ApiService _apiService = ApiService();
  List<dynamic> _data = [];
  bool _isLoading = false;

  final Map<String, int> _eventIds = {

  };

  int _selectedEventId = 1;

  List<String> _eventNames = [];
  String _selectedEventName = 'Leads'; // Default title

  void _syncData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiService.fetchData();
      setState(() {
        _data = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sync data: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEventSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Event'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _eventNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_eventNames[index]),
                  onTap: () {
                    setState(() {
                      _selectedEventName = _eventNames[index];
                      _selectedEventId = _eventIds[_selectedEventName]!;
                      userProvider.setEvent(_selectedEventId);// Update the ID
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  late UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    _eventNames = _eventIds.keys.toList();
    _selectedEventName = _eventIds.isNotEmpty ? _eventIds.keys.first: 'Leads';
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (_eventIds.length > 0) {
              _showEventSelectionDialog();
            }
          },
          child: Text(_selectedEventName),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            tooltip: "Sync Data",
            onPressed: _isLoading
                ? null // Disable button while loading
                : _syncData,
          ),
          PopupMenuButton<ThemeMode>(
            onSelected: widget.onThemeChanged, // Directly use onThemeChanged
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
                  delegate: UserSearchDelegate(userProvider.getFilteredUsers()),
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.purple.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userProvider.loggedInUser['name']!, // User name
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                userProvider.loggedInUser['phone']!, // User phone
                                style: TextStyle(color: Colors.white70, fontSize: 14.0),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                userProvider.loggedInUser['email']!, // User email
                                style: TextStyle(color: Colors.white70, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context); // Close the drawer
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(user: userProvider.loggedInUser),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                      // Navigate to the settings screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.pop(context); //
                         // Close the drawer
                      // Navigate to the about screen
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'V. 24.12.01',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),


      body: _isLoading
          ? Center(child: CircularProgressIndicator())
      :Container(
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
              child: DropdownButton<String>(
                value: userProvider.selectedFilter,
                icon: Icon(Icons.filter_list),
                items: userProvider.combinedFilters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  userProvider.setFilter(newValue!);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: userProvider.getFilteredUsers().length,
                itemBuilder: (context, index) {
                  var user = userProvider.getFilteredUsers()[index];
                  return Dismissible(
                    key: Key(user['id'].toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      userProvider.deleteUser(user['id']);
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
                        onPressed: () => _makePhoneCall(user,userProvider, context),
                      ),
                      title: InkWell(
                        onTap: () => showEditUserModal(context, userProvider, index),
                        child: Text(user['name']),
                      ),
                      subtitle: Text(
                        user['lastCalled'] != null && user['lastCalled'].toString().isNotEmpty
                            ? 'Last Called: ${user['lastCalled']}'
                            :  user['mobile'],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          user['isFavorite'] != 0 ? Icons.star : Icons.star_border,
                          color: user['isFavorite'] != 0 ? Colors.yellow : null,
                        ),
                        onPressed: () => userProvider.toggleFavorite(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddUserModal(context),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  void showEditUserModal(BuildContext context, UserProvider userProvider, int index) {
    final user = userProvider.getFilteredUsers()[index];
    final nameController = TextEditingController(text: user['name']);
    final mobileController = TextEditingController(text: user['mobile']);
    final commentsController = TextEditingController(text: user['comments']);
    List<String> selectedTags = user['tags'].split(",");
    //List<String> selectedTagsForModal = [];

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
                children: userProvider.predefinedTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selectedColor: Colors.blue.shade200,
                    backgroundColor: Colors.purple.shade50,
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
                      userProvider.updateUser(
                        user['id'],
                        nameController.text,
                        1,
                        mobileController.text,
                        user['isFavorite'] != 0,
                        selectedTags.join(','),
                        commentsController.text,
                        ''
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Save Changes'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
  void showAddUserModal(BuildContext context) {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final commentsController = TextEditingController();

    // Initialize a local list to store selected tags for this modal session
    List<String> selectedTagsForModal = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

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
                children: userProvider.predefinedTags.map((tag) {
                  return FilterChip(
                    label: Text(tag),
                    selectedColor: Colors.blue.shade200,
                    backgroundColor: Colors.purple.shade50,
                    selected: selectedTagsForModal.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTagsForModal.add(tag);
                        } else {
                          selectedTagsForModal.remove(tag);
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
                        userProvider.addUser(
                          nameController.text,
                          _selectedEventId,
                          mobileController.text,
                          false,
                          selectedTagsForModal.join(','),
                          commentsController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add User'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
  void _makePhoneCall(var user, UserProvider userProvider, BuildContext context) {
    String phoneNumber = user['mobile'];
    final String phoneUri = 'tel:$phoneNumber';
    canLaunchUrlString(phoneUri).then((canLaunch) {
      if (canLaunch) {
        launchUrlString(phoneUri);
        setState(() {
          // Update the last called date and time
          userProvider.updateLastCallDateTime(user,DateFormat('dd-MMM-yy HH:mm').format(DateTime.now()));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $phoneNumber')),
        );
      }
    });
  }
}



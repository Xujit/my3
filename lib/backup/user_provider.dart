import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  List<String> _predefinedTags = [];

  List<Map<String, dynamic>> get users => _users;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  List<String> get predefinedTags => _predefinedTags;

  List<String> get combinedFilters => ['All', 'Favorites', ...predefinedTags];

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  UserProvider() {
    _loadUserProfile();
    _loadUsers();
    _loadTags();
  }

  Map<String, String> loggedInUser = {
    'name': '',
    'phone': '',
    'email': '',
  };

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInUser['name'] = prefs.getString('userName') ?? 'Default Name';
    loggedInUser['phone'] = prefs.getString('userPhone') ?? '1234567890';
    loggedInUser['email'] = prefs.getString('userEmail') ?? 'example@example.com';
    notifyListeners(); // Notify listeners after loading data
  }

  Future<void> updateUserProfile(String name, String phone, String email) async {
    final prefs = await SharedPreferences.getInstance();
    loggedInUser = {'name': name, 'phone': phone, 'email': email};
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
    await prefs.setString('userEmail', email);
    await _loadUserProfile();
  }


  void _loadUsers() async {
    _users = await DatabaseHelper().fetchUsers();
    notifyListeners();
  }



  List<Map<String, dynamic>> getFilteredUsers() {
    List<Map<String, dynamic>> filteredUsers = _users;

    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user['mobile'].contains(_searchQuery);
      }).toList();
    }

    if (_selectedFilter == 'Favorites') {
      filteredUsers = filteredUsers.where((user) => user['isFavorite'] != 0).toList();
    } else if (_predefinedTags.contains(_selectedFilter)) {
      filteredUsers = filteredUsers.where((user) {
        return user['tags'].split(',').contains(_selectedFilter);
      }).toList();
    }

    return filteredUsers;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> addUser(String name, String mobile, bool isFavorite, String tags, String comments) async {
    await DatabaseHelper().insertUser({
      'name': name,
      'mobile': mobile,
      'isFavorite': isFavorite ? 1 : 0,
      'tags': tags,
      'comments': comments,
    });
    _loadUsers();
  }

  Future<void> updateUser(int id,String name, String mobile, bool isFavorite, String tags, String comments,String lastCalled) async {
    await DatabaseHelper().updateUser({
      'id': id,
      'name': name,
      'mobile': mobile,
      'isFavorite': isFavorite ? 1 : 0,
      'tags': tags,
      'comments': comments,
      'lastCalled': lastCalled
    });
    _loadUsers();
  }

  Future<void> deleteUser(int id) async {
    await DatabaseHelper().deleteUser(id);
    _loadUsers();
  }

  void toggleFavorite(int index) async {
    int userFavourite = _users[index]['isFavorite'] == 0 ? 1 : 0;
    await updateUser(
      _users[index]['id'],
      _users[index]['name'],
      _users[index]['mobile'],
      userFavourite != 0,
      _users[index]['tags'],
      _users[index]['comments'],
      _users[index]['lastCalled']
    );
  }
  void updateLastCallDateTime(var user,String lastCalled) async {
    await updateUser(
        user['id'],
        user['name'],
        user['mobile'],
        user['isFavorite']==1,
        user['tags'],
        user['comments'],
        lastCalled
    );
  }
  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    _predefinedTags = prefs.getStringList('tags') ?? ['Tag1', 'Tag2', 'Tag3'];
    notifyListeners();
  }

  Future<void> addTag(String tag) async {
    if (!_predefinedTags.contains(tag)) {
      _predefinedTags.add(tag);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('tags', _predefinedTags);
      notifyListeners();
    }
  }

  Future<void> removeTag(String tag) async {
    _predefinedTags.remove(tag);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tags', _predefinedTags);
    notifyListeners();
  }
}

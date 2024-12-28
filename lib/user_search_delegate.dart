import 'package:flutter/material.dart';

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

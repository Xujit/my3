import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<dynamic> users;
  final Function onEdit;
  final Function onDelete;
  final Function onToggleFavorite;

  const UserList({
    Key? key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        var user = users[index];
        return Dismissible(
          key: Key(user['id'].toString()),
          onDismissed: (direction) => onDelete(user),
          background: Container(color: Colors.red, child: Icon(Icons.delete)),
          child: ListTile(
            title: Text(user['name']),
            trailing: IconButton(
              icon: Icon(
                user['isFavorite'] != 0 ? Icons.star : Icons.star_border,
                color: user['isFavorite'] != 0 ? Colors.yellow : null,
              ),
              onPressed: () => onToggleFavorite(user),
            ),
            onTap: () => onEdit(user),
          ),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';

class SelectedUsers extends ChangeNotifier{
  Set<String> _selectedUsers = {};

  void addUser({required final String email}){
    _selectedUsers.add(email);
    notifyListeners();
  }

  void removeUser({required final String email}){
    _selectedUsers.remove(email);
    notifyListeners();
  }

  List<String> get toList {
    List<String> users = [];
    _selectedUsers.forEach((element) { users.add(element); });
    return users;
  }

  bool get isNotEmpty => _selectedUsers.isNotEmpty;

  bool get isEmpty => _selectedUsers.isEmpty;
}
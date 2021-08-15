import 'package:flutter/cupertino.dart';
import 'package:hi/services/firebase_service.dart';

class SelectedChats extends ChangeNotifier{
  Set<String> _selectedChats = {};

  void addChat({required final String roomId}){
    _selectedChats.add(roomId);
    notifyListeners();
  }

  void removeChat({required final String roomId}){
    _selectedChats.remove(roomId);
    notifyListeners();
  }

  List<String> get toList {
    List<String> chats = [];
    _selectedChats.forEach((element) { chats.add(element); });
    return chats;
  }

  bool get isNotEmpty => _selectedChats.isNotEmpty;

  bool get isEmpty => _selectedChats.isEmpty;

  Future<void> deleteChats() async {
    await FirebaseService.deleteCurrentUserChats(roomIds: this.toList);
    _selectedChats.clear();
  }
}
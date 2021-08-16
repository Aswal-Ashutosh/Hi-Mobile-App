import 'package:flutter/cupertino.dart';
import 'package:hi/provider/helper/chat.dart';

class SelectedForwardMessageChats extends ChangeNotifier{
  Map<String, Chat> _selectedChats = {};

  void addChat({required final Chat chat}){
    _selectedChats[chat.roomId] = chat;
    notifyListeners();
  }

  void removeChat({required final String roomId}){
    _selectedChats.remove(roomId);
    notifyListeners();
  }

  List<Chat> get toList {
    List<Chat> chats = [];
    _selectedChats.forEach((key, value) {chats.add(value);});
    return chats;
  }

  bool get isNotEmpty => _selectedChats.isNotEmpty;

  bool get isEmpty => _selectedChats.isEmpty;
}
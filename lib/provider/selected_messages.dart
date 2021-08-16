import 'package:flutter/cupertino.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/services/firebase_service.dart';

class SelectedMessages extends ChangeNotifier {
  Set<String> _selectedMessagesIds = {};
  Map<String, Message> _selectedMessages = {};

  void addMessage({required final Message message}) {
    _selectedMessagesIds.add(message.messageId);
    _selectedMessages[message.messageId] = message;
    notifyListeners();
  }

  void removeMessage({required final String messageId}) {
    _selectedMessagesIds.remove(messageId);
    _selectedMessages.remove(messageId);
    notifyListeners();
  }

  List<Message> get toList {
    List<Message> messages = [];
    _selectedMessages.forEach((id, message) {
      messages.add(message);
    });
    return messages;
  }

  bool contain({required final String messageId}) =>
      _selectedMessagesIds.contains(messageId);

  bool get canBeDeletedForEveryone {
    final currentTime = DateTime.now();
    for (final message in _selectedMessages.values) {
      if (message.sender != FirebaseService.currentUserEmail) return false;
      final messageCreatedAt = message.timestamp.toDate();
      if (currentTime.difference(messageCreatedAt).inHours > 24) return false;
    }
    return true;
  }

  Future<void> deleteSelectedMessageForCurrentUser(
      {required final String roomId}) async {
    await FirebaseService.deleteMessageForCurrentUserOnly(
        roomId: roomId, messageIds: _selectedMessagesIds.toList());
    _selectedMessages.clear();
    _selectedMessagesIds.clear();
  }

  Future<void> deleteSelectedMessageForEveryOne(
      {required final String roomId}) async {
    await FirebaseService.deleteMessageForEveryOne(
        roomId: roomId, messageIds: _selectedMessagesIds.toList());
    _selectedMessages.clear();
    _selectedMessagesIds.clear();
  }

  void clear() {
    _selectedMessages.clear();
    _selectedMessagesIds.clear();
  }

  bool get isNotEmpty => _selectedMessages.isNotEmpty;

  bool get isEmpty => _selectedMessages.isEmpty;
}

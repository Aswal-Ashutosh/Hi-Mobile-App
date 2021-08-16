import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String? content;
  final String sender;
  final String time;
  final String date;
  final String type;
  final List<String>? imageUrls;
  final Timestamp timestamp;

  Message({required this.messageId, this.content, required this.sender, this.imageUrls, required this.timestamp, required this.time, required this.date, required this.type});
}

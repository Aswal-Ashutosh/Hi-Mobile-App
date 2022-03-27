import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TextStreamBuilder extends StatelessWidget {
  final _stream;
  final String _key;
  final TextStyle? _style;
  final TextOverflow? _textOverflow;
  const TextStreamBuilder(
      {required final stream,
      required final String key,
      final TextStyle? style,
      final TextOverflow? textOverflow})
      : _stream = stream,
        _key = key,
        _textOverflow = textOverflow,
        _style = style;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data;
          final requiredData = userData?[_key];
          return Text(
            requiredData,
            style: _style,
            overflow: _textOverflow,
          );
        } else {
          return Text('Loading...', style: TextStyle(color: Colors.grey));
        }
      },
    );
  }
}

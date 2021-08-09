

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConditionalStreamBuilder extends StatelessWidget {
  ///[CoditionalStreamBuilder] will take a stream to firebase document and depending upon wether
  ///that document exist or not it will build one of the two child provided.
  const ConditionalStreamBuilder(
      {required final Stream<DocumentSnapshot<Object?>> stream,
      required final Widget childIfExist,
      required final Widget childIfDoNotExist})
      : _stream = stream,
        _childIfExist = childIfExist,
        _childIfDoNotExist = childIfDoNotExist;

  final Stream<DocumentSnapshot<Object?>> _stream;
  final Widget _childIfExist;
  final Widget _childIfDoNotExist;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        bool exist =
            snapshot.hasData && snapshot.data != null && snapshot.data!.exists;
        return exist ? _childIfExist : _childIfDoNotExist;
      },
    );
  }
}

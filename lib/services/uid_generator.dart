import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class UidGenerator {
  static final uuid = Uuid();

  static String getRoomIdFor({required String email1, required String email2}) {
    late String combination;

    if (email1.compareTo(email2) > 0) {
      combination = email2 + email1;
    } else {
      combination = email1 + email2;
    }

    final List<int> bytes = utf8.encode(combination);
    final Digest digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  static String get uniqueId => uuid.v1();
}

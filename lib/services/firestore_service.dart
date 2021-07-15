import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  static FirebaseFirestore _fStore = FirebaseFirestore.instance;

  static Future<void> createNewUser({required String email, required String name}) async{
    await _fStore.collection('users').doc(email).set({'email': email, 'display_name': name, 'search_name': name.toLowerCase()});
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreService{
  static FirebaseFirestore _fStore = FirebaseFirestore.instance;
  static FirebaseAuth _fAuth = FirebaseAuth.instance;

  static Future<void> createNewUser({required String uid, required String email, required String name}) async{
    await _fStore.collection('users').doc(email).set({'uid': uid, 'email': email, 'display_name': name, 'search_name': name.toLowerCase()});
  }

  static Future<void> sendFriendRequest({required String recipientEmail}) async{
    final senderEmail = _fAuth.currentUser?.email;
    //Sending request to yourselft
    if(senderEmail == recipientEmail) 
      throw('Can\'t send request to yourself.');
    
    //No such email exist in database
    if(await _fStore.collection('users').doc(recipientEmail).get().then((value) => !value.exists))
      throw('No such user exist.');
    
    //If already friends
    if(await _fStore.collection('users').doc(senderEmail).collection('friends').doc(recipientEmail).get().then((value) => value.exists))
      throw('You are already friends.');
    
    //If same user already requested you
    if(await _fStore.collection('users').doc(senderEmail).collection('friend_requests').doc(recipientEmail).get().then((value) => value.exists))
      throw('You have a pending request from the same user.');
    
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore.collection('users').doc(recipientEmail).collection('friend_requests').doc(senderEmail).set({
      'sender_email': senderEmail,
      'time': timeOfSending,
      'date': dateOfSending,
    });
  }
}
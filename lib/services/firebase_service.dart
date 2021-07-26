import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hi/constants/firestore_costants.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/uid_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  static FirebaseFirestore _fStore = FirebaseFirestore.instance;
  static FirebaseAuth _fAuth = FirebaseAuth.instance;
  static FirebaseStorage _fStorage = FirebaseStorage.instance;

  static Future<void> createNewUser({
    required String email,
    required String name,
    required String about,
    required File? profileImage,
  }) async {
    String? profileImageUrl;

    if (profileImage != null) {
      Reference reference = _fStorage
          .ref()
          .child('profile_pictures/${_fAuth.currentUser?.email}');
      UploadTask task = reference.putFile(profileImage);
      TaskSnapshot snapshot = await task.whenComplete(() => task.snapshot);
      profileImageUrl = await snapshot.ref.getDownloadURL();
    }

    await _fStore.collection(Collections.USERS).doc(email).set({
      UserDocumentField.EMAIL: email,
      UserDocumentField.DISPLAY_NAME: name,
      UserDocumentField.SEARCH_NAME: name.toLowerCase(),
      UserDocumentField.PROFILE_IMAGE: profileImageUrl,
      UserDocumentField.ABOUT: about,
    });
  }

  static Future<bool> get userHasSetupProfile async => await _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .get()
      .then((value) => value.exists);

  static Future<void> signOut() async => await _fAuth.signOut();

  static Future<void> sendFriendRequest(
      {required String recipientEmail}) async {
    final senderEmail = FirebaseService.currentUserEmail;
    //Sending request to yourselft
    if (senderEmail == recipientEmail)
      throw ('Can\'t send request to yourself.');

    //No such email exist in database
    if (await _fStore
        .collection(Collections.USERS)
        .doc(recipientEmail)
        .get()
        .then((value) => !value.exists)) throw ('No such user exist.');

    //If already friends
    if (await _fStore
        .collection(Collections.USERS)
        .doc(senderEmail)
        .collection(Collections.FRIENDS)
        .doc(recipientEmail)
        .get()
        .then((value) => value.exists)) throw ('You are already friends.');

    //If same user already requested you
    if (await _fStore
        .collection(Collections.USERS)
        .doc(senderEmail)
        .collection(Collections.FRIEND_REQUESTS)
        .doc(recipientEmail)
        .get()
        .then((value) => value.exists))
      throw ('You have a pending request from the same user.');

    //If your request is still pending
    if (await _fStore
        .collection(Collections.USERS)
        .doc(recipientEmail)
        .collection(Collections.FRIEND_REQUESTS)
        .doc(senderEmail)
        .get()
        .then((value) => value.exists))
      throw ('Your request is still pending.');

    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore
        .collection(Collections.USERS)
        .doc(recipientEmail)
        .collection(Collections.FRIEND_REQUESTS)
        .doc(senderEmail)
        .set({
      FriendRequestDocumentField.SENDER_EMAIL: senderEmail,
      FriendRequestDocumentField.TIME: timeOfSending,
      FriendRequestDocumentField.DATE: dateOfSending,
    });
  }

  static Future<void> pickAndUploadProfileImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Reference reference = _fStorage
          .ref()
          .child('profile_pictures/${_fAuth.currentUser?.email}');
      UploadTask task = reference.putFile(File(image.path));
      TaskSnapshot snapshot = await task.whenComplete(() => task.snapshot);
      String url = await snapshot.ref.getDownloadURL();

      final email = _fAuth.currentUser?.email;
      await _fStore
          .collection(Collections.USERS)
          .doc(email)
          .update({UserDocumentField.PROFILE_IMAGE: url});
    }
  }

  static getStreamToUserData({required final String email}) =>
      _fStore.collection(Collections.USERS).doc(email).snapshots();

  static get currentUserStreamToUserData =>
      getStreamToUserData(email: FirebaseService.currentUserEmail);

  static get currentUserStreamToFirendRequests => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.FRIEND_REQUESTS)
      .snapshots();

  static get currentUserStreamToFriends => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.FRIENDS)
      .snapshots();

  static Future<String> getNameOf({required final String email}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(email)
          .get()
          .then((value) => value[UserDocumentField.DISPLAY_NAME]);

  static Future<String> get currentUserName async =>
      await getNameOf(email: FirebaseService.currentUserEmail);

  static String get currentUserEmail => _fAuth.currentUser?.email as String;

  static Future<void> acceptFriendRequest({required final String email}) async {
    //Adding friend to current user friend list
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.FRIENDS)
        .doc(email)
        .set({FriendsDocumentField.EMAIL: email});
    //Adding current user to friend's friend list
    await _fStore
        .collection(Collections.USERS)
        .doc(email)
        .collection(Collections.FRIENDS)
        .doc(FirebaseService.currentUserEmail)
        .set({FriendsDocumentField.EMAIL: FirebaseService.currentUserEmail});
    //Deleting the request
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.FRIEND_REQUESTS)
        .doc(email)
        .delete();
    
    //Setting Room Id
    final String roomId = UidGenerator.getRoomIdFor(email1: email, email2: FirebaseService.currentUserEmail);

    //Creating Chat refrence in current user collection
    await _fStore.collection(Collections.USERS).doc(FirebaseService.currentUserEmail).collection(Collections.CHATS).doc(roomId).set(
      {
        ChatDocumentField.ROOM_ID: roomId,
        ChatDocumentField.VISIBILITY: false,
        ChatDocumentField.SHOW_AFTER: DateTime.now(),
      }
    );

    //Creating Chat refrence in friend collection
    await _fStore.collection(Collections.USERS).doc(email).collection(Collections.CHATS).doc(roomId).set(
      {
        ChatDocumentField.ROOM_ID: roomId,
        ChatDocumentField.VISIBILITY: false,
        ChatDocumentField.SHOW_AFTER: DateTime.now(),
      }
    );

    //Creating Chat in Chat Database

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).set({ChatDBDocumentField.ROOM_ID: roomId});
  }

  static Future<void> rejectFreindRequest({required final String email}) async {
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.FRIEND_REQUESTS)
        .doc(email)
        .delete();
  }

  static Future<void> updateCurrentUserAboutField(
          {required final String about}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .update({UserDocumentField.ABOUT: about});
  
   static Future<void> updateCurrentUserNameField(
          {required final String name}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .update({
            UserDocumentField.DISPLAY_NAME: name,
            UserDocumentField.SEARCH_NAME: name.toLowerCase(),
          });

  static Future<String> get currentUserAboutFieldData async => await _fStore
    .collection(Collections.USERS).doc(FirebaseService.currentUserEmail).get().then((value) => value[UserDocumentField.ABOUT]);

  //Chat Related functions

  static Future<void> sendTextMessageToFriend({required String friendEmail, required String roomId, required String message}) async{
    //Setting visiblity as true for current user chat reference.
    await _fStore.collection(Collections.USERS).doc(FirebaseService.currentUserEmail).collection(Collections.CHATS).doc(roomId).update({ChatDocumentField.VISIBILITY: true});
    //Setting visiblity as true for friends chat reference.
    await _fStore.collection(Collections.USERS).doc(friendEmail).collection(Collections.CHATS).doc(roomId).update({ChatDocumentField.VISIBILITY: true});

    //Sending Message
    final encryptedMessage = EncryptionService.encrypt(message);
    final messageId = UidGenerator.uniqueId;
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).collection(Collections.MESSAGES).doc(messageId).set({
      MessageDocumentField.MESSAGE_ID: messageId,
      MessageDocumentField.SENDER: FirebaseService.currentUserEmail,
      MessageDocumentField.CONTENT: encryptedMessage,
      MessageDocumentField.DATE: dateOfSending,
      MessageDocumentField.TIME: timeOfSending,
      MessageDocumentField.TIME_STAMP: timeStamp,
      MessageDocumentField.TYPE: MessageType.TEXT,
    });
  }

  static getStreamToChat({required roomId}) => _fStore.collection(Collections.CHAT_DB).doc(roomId).collection(Collections.MESSAGES).orderBy(MessageDocumentField.TIME_STAMP, descending: true).snapshots();
}

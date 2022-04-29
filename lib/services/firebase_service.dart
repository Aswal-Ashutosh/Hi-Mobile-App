import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hi/constants/firestore_constants.dart';
import 'package:hi/provider/helper/chat.dart';
import 'package:hi/provider/helper/message.dart';
import 'package:hi/services/encryption_service.dart';
import 'package:hi/services/image_picker_service.dart';
import 'package:hi/services/uid_generator.dart';
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
    //Sending request to yourself
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

  static Future<bool> pickAndUploadProfileImage() async {
    File? image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      Reference reference = _fStorage
          .ref()
          .child('profile_pictures/${_fAuth.currentUser?.email}');
      UploadTask task = reference.putFile(image);
      TaskSnapshot snapshot = await task.whenComplete(() => task.snapshot);
      String url = await snapshot.ref.getDownloadURL();

      final email = _fAuth.currentUser?.email;
      await _fStore
          .collection(Collections.USERS)
          .doc(email)
          .update({UserDocumentField.PROFILE_IMAGE: url});
      return true;
    }
    return false;
  }

  static getStreamToUserData({required final String email}) =>
      _fStore.collection(Collections.USERS).doc(email).snapshots();

  static get currentUserStreamToUserData =>
      getStreamToUserData(email: FirebaseService.currentUserEmail);

  static getStreamToGroupData({required final String roomId}) =>
      _fStore.collection(Collections.CHAT_DB).doc(roomId).snapshots();

  static get currentUserStreamToFriendRequests => _fStore
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
    final String roomId = UidGenerator.getRoomIdFor(
        email1: email, email2: FirebaseService.currentUserEmail);

    //IF USERS WERE ALREADY FRIENDS AND UNFRIEND THEM THEN IF THEY AGAIN WANT TO BECOME FRIEND,
    //THEN WE DON'T NEED TO MAKE CHAT REFERENCE AGAIN AS THEY WILL BE THERE ONLY WITH VISIBILITY TRUE/FALSE.
    if (await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value.exists)) return;

    //IF BECOMING FRIENDS FOR THE FIRST TIME

    //Creating Chat reference in current user collection
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .set({
      ChatDocumentField.ROOM_ID: roomId,
      ChatDocumentField.VISIBILITY: false,
      ChatDocumentField.SHOW_AFTER: DateTime.now(),
    });

    //Creating Chat reference in friend collection
    await _fStore
        .collection(Collections.USERS)
        .doc(email)
        .collection(Collections.CHATS)
        .doc(roomId)
        .set({
      ChatDocumentField.ROOM_ID: roomId,
      ChatDocumentField.VISIBILITY: false,
      ChatDocumentField.SHOW_AFTER: DateTime.now(),
    });

    //Creating Chat in Chat Database
    await _fStore.collection(Collections.CHAT_DB).doc(roomId).set({
      ChatDBDocumentField.ROOM_ID: roomId,
      ChatDBDocumentField.TYPE: ChatType.ONE_TO_ONE,
      ChatDBDocumentField.MEMBERS: [email, FirebaseService.currentUserEmail],
    });
  }

  static Future<void> rejectFriendRequest({required final String email}) async {
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
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .get()
      .then((value) => value[UserDocumentField.ABOUT]);

  //Chat Related functions

  static Future<void> sendTextMessageToRoom(
      {required String roomId, required String message}) async {
    //Sending Message
    final encryptedMessage = EncryptionService.encrypt(message);
    final messageId = UidGenerator.uniqueId;
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .collection(Collections.MESSAGES)
        .doc(messageId)
        .set({
      MessageDocumentField.MESSAGE_ID: messageId,
      MessageDocumentField.SENDER: FirebaseService.currentUserEmail,
      MessageDocumentField.CONTENT: encryptedMessage,
      MessageDocumentField.DATE: dateOfSending,
      MessageDocumentField.TIME: timeOfSending,
      MessageDocumentField.TIME_STAMP: timeStamp,
      MessageDocumentField.TYPE: MessageType.TEXT,
      MessageDocumentField.DELETED_BY: {},
      MessageDocumentField.DELETED_FOR_EVERYONE: false,
      MessageDocumentField.FORWARDED_MESSAGE: false,
    });

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).update({
      ChatDBDocumentField.LAST_MESSAGE: encryptedMessage,
      ChatDBDocumentField.LAST_MESSAGE_TIME: timeOfSending,
      ChatDBDocumentField.LAST_MESSAGE_DATE: dateOfSending,
      ChatDBDocumentField.LAST_MESSAGE_TYPE: MessageType.TEXT,
      ChatDBDocumentField.LAST_MESSAGE_SEEN: {
        FirebaseService.currentUserEmail: true
      },
      ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP: timeStamp,
    });
  }

  static Future<void> sendTextMessageToFriend(
      {required String friendEmail,
      required String roomId,
      required String message}) async {
    //Sending Message
    await FirebaseService.sendTextMessageToRoom(
        roomId: roomId, message: message);

    //Setting visibility as true for current user chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
    //Setting visibility as true for friends chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(friendEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
  }

  static Future<void> sendImagesToRoom({
    required String roomId,
    required List<File> images,
    required String? message,
  }) async {
    List<String> encryptedUrl = [];
    for (File image in images) {
      //Uploading images
      final Reference reference =
          _fStorage.ref().child('shared_pictures/${UidGenerator.uniqueId}');
      final UploadTask task = reference.putFile(image);
      final TaskSnapshot snapshot =
          await task.whenComplete(() => task.snapshot);
      final String url = await snapshot.ref.getDownloadURL();
      encryptedUrl.add(EncryptionService.encrypt(url));
    }

    final encryptedMessage =
        message != null ? EncryptionService.encrypt(message) : null;
    final messageId = UidGenerator.uniqueId;
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .collection(Collections.MESSAGES)
        .doc(messageId)
        .set({
      MessageDocumentField.MESSAGE_ID: messageId,
      MessageDocumentField.SENDER: FirebaseService.currentUserEmail,
      MessageDocumentField.IMAGES: encryptedUrl,
      MessageDocumentField.CONTENT: encryptedMessage,
      MessageDocumentField.DATE: dateOfSending,
      MessageDocumentField.TIME: timeOfSending,
      MessageDocumentField.TIME_STAMP: timeStamp,
      MessageDocumentField.TYPE: MessageType.IMAGE,
      MessageDocumentField.DELETED_BY: {},
      MessageDocumentField.DELETED_FOR_EVERYONE: false,
      MessageDocumentField.FORWARDED_MESSAGE: false,
    });

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).update({
      ChatDBDocumentField.LAST_MESSAGE: encryptedMessage,
      ChatDBDocumentField.LAST_MESSAGE_TIME: timeOfSending,
      ChatDBDocumentField.LAST_MESSAGE_DATE: dateOfSending,
      ChatDBDocumentField.LAST_MESSAGE_TYPE: MessageType.IMAGE,
      ChatDBDocumentField.LAST_MESSAGE_SEEN: {
        FirebaseService.currentUserEmail: true
      },
      ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP: timeStamp,
    });
  }

  //METHOD: to send photos to friend
  static Future<void> sendImagesToFriend({
    required String friendEmail,
    required String roomId,
    required List<File> images,
    required String? message,
  }) async {
    await FirebaseService.sendImagesToRoom(
        roomId: roomId, images: images, message: message);

    //Setting visibility as true for current user chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});

    //Setting visibility as true for friends chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(friendEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
  }

  //METHOD: To get stream to chat room messages
  static getStreamToChatRoomMessages({required final String roomId}) => _fStore
      .collection(Collections.CHAT_DB)
      .doc(roomId)
      .collection(Collections.MESSAGES)
      .orderBy(MessageDocumentField.TIME_STAMP, descending: true)
      .snapshots();

  //METHOD: To get stream to chat room messages
  static getStreamToRemovedChatRoomMessages(
          {required final String roomId, required final Timestamp removedAt}) =>
      _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .collection(Collections.MESSAGES)
          .where(MessageDocumentField.TIME_STAMP, isLessThan: removedAt)
          .orderBy(MessageDocumentField.TIME_STAMP, descending: true)
          .snapshots();

  static get currentUserStreamToChats => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.CHATS)
      .where(ChatDocumentField.VISIBILITY, isEqualTo: true)
      .snapshots();

  static getStreamToChatDBWhereRoomIdIn({required final List<String> rooms}) =>
      _fStore
          .collection(Collections.CHAT_DB)
          .where(ChatDBDocumentField.ROOM_ID, whereIn: rooms)
          .orderBy(ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP,
              descending: true)
          .snapshots();

  static getStreamToChatRoomDoc({required final String roomId}) =>
      _fStore.collection(Collections.CHAT_DB).doc(roomId).snapshots();

  static Future<void> setCurrentUserOnline({required final bool state}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .update({UserDocumentField.ONLINE: state});

  //METHOD: TO CREATE A GROUP
  static Future<void> createNewGroup(
      {required List<String> members,
      required final String groupName,
      required final String aboutGroup,
      required final File? groupImage}) async {
    //Adding current user to the member list
    members.insert(0, FirebaseService.currentUserEmail);

    //Generating Unique Room ID
    final String roomId = UidGenerator.uniqueId;

    //Uploading Group Image
    String? groupImageUrl;

    if (groupImage != null) {
      Reference reference =
          _fStorage.ref().child('group_profile_pictures/$roomId');
      UploadTask task = reference.putFile(groupImage);
      TaskSnapshot snapshot = await task.whenComplete(() => task.snapshot);
      groupImageUrl = await snapshot.ref.getDownloadURL();
    }

    final timeStamp = DateTime.now();
    final timeOfCreation = DateFormat.jm().format(timeStamp);
    final dateOfCreation = DateFormat.yMMMMEEEEd().format(timeStamp);

    //Creating Group in Chat Database
    await _fStore.collection(Collections.CHAT_DB).doc(roomId).set({
      ChatDBDocumentField.GROUP_NAME: groupName,
      ChatDBDocumentField.GROUP_IMAGE: groupImageUrl,
      ChatDBDocumentField.GROUP_ADMIN: FirebaseService.currentUserEmail,
      ChatDBDocumentField.GROUP_ABOUT: aboutGroup,
      ChatDBDocumentField.GROUP_CREATED_AT:
          '$dateOfCreation at $timeOfCreation',
      ChatDBDocumentField.ROOM_ID: roomId,
      ChatDBDocumentField.MEMBERS: members,
      ChatDBDocumentField.TYPE: ChatType.GROUP,
      ChatDBDocumentField.LAST_MESSAGE_TYPE: null,
      ChatDBDocumentField.LAST_MESSAGE_SEEN: {},
      ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP:
          timeStamp, /* This field is required to Sort the Chat based on time*/
    });

    //Creating reference for each member
    for (final String member in members) {
      _fStore
          .collection(Collections.USERS)
          .doc(member)
          .collection(Collections.CHATS)
          .doc(roomId)
          .set({
        ChatDocumentField.ROOM_ID: roomId,
        ChatDocumentField.VISIBILITY: true,
        ChatDocumentField.SHOW_AFTER: timeStamp,
        ChatDocumentField.REMOVED: false,
        ChatDocumentField.REMOVED_AT: null,
        ChatDBDocumentField.DELETED: false,
      });
    }
  }

  static Future<void> markLastMessageAsSeen(
      {required final String roomId}) async {
    final Map<dynamic, dynamic> lastMessageSeen = await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value[ChatDBDocumentField.LAST_MESSAGE_SEEN]);
    lastMessageSeen[FirebaseService.currentUserEmail] = true;
    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .update({ChatDBDocumentField.LAST_MESSAGE_SEEN: lastMessageSeen});
  }

  //[METHOD]: TO CHECK WETHER THE CURRENT USER IS FRIEND WITH THE USER WITH THE PROVIDED EMAIL ID
  static Future<bool> isFriend({required final String email}) async {
    return await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.FRIENDS)
        .doc(email)
        .get()
        .then((value) => value.exists);
  }

  //[METHOD]: TO UNFRIEND A USER
  static Future<void> unfriend({required final String email}) async {
    //DELETING PROVIDED USER FROM CURRENT USER FRIENDS LIST
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.FRIENDS)
        .doc(email)
        .delete();
    //DELETING CURRENT USER FROM PROVIDED USER FRIENDS LIST
    await _fStore
        .collection(Collections.USERS)
        .doc(email)
        .collection(Collections.FRIENDS)
        .doc(FirebaseService.currentUserEmail)
        .delete();
  }

  //[METHOD]: TO GET FRIEND DOCUMENT FROM FRIENDS COLLECTION OF A CURRENT USER
  static getStreamToFriendDoc({required final String email}) => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.FRIENDS)
      .doc(email)
      .snapshots();

  //[METHOD]: TO GET GROUP ADMIN
  static Future<String> getGroupData(
          {required final String roomId, required final String key}) async =>
      await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .get()
          .then((value) => value[key]);

  //[METHOD]: TO UPDATE GROUP DATA STRING FIELDS
  static Future<void> updateGroupData(
          {required final String roomId,
          required final String key,
          required final String newValue}) async =>
      await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .update({key: newValue});

  //[METHOD]: TO UPDATE GROUP PROFILE PICTURE
  static Future<bool> pickAndUploadGroupProfileImage(
      {required final String roomId}) async {
    File? image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      Reference reference =
          _fStorage.ref().child('group_profile_pictures/$roomId');
      UploadTask task = reference.putFile(image);
      TaskSnapshot snapshot = await task.whenComplete(() => task.snapshot);
      String groupImageUrl = await snapshot.ref.getDownloadURL();

      await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .update({ChatDBDocumentField.GROUP_IMAGE: groupImageUrl});
      return true;
    }
    return false;
  }

  //[METHOD]: TO GET SET OF GROUP MEMBERS
  static Future<Set<String>> getGroupMembers(
      {required final String roomId}) async {
    List<dynamic> membersList = await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value[ChatDBDocumentField.MEMBERS]);
    Set<String> membersSet = {};
    membersList.forEach((member) {
      membersSet.add(member);
    });
    return membersSet;
  }

  static Future<void> addMembersInGroup(
      {required final String roomId,
      required final List<String> newMembers}) async {
    final List<dynamic> members = await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value[ChatDBDocumentField.MEMBERS]);
    members.addAll(newMembers);
    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .update({ChatDBDocumentField.MEMBERS: members});

    //Creating reference for each member
    for (final String member in members) {
      if (await _fStore
          .collection(Collections.USERS)
          .doc(member)
          .collection(Collections.CHATS)
          .doc(roomId)
          .get()
          .then((value) => value.exists)) {
        _fStore
            .collection(Collections.USERS)
            .doc(member)
            .collection(Collections.CHATS)
            .doc(roomId)
            .update({
          ChatDocumentField.REMOVED: false,
          ChatDocumentField.REMOVED_AT: null,
          ChatDocumentField.VISIBILITY: true,
        });
      } else {
        _fStore
            .collection(Collections.USERS)
            .doc(member)
            .collection(Collections.CHATS)
            .doc(roomId)
            .set({
          ChatDocumentField.ROOM_ID: roomId,
          ChatDocumentField.VISIBILITY: true,
          ChatDocumentField.SHOW_AFTER: DateTime.now(),
          ChatDocumentField.REMOVED: false,
          ChatDocumentField.REMOVED_AT: null,
        });
      }
    }
  }

  //[METHOD]: THIS METHOD WILL RETURN STREAM TO USER SIDE CHAT REFERENCE OF A CHAT
  static getStreamToUserChatRef({required final String roomId}) => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.CHATS)
      .doc(roomId)
      .snapshots();

  //[METHOD]: TO REMOVE MEMBER FROM THE GROUP
  static Future<void> removeMemberFromGroup(
      {required final String roomId,
      required final String memberEmail}) async {
    //Removing from member array
    final List<dynamic> members = await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value[ChatDBDocumentField.MEMBERS]);
    members.remove(memberEmail);
    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .update({ChatDBDocumentField.MEMBERS: members});

    //Marking removed in user chat reference to group
    await _fStore
        .collection(Collections.USERS)
        .doc(memberEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({
      ChatDocumentField.REMOVED: true,
      ChatDocumentField.REMOVED_AT: DateTime.now(),
    });
  }

  //[METHOD]: TO LEAVE A GROUP
  static Future<void> leaveGroup({required final roomId}) async =>
      await FirebaseService.removeMemberFromGroup(
          roomId: roomId, memberEmail: FirebaseService.currentUserEmail);

  //[METHOD]: TO DELETE THE GROUP
  static Future<void> deleteGroup({required roomId}) async {
    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .update({ChatDBDocumentField.DELETED: true});
    final List<dynamic> members = await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .get()
        .then((value) => value[ChatDBDocumentField.MEMBERS]);
    for (final member in members) {
      await _fStore
          .collection(Collections.USERS)
          .doc(member)
          .collection(Collections.CHATS)
          .doc(roomId)
          .update({ChatDocumentField.DELETED: true});
    }
  }

  //[METHOD]: THIS METHOD WILL RETURN TRUE IF GROUP IS DELETED
  static Future<bool> isGroupDeleted({required final String roomId}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .collection(Collections.CHATS)
          .doc(roomId)
          .get()
          .then((value) => value[ChatDocumentField.DELETED]);

  //[METHOD]: THIS METHOD WILL RETURN TRUE IF CURRENT USER IF REMOVED FROM THE GROUP
  static Future<bool> isCurrentUserRemovedFromGroup(
          {required final String roomId}) async =>
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .collection(Collections.CHATS)
          .doc(roomId)
          .get()
          .then((value) => value[ChatDocumentField.REMOVED]);

  //[METHOD]: TO DELETE CHATS OF CURRENT USER
  static Future<void> deleteCurrentUserChats(
      {required final List<String> roomIds}) async {
    for (final String roomId in roomIds) {
      await _fStore
          .collection(Collections.USERS)
          .doc(FirebaseService.currentUserEmail)
          .collection(Collections.CHATS)
          .doc(roomId)
          .update({ChatDocumentField.VISIBILITY: false});
    }
  }

  //[METHOD]: TO DELETE MESSAGE FOR CURRENT USER ONLY
  static Future<void> deleteMessageForCurrentUserOnly(
      {required roomId, required List<String> messageIds}) async {
    for (final messageId in messageIds) {
      final Map<dynamic, dynamic> deletedBy = await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .collection(Collections.MESSAGES)
          .doc(messageId)
          .get()
          .then((value) => value[MessageDocumentField.DELETED_BY]);
      deletedBy[FirebaseService.currentUserEmail] = true;
      await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .collection(Collections.MESSAGES)
          .doc(messageId)
          .update({MessageDocumentField.DELETED_BY: deletedBy});
    }
  }

  //[METHOD]: TO DELETE MESSAGE FOR EVERYONE
  static Future<void> deleteMessageForEveryOne(
      {required roomId, required List<String> messageIds}) async {
    for (final messageId in messageIds) {
      await _fStore
          .collection(Collections.CHAT_DB)
          .doc(roomId)
          .collection(Collections.MESSAGES)
          .doc(messageId)
          .update({MessageDocumentField.DELETED_FOR_EVERYONE: true});
    }
  }

  //[METHODS]: TO FORWARD MESSAGES TO CHATS
  static Future<void> forwardTextMessageToRoom(
      {required String roomId, required String message}) async {
    //Sending Message
    final encryptedMessage = EncryptionService.encrypt(message);
    final messageId = UidGenerator.uniqueId;
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .collection(Collections.MESSAGES)
        .doc(messageId)
        .set({
      MessageDocumentField.MESSAGE_ID: messageId,
      MessageDocumentField.SENDER: FirebaseService.currentUserEmail,
      MessageDocumentField.CONTENT: encryptedMessage,
      MessageDocumentField.DATE: dateOfSending,
      MessageDocumentField.TIME: timeOfSending,
      MessageDocumentField.TIME_STAMP: timeStamp,
      MessageDocumentField.TYPE: MessageType.TEXT,
      MessageDocumentField.DELETED_BY: {},
      MessageDocumentField.DELETED_FOR_EVERYONE: false,
      MessageDocumentField.FORWARDED_MESSAGE: true,
    });

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).update({
      ChatDBDocumentField.LAST_MESSAGE: encryptedMessage,
      ChatDBDocumentField.LAST_MESSAGE_TIME: timeOfSending,
      ChatDBDocumentField.LAST_MESSAGE_DATE: dateOfSending,
      ChatDBDocumentField.LAST_MESSAGE_TYPE: MessageType.TEXT,
      ChatDBDocumentField.LAST_MESSAGE_SEEN: {
        FirebaseService.currentUserEmail: true
      },
      ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP: timeStamp,
    });
  }

  static Future<void> forwardTextMessageToFriend(
      {required String friendEmail,
      required String roomId,
      required String message}) async {
    //Sending Message
    await FirebaseService.forwardTextMessageToRoom(
        roomId: roomId, message: message);

    //Setting visibility as true for current user chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
    //Setting visibility as true for friends chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(friendEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
  }

  static Future<void> forwardImagesToRoom({
    required String roomId,
    required List<String> imageUrls,
    required String? message,
  }) async {
    List<String> encryptedUrl = [];
    for (String url in imageUrls)
      encryptedUrl.add(EncryptionService.encrypt(url));

    final encryptedMessage =
        message != null ? EncryptionService.encrypt(message) : null;
    final messageId = UidGenerator.uniqueId;
    final timeStamp = DateTime.now();
    final timeOfSending = DateFormat.jm().format(timeStamp);
    final dateOfSending = DateFormat.yMMMMEEEEd().format(timeStamp);

    await _fStore
        .collection(Collections.CHAT_DB)
        .doc(roomId)
        .collection(Collections.MESSAGES)
        .doc(messageId)
        .set({
      MessageDocumentField.MESSAGE_ID: messageId,
      MessageDocumentField.SENDER: FirebaseService.currentUserEmail,
      MessageDocumentField.IMAGES: encryptedUrl,
      MessageDocumentField.CONTENT: encryptedMessage,
      MessageDocumentField.DATE: dateOfSending,
      MessageDocumentField.TIME: timeOfSending,
      MessageDocumentField.TIME_STAMP: timeStamp,
      MessageDocumentField.TYPE: MessageType.IMAGE,
      MessageDocumentField.DELETED_BY: {},
      MessageDocumentField.DELETED_FOR_EVERYONE: false,
      MessageDocumentField.FORWARDED_MESSAGE: true,
    });

    await _fStore.collection(Collections.CHAT_DB).doc(roomId).update({
      ChatDBDocumentField.LAST_MESSAGE: encryptedMessage,
      ChatDBDocumentField.LAST_MESSAGE_TIME: timeOfSending,
      ChatDBDocumentField.LAST_MESSAGE_DATE: dateOfSending,
      ChatDBDocumentField.LAST_MESSAGE_TYPE: MessageType.IMAGE,
      ChatDBDocumentField.LAST_MESSAGE_SEEN: {
        FirebaseService.currentUserEmail: true
      },
      ChatDBDocumentField.LAST_MESSAGE_TIME_STAMP: timeStamp,
    });
  }

  //METHOD: to send photos to friend
  static Future<void> forwardImagesToFriend({
    required String friendEmail,
    required String roomId,
    required List<String> imageUrls,
    required String? message,
  }) async {
    await FirebaseService.forwardImagesToRoom(
        roomId: roomId, imageUrls: imageUrls, message: message);

    //Setting visibility as true for current user chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(FirebaseService.currentUserEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});

    //Setting visibility as true for friends chat reference.
    await _fStore
        .collection(Collections.USERS)
        .doc(friendEmail)
        .collection(Collections.CHATS)
        .doc(roomId)
        .update({ChatDocumentField.VISIBILITY: true});
  }

  static Future<void> forwardMessagesToOneToOneChat(
      List<Message> messages, Chat chat) async {
        for(final message in messages){
          switch(message.type){
            case MessageType.TEXT: await FirebaseService.forwardTextMessageToFriend(friendEmail: chat.friendEmail as String, roomId: chat.roomId, message: message.content as String); break;
            case MessageType.IMAGE: await FirebaseService.forwardImagesToFriend(friendEmail: chat.friendEmail as String, roomId: chat.roomId, imageUrls: message.imageUrls as List<String>, message: message.content); break;
            default: assert(false);
          }
        }
      }

  static Future<void> forwardMessagesToGroupChat(
      List<Message> messages, Chat chat) async {
        for(final message in messages){
          switch(message.type){
            case MessageType.TEXT: await FirebaseService.forwardTextMessageToRoom(roomId: chat.roomId, message: message.content as String); break;
            case MessageType.IMAGE: await FirebaseService.forwardImagesToRoom(roomId: chat.roomId, imageUrls: message.imageUrls as List<String>, message: message.content); break;
            default: assert(false);
          }
        }
      }

  static Future<void> forwardMessages(
      {required final List<Message> messages,
      required final List<Chat> chats}) async {
    for (final chat in chats) {
      switch (chat.type) {
        case ChatType.ONE_TO_ONE:
          await FirebaseService.forwardMessagesToOneToOneChat(messages, chat);
          break;
        case ChatType.GROUP:
          await FirebaseService.forwardMessagesToGroupChat(messages, chat);
          break;
        default:
          assert(false);
      }
    }
  }

  static get currentUserStreamToAllChats => _fStore
      .collection(Collections.USERS)
      .doc(FirebaseService.currentUserEmail)
      .collection(Collections.CHATS)
      .snapshots();
}

class Collections {
  static const USERS = 'users';
  static const FRIENDS = 'friends';
  static const FRIEND_REQUESTS = 'friend_requests';
  static const CHATS = 'chats';
  static const CHAT_DB = 'chat_db';
  static const MESSAGES = 'messages';
}

class UserDocumentField{
  static const ABOUT = 'about';
  static const DISPLAY_NAME = 'display_name';
  static const EMAIL = 'email';
  static const PROFILE_IMAGE = 'profile_image';
  static const SEARCH_NAME = 'search_name';
}

class FriendRequestDocumentField{
  static const SENDER_EMAIL = 'sender_email';
  static const TIME = 'time';
  static const DATE = 'date';
}

class FriendsDocumentField{
  static const EMAIL = 'email';
}

class ChatDocumentField{
  static const ROOM_ID = 'room_id';
  static const VISIBILITY = 'visibility';
  static const SHOW_AFTER = 'show_after';
}

class ChatDBDocumentField{
  static const ROOM_ID = 'room_id';
}

class MessageDocumentField{
  static const MESSAGE_ID = 'id';
  static const CONTENT = 'content';
  static const SENDER = 'sender';
  static const TIME = 'time';
  static const DATE = 'date';
  static const TIME_STAMP = 'time_stamp';
  static const TYPE = 'type';
}

class MessageType{
  static const TEXT = 'text';
  static const IMAGE = 'image';
  static const VIDEO = 'video';
  static const AUDIO = 'audio';
}
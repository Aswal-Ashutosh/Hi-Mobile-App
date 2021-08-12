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
  static const ONLINE = 'online';
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
  static const REMOVED = 'removed';
  static const REMOVED_AT = 'removed_at';
  static const DELETED = 'deleted';
}


class ChatDBDocumentField{
  static const GROUP_NAME = 'group_name';
  static const GROUP_IMAGE = 'group_image';
  static const GROUP_CREATED_AT = 'created_at';
  static const GROUP_ADMIN = 'group_admin';
  static const GROUP_ABOUT = 'about_group';
  static const ROOM_ID = 'room_id';
  static const TYPE = 'type';
  static const LAST_MESSAGE = 'last_message';
  static const LAST_MESSAGE_TIME = 'last_message_time';
  static const LAST_MESSAGE_DATE = 'last_message_date';
  static const LAST_MESSAGE_SEEN = 'last_message_seen';
  static const LAST_MESSAGE_TYPE = 'last_message_type';
  static const LAST_MESSAGE_TIME_STAMP = 'last_message_time_stamp';
  static const MEMBERS = 'members';
  static const DELETED = 'deleted';
}

class MessageDocumentField{
  static const MESSAGE_ID = 'id';
  static const CONTENT = 'content';
  static const IMAGES = 'images';
  static const SENDER = 'sender';
  static const TIME = 'time';
  static const DATE = 'date';
  static const TIME_STAMP = 'time_stamp';
  static const TYPE = 'type';
}

class MessageType{
  static const TEXT = 'TEXT';
  static const IMAGE = 'IMAGE';
  static const VIDEO = 'VIDEO';
  static const AUDIO = 'AUDIO';
}

class ChatType{
  static const ONE_TO_ONE = 'ONE_TO_ONE';
  static const GROUP = 'GROUP';
}
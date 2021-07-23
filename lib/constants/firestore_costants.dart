class Collections {
  static const USERS = 'users';
  static const FRIENDS = 'friends';
  static const FRIEND_REQUESTS = 'friend_requests';
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
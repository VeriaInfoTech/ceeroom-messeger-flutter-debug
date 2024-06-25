class ApiHelper {
  final String _apiUri = "https://messenger-core.ceeroom.com/ver4/";
  final String _webSocketUri =
      "wss://messenger-service.ceeroom.com/interaction/?tokenData=";

  String get apiUri => _apiUri;

  String webSocketUri(String token) {
    return _webSocketUri + token;
  }

  /// auth
  final String verifyOtp = "user/authentication/mobile/verify";
  final String mobile = "user/authentication/mobile/request";
  final String login = "user/authentication/login";
  final String userProfile = "user/profile/view";
  final String logout = "user/authentication/logout";
  final String updateUserProfile = "user/profile/update";

  /// profile
  final String getMessengerProfile = "messenger/profile/get";
  final String uploadAvatar = "user/avatar/upload";
  final String updateMessengerProfile = "messenger/profile/update";

  /// call
  final String requestCall = "messenger/call/request";
  final String updateCall = "messenger/call/update";

  /// chat
  final String startChat = "messenger/chat/start";
  final String replyChat = "messenger/chat/reply";
  final String updateChat = "messenger/chat/update";
  final String getChats = "messenger/chat/get";
  final String uploadMedia = "media/private/add-private";
  final String downloadMedia = "media/private/stream";

  /// group
  final String createGroup = "messenger/group/create";

  /// contacts
  final String initContacts = "messenger/profile/contact/initial";

  final String updateDeviceToken = "user/profile/device-token";
  final String settingVersionCheck = "content/setting/version";
}

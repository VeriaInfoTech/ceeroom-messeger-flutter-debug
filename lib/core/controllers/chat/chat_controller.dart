import 'dart:async';
import 'dart:convert';

import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/message_media_model.dart';
import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/core/services/fcm/chat/firestore.dart';
import 'package:CeeRoom/core/services/local_storage/media.dart';
import 'package:CeeRoom/core/services/web_api/chat_api.dart';
import 'package:CeeRoom/core/services/web_api/messenger_profile_api.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  Rxn<List<MessageModel>> messages = Rxn<List<MessageModel>>();
  List<MessageModel> tempMessages = [];
  Rxn<List<ChatModel>> chats = Rxn<List<ChatModel>>();
  Rx<bool> getChatsServerErr = false.obs;
  ChatModel? chat;
  Rx<bool> getChatMessagesServerErr = false.obs;
  final ChatApi _chatApi = ChatApi();
  final MessengerProfileApi _profileApi = MessengerProfileApi();
  List<ChatModel> allChats = [];
  String chatDocId = '';
  late ChatFireStoreService fscService;
  bool canAdd = false;
  List<MessageModel> fscData = [];
  Timer? updateTimer;
  Rx<bool> canSendMsg = false.obs;
  List<MessageMediaModel> downloadedMedia = [];
  bool isChatStarter = false;
  final ChatSocketController _socketCtl = ChatSocketController();
  Rxn<bool> getChatLoading = Rxn<bool>(true);

  void connectToSocket(
    String token,
    VoidCallback onSuccess,
    int userId,
    int? contactId,
  ) {
    try {
      _socketCtl.init(
        token,
        (event) {
          onMessageReceived(userId, contactId, event);
        },
      );
      _socketCtl.startConnection();
      onSuccess.call();
    } catch (e) {
      getChatMessagesServerErr.value = true;
      getChatLoading.value = null;
    }
  }

  Future<void> initFireStore({
    List<int>? users,
    bool isPrivateChat = true,
  }) async {
    try {
      if (isPrivateChat) {
        chatDocId = 'chat-';
        if (chat != null) {
          users = chat!.users!;
        }
        users!.sort();
        chatDocId += users.join('-');
      } else {
        chatDocId = 'group-${chat!.conversationId}';
      }

      fscService = ChatFireStoreService(chatDocId);
      fscData = await fscService.getData();
      if (fscData.isEmpty) {
        for (final m in messages.value!) {
          await fscService.add(m);
        }
      }
    } catch (e) {
      debugPrint('Init firestore');
      debugPrint('==================');
      debugPrint('Somethings went wrong: $e');
      debugPrint('==================');
    }
  }

  Future<void> getChats({bool clear = true}) async {
    try {
      if (clear) {
        chats.value = null;
      }else{
        // final SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setBool('from_notification', false);
      }
      getChatsServerErr.value = false;
      final resp = await _profileApi.getProfile(section: 'chat');
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        chats.value = getAllChats(api.data);
      } else {
        if (clear) {
          getChatsServerErr.value = true;
        }
      }
    } catch (e) {
      if (clear) {
        getChatsServerErr.value = true;
      }
    }
  }

  Future<void> getChatMessages(String slug, {bool clear = true}) async {
    try {
      getChatLoading.value = true;
      if (clear) {
        messages.value = null;
        getChatMessagesServerErr.value = false;
      }
      final resp = await _chatApi.getChats(slug);
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        chat = ChatModel.fromJson(api.data);
        messages.value = chat!.message ?? [];
        getChatLoading.value = false;
        checkMediaDownloaded();
      } else {
        if (clear) {
          getChatMessagesServerErr.value = true;
        }
        getChatLoading.value = null;
      }
    } catch (e) {
      if (clear) {
        getChatMessagesServerErr.value = true;
      }
      getChatLoading.value = null;
    }
  }

  void cancelDownload(
    MessageModel message,
  ) {
    message.mediaInfo!.downloadProgress = null;
    message.mediaInfo!.subscription?.cancel();
    message.mediaInfo!.client?.close();
    update(['message_${message.id}']);
  }

  Future<void> startChat(
    MessageModel message,
    int userId, {
    bool addMessage = true,
  }) async {
    try {
      if (addMessage) {
        messages.value!.insert(0, message);
        messages.refresh();
      }
      _socketCtl.channel!.sink.add(
        SocketService.jsonFormat(
          action: SocketService.startChat,
          data: {
            "user_id": userId,
            "message": message.toJson(),
          },
        ),
      );
      message.status = 1;
    } catch (e) {
      message.status = 2;
    } finally {
      update(['message_${message.id}']);
    }
  }

  Future<void> updateChat(MessageModel message) async {
    try {
      _socketCtl.channel!.sink.add(
        SocketService.jsonFormat(
          action: SocketService.updateChat,
          data: message.toJson(),
        ),
      );
    } catch (e) {
      debugPrint('Update chat');
      debugPrint('======================');
      debugPrint('Something went wrong: $e');
      debugPrint('======================');
    }
  }

  // Future<void> updateChat(MessageModel message) async {
  //   try {
  //     await _chatApi.updateChat(message);
  //   } catch (e) {
  //     debugPrint('Update chat');
  //     debugPrint('======================');
  //     debugPrint('Something went wrong: $e');
  //     debugPrint('======================');
  //     updateChat(message);
  //   }
  // }

  Future<void> updateSeenUsers(int userId) async {
    if (chat != null) {
      for (final msg in messages.value!) {
        try {
          if (msg.userId != userId &&
              !msg.seen!.contains(userId) &&
              !isEqualList(
                msg.seen,
                chat!.users,
                isOrderImportant: false,
              )) {
            final seen = [...msg.seen!, userId];
            // final dId = fscData
            //     .firstWhereOrNull((element) => element.id == msg.id)
            //     ?.docId;
            final newMsg = msg;
            newMsg.seen = seen;
            updateChat(newMsg);
            // _socketCtl.channel.sink.add(
            //   SocketService.jsonFormat(
            //     action: SocketService.updateChat,
            //     data: newMsg.toJson(),
            //   ),
            // );
            // if (dId != null) {
            //   fscService.update(dId, newMsg);
            // }
            // updateChat(newMsg);
          }
        } catch (e) {
          debugPrint('Update user seen');
          debugPrint('==================');
          debugPrint('Somethings went wrong: $e');
          debugPrint('==================');
        }
      }
    }
  }

  void addMessage(MessageModel msg) {
    if (messages.value == null) {
      return;
    }
    messages.value!.insert(0, msg);
    messages.refresh();
  }

  void sendMessage({
    required MessageModel msg,
    required int userId,
    required int? contactId,
    bool addMessage = true,
  }) {
    if (messages.value == null) {
      return;
    }
    if (messages.value!.isEmpty) {
      isChatStarter = true;
      startChat(msg, contactId!, addMessage: addMessage);
    } else {
      replyChat(
        slug: chat!.slug!,
        conversationId: chat!.conversationId!,
        message: msg,
        userId: chat!.profile == null ? contactId! : userId,
        addMessage: addMessage,
      );
    }
  }

  Future<void> replyChat({
    required String slug,
    required String conversationId,
    required MessageModel message,
    required int userId,
    bool addToFireStore = true,
    bool addMessage = true,
  }) async {
    try {
      message.status = 0;
      if (addMessage) {
        messages.value!.insert(0, message);
        messages.refresh();
      }
      if (!_socketCtl.isSocketConnected) {
        message.status = 2;
      } else {
        _socketCtl.channel!.sink.add(
          SocketService.jsonFormat(
            action: SocketService.replyChat,
            data: {
              "slug": slug,
              "conversation_id": conversationId,
              "user_id": userId,
              "message": message.toJson()
            },
          ),
        );
        message.status = 1;
      }
    } finally {
      update(['message_${message.id}']);
    }
  }

  void onMessageReceived(int userId, int? contactId, dynamic event) {
    Map<String, dynamic> resp = jsonDecode(event);
    switch (resp['action']) {
      case SocketService.replyChat:
        final chat = ChatModel.fromJson(resp['data']);
        final msg = chat.message![0];
        if (chat.profile != null) {
          if (!chat.users!.contains(msg.userId)) {
            return;
          }
        } else if (contactId != msg.userId) {
          return;
        }
        messages.value!.insert(0, msg);
        messages.refresh();
        final seen = [...msg.seen!, userId];
        final newMsg = msg;
        newMsg.seen = seen;
        updateChat(newMsg);
        break;
      case SocketService.startChat:
        chat = ChatModel.fromJson(resp['data']);
        if (isChatStarter) {
          return;
        }
        final msg = chat!.message![0];
        if (chat!.profile != null) {
          if (!chat!.users!.contains(msg.userId)) {
            return;
          }
        } else if (contactId != msg.userId) {
          return;
        }
        messages.value!.insert(0, msg);
        messages.refresh();
        final seen = [...msg.seen!, userId];
        final newMsg = msg;
        newMsg.seen = seen;
        updateChat(newMsg);
        break;
      case SocketService.updateChat:
        chat = ChatModel.fromJson(resp['data']);
        messages.value = chat!.message;
        break;
    }
  }

  void checkMediaDownloaded() {
    downloadedMedia = MediaLocalStorage.getMedias();
    for (final m in messages.value!) {
      if (m.mediaInfo != null) {
        m.mediaInfo!.path = downloadedMedia
            .firstWhereOrNull((element) => element.id == m.mediaInfo!.id)
            ?.path;
      }
    }
  }

  // void onMessageReceived(int userId) {
  //   fscService.listenToReceivedMessages(
  //     onAdd: (msg) {
  //       if (canAdd ||
  //           messages.value!.isEmpty ||
  //           (chat != null &&
  //               chat!.profile != null &&
  //               messages.value!.length > 1)) {
  //         if (msg.userId != userId && !msg.seen!.contains(userId)) {
  //           if (!messages.value!.any((element) => element.id == msg.id)) {
  //             messages.value!.insert(0, msg);
  //             messages.refresh();
  //           }
  //
  //           final seen = [...msg.seen!, userId];
  //           final newMsg = msg;
  //           newMsg.seen = seen;
  //           fscService.update(msg.docId!, newMsg);
  //           updateChat(newMsg);
  //         }
  //       } else {
  //         tempMessages.add(msg);
  //         if (tempMessages.length == messages.value!.length) {
  //           canAdd = true;
  //         }
  //       }
  //     },
  //     onModify: (msg) {
  //       if (msg.userId == userId) {
  //         messages.value!.firstWhere((element) => element.id == msg.id).seen =
  //             msg.seen;
  //         update(['message']);
  //       }
  //     },
  //   );
  // }

  void searchChats({int? userId, required String val}) {
    if (val == '') {
      chats.value = allChats;
    } else {
      List<ChatModel> searchedChats = [];
      for (ChatModel item in allChats) {
        if (item.profile != null) {
          if (item.profile!.name!.toLowerCase().contains(val.toLowerCase())) {
            searchedChats.add(item);
          }
        } else {
          final isReceiver = userId != item.userId;
          if (isReceiver) {
            if (item.profiles![0].name!
                .toLowerCase()
                .contains(val.toLowerCase())) {
              searchedChats.add(item);
            }
          } else {
            if (item.profiles![1].name!.contains(val)) {
              searchedChats.add(item);
            }
          }
        }
      }
      chats.value = searchedChats;
    }
  }

  void updateChatsPeriodically() {
    updateTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (messages.value != null && messages.value!.isNotEmpty) {
          update(['message_list']);
        }
      },
    );
  }

  bool isGroupChat({ChatModel? chat}) {
    chat ??= this.chat;
    return chat != null && chat.profile != null;
  }

  void closeSocket() {
    _socketCtl.isManuallyClosed = true;
    _socketCtl.channel!.sink.close();
  }

  void stopAllUploadAndDownload() {
    for (final m in messages.value ?? []) {
      if (m.mediaInfo != null) {
        if (m.mediaInfo!.cancelToken != null) {
          m.mediaInfo!.cancelToken!.cancel();
        }
        if (m.mediaInfo!.client != null) {
          m.mediaInfo!.client!.close();
          m.mediaInfo!.subscription!.cancel();
        }
      }
    }
  }

  void removeMessage(String id) {
    messages.value!.removeWhere(
      (element) => element.id == id,
    );
    messages.refresh();
  }
}

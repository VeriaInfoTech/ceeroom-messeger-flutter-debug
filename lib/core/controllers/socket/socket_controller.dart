import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:CeeRoom/core/services/web_api/api_helper.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

Future<IOWebSocketChannel?> _connectChatSocket(String token) async {
  try {
    final ApiHelper api = ApiHelper();
    final socket = await WebSocket.connect(api.webSocketUri(token));
    return IOWebSocketChannel(socket);
  } catch (e) {
    return null;
  }
}

IOWebSocketChannel _connect(String token) {
  final ApiHelper api = ApiHelper();

  return IOWebSocketChannel.connect(
    Uri.parse(
      api.webSocketUri(token),
    ),
  );
}

class SocketController {
  late IOWebSocketChannel channel;

  Future<void> connect(String token) async {
    channel = _connect(token);
    await channel.ready;
  }
}

class GeneralSocketController extends GetxController {
  late IOWebSocketChannel channel;
  late VoidCallback onGroupCreate;

  Future<void> connect(String token) async {
    channel = _connect(token);
    await channel.ready;
    listen();
  }

  void listen() {
    channel.stream.listen(
      (event) {
        Map<String, dynamic> resp = jsonDecode(event);
        switch (resp['action']) {
          case SocketService.createGroup:
            onGroupCreate.call();
            break;
        }
      },
    );
  }
}

class ChatSocketController {
  late String token;
  late void Function(dynamic) onReceivedMsg;

  void init(String token, void Function(dynamic) onReceivedMsg) {
    this.token = token;
    this.onReceivedMsg = onReceivedMsg;
  }

  IOWebSocketChannel? channel;

  bool isManuallyClosed = false;
  bool isSocketConnected = false;
  Timer? timer;

  void _handleLostConnection() {
    isSocketConnected = false;
    timer = Timer.periodic(
      const Duration(seconds: 3),
      (t) {
        startConnection();
      },
    );
  }

  Future<void> startConnection() async {
    try {
      channel = await _connectChatSocket(token);
      if (channel == null) {
        return;
      }
      isSocketConnected = true;
      timer?.cancel();
      channel!.stream.listen(
        (event) {
          onReceivedMsg.call(event);
        },
        onError: (error) {
          _handleLostConnection();
        },
        onDone: () {
          if (!isManuallyClosed) {
            _handleLostConnection();
          }
        },
      );
    } catch (e) {
      debugPrint("Something went wrong on connect to socket: $e");
    }
  }
}

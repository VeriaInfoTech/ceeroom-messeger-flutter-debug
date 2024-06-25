import 'dart:async';

import 'package:CeeRoom/core/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatFireStoreService {
  final String docId;
  late DocumentReference chats;
  late CollectionReference messages;
  late StreamSubscription<QuerySnapshot> subscription;

  ChatFireStoreService(this.docId) {
    chats = FirebaseFirestore.instance.collection('chats').doc(docId);
    messages = chats.collection('messages');
  }

  void listenToReceivedMessages({
    required ValueChanged<MessageModel> onAdd,
    required ValueChanged<MessageModel> onModify,
  }) {
    try {
      subscription = messages.snapshots().listen(
        (snapShot) {
          snapShot.docChanges.forEach(
            (change) {
              if (change.type == DocumentChangeType.modified) {
                Map<String, dynamic> data =
                    change.doc.data() as Map<String, dynamic>;
                final m = MessageModel.fromJson(data);
                onModify.call(m);
              } else if (change.type == DocumentChangeType.added) {
                Map<String, dynamic> data =
                    change.doc.data() as Map<String, dynamic>;
                final m = MessageModel.fromJson(data);
                onAdd.call(m);
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Listen on receive new chat');
      debugPrint('======================');
      debugPrint('Something went wrong: $e');
      debugPrint('======================');
    }
  }

  Future<void> add(MessageModel msg) async {
    try {
      final mDoc = messages.doc();
      msg.docId = mDoc.id;
      mDoc.set(msg.toJson());
    } catch (e) {
      debugPrint('Add to fire store');
      debugPrint('======================');
      debugPrint('Something went wrong: $e');
      debugPrint('======================');
    }
  }

  // Future<void> delete() async {
  //   await messages.doc().delete();
  // }

  Future<void> update(String docId, MessageModel newMsg) async {
    try {
      messages.doc(docId).update(newMsg.toJson());
    } catch (e) {
      debugPrint('Update fire store');
      debugPrint('======================');
      debugPrint('Something went wrong: $e');
      debugPrint('======================');
    }
  }

  Future<List<MessageModel>> getData() async {
    try {
      QuerySnapshot querySnapshot = await messages.get();
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      return getAllMessages(allData);
    } catch (e) {
      debugPrint('Get data from socket');
      debugPrint('==================');
      debugPrint('Somethings went wrong: $e');
      debugPrint('==================');
      return [];
    }
  }

  Future<void> closeSocket() async{
    await subscription.cancel();
  }
}

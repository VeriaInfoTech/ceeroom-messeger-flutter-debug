import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/socket/socket_controller.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/services/web_api/socket.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  RxList<ContactModel> selectedMembers = <ContactModel>[].obs;
  Rx<bool> createGroupLoading = false.obs;
  late GeneralSocketController socketCtl;
  Rxn<Map<String, List<ContactModel>>> createGPContacts =
      Rxn<Map<String, List<ContactModel>>>();

  Future<void> createGroup(ChatModel chat, VoidCallback onGroupCreated) async {
    try {
      createGroupLoading.value = true;
      socketCtl.channel.sink.add(
        SocketService.jsonFormat(
          action: SocketService.createGroup,
          data: chat.createGroupToJson(),
        ),
      );
      onGroupCreated.call();

      /// pop to choose group member
      Get.back();

      /// pop to contact list
      Get.back();

      /// pop to chat list
      Get.back();
      Get.delete<GroupController>();
    } catch (e) {
      BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
    } finally {
      createGroupLoading.value = false;
    }
  }

  void searchContact(
    String val,
    Map<String, List<ContactModel>> allContacts,
  ) {
    if (val == '') {
      createGPContacts.value = allContacts;
    } else {
      List<ContactModel> contacts = [];
      List<ContactModel> searchedContacts = [];
      for (final cv in allContacts.values) {
        contacts.addAll(cv);
      }
      for (final c in contacts) {
        if (c.name != null) {
          if (c.name!.contains(val)) {
            searchedContacts.add(c);
          }
        }
      }
      createGPContacts.value = sortingContacts(searchedContacts);
    }
  }
}

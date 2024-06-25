import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/core/services/local_storage/contact.dart'
    as contact_local;
import 'package:CeeRoom/core/services/local_storage/user.dart';
import 'package:CeeRoom/core/services/web_api/messenger_profile_api.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactController extends GetxController {
  Rxn<Map<String, List<ContactModel>>> sortedContacts =
      Rxn<Map<String, List<ContactModel>>>();
  late Map<String, List<ContactModel>> allContacts;
  Rx<bool> getContactServerErr = false.obs;
  Rx<bool> startInitContacts = false.obs;
  Rxn<ContactModel> selectedContact = Rxn<ContactModel>();
  final MessengerProfileApi _profileApi = MessengerProfileApi();
  List<ContactModel> allInviteContacts = [];
  Rx<List<ContactModel>> searchedInviteContacts = Rx<List<ContactModel>>([]);
  Rxn<String> selectedInvitePhone = Rxn<String>();

  Future<void> getContacts() async {
    try {
      searchedInviteContacts.value = allInviteContacts;
      sortedContacts.value = null;
      getContactServerErr.value = false;
      final resp = await _profileApi.getProfile(section: "contact");
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        sortedContacts.value = {};
        final contacts = getAllContacts(api.data);
        if (contacts.isNotEmpty) {
          contacts.sort((a, b) => a.name!.compareTo(b.name!));
          for (ContactModel item in contacts) {
            String firstLetter = item.name!.substring(0, 1).toUpperCase();
            sortedContacts.value![firstLetter] ??= [];
            sortedContacts.value![firstLetter]!.add(item);
            searchedInviteContacts.value.removeWhere(
                (contact) => contact.inviteMobile!.contains(item.mobile));
          }
          allInviteContacts = searchedInviteContacts.value;
        }
      } else {
        getContactServerErr.value = true;
      }
    } catch (e) {
      getContactServerErr.value = true;
    }
  }

  Future<void> initialContacts(
    String contacts,
    bool needSort,
    bool needSnackBar,
  ) async {
    try {
      sortedContacts.value = null;
      getContactServerErr.value = false;
      final resp = await _profileApi.initialContacts(contacts: contacts);
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        startInitContacts.value = false;
        contact_local.Contact.storeContacts(true);
        if (needSnackBar) {
          BaseWidget.snackBar(
            Variable.stringVar.contactsUpdatedSuccessfully.tr,
          );
        }
        if (needSort) {
          sortedContacts.value = sortingContacts(
            getAllContacts(api.data['contact']),
          );
        }
      } else {
        getContactServerErr.value = true;
      }
    } catch (e) {
      if (needSnackBar) {
        BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
      }
      getContactServerErr.value = true;
    } finally {
      startInitContacts.value = false;
    }
  }

  Future<void> getPhoneContact({
    bool needSort = true,
    bool needSnackBar = false,
  }) async {
    try {
      getContactServerErr.value = false;
      final user = LocalUser.getUser()!;
      if (await FlutterContacts.requestPermission()) {
        startInitContacts.value = true;
        final phoneContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withAccounts: true,
        );
        List<String> phoneNumbers = [];
        List<String> invitePhones = [];
        for (Contact item in phoneContacts) {
          invitePhones = [];
          String name =
              "${item.name.first}${item.name.middle.isEmpty ? "" : " ${item.name.middle}"} ${item.name.last}";
          for (Phone phones in item.phones) {
            if (prettyPhoneNumber(phones.number) != user.mobile &&
                prettyPhoneNumber(phones.normalizedNumber) != user.mobile) {
              String number = phones.normalizedNumber == ''
                  ? phones.number
                  : phones.normalizedNumber;
              phoneNumbers.add(prettyPhoneNumber(number));
              invitePhones.add(prettyPhoneNumber(number));
            }
          }
          if (item.phones.isNotEmpty) {
            if (!searchedInviteContacts.value.any((element) => element.name == name)) {
              searchedInviteContacts.value.add(ContactModel(name: name, inviteMobile: invitePhones));
            }
          }
        }
        allInviteContacts = searchedInviteContacts.value;
        await initialContacts(phoneNumbers.join(','), needSort, needSnackBar);
      } else {
        sortedContacts.value = {};
      }
    } catch (e) {
      if (needSnackBar) {
        BaseWidget.snackBar(Variable.stringVar.errorHappened.tr);
      }
      getContactServerErr.value = true;
    } finally {
      startInitContacts.value = false;
    }
  }

  void searchInviteContact(String val) {
    if (val == '') {
      searchedInviteContacts.value = allInviteContacts;
    } else {
      List<ContactModel> searchedContacts = [];
      for (final c in allInviteContacts) {
        if (c.name != null) {
          if (c.name!.toLowerCase().contains(val.toLowerCase())) {
            searchedContacts.add(c);
          }
        }
      }
      searchedInviteContacts.value = searchedContacts;
    }
  }

  void searchContact(String val) {
    if (val == '') {
      sortedContacts.value = allContacts;
    } else {
      List<ContactModel> contacts = [];
      List<ContactModel> searchedContacts = [];
      for (final cv in allContacts.values) {
        contacts.addAll(cv);
      }
      for (final c in contacts) {
        if (c.name != null) {
          if (c.name!.toLowerCase().contains(val.toLowerCase())) {
            searchedContacts.add(c);
          }
        }
      }
      sortedContacts.value = sortingContacts(searchedContacts);
    }
  }
}

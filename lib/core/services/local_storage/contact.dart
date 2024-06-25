import 'package:get_storage/get_storage.dart';

class Contact{
  static final contactBox = GetStorage();

  static bool hasData() {
      return contactBox.read('contact') != null;
  }

  static storeContacts(bool contact) {
    contactBox.write('contact', contact);
  }

  static bool? getContacts() {
    try {
      return hasData()
          ? contactBox.read('contact')
          : false;
    } catch (_) {
      return false;
    }
  }
}
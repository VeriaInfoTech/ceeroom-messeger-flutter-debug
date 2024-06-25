import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/massenger_profile.dart';
import 'package:CeeRoom/core/services/web_api/messenger_profile_api.dart';
import 'package:get/get.dart';

class MessengerProfileController extends GetxController {
  Rxn<MessengerProfile> profile = Rxn<MessengerProfile>();
  Rx<bool> getProfileServerErr = false.obs;
  final MessengerProfileApi _profileApi = MessengerProfileApi();
  bool checkIsNewChatServerErr = false;

  Future<void> getProfile() async {
    try {
      getProfileServerErr.value = false;
      profile.value = null;
      final resp = await _profileApi.getProfile();
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        profile.value = MessengerProfile.fromJson(api.data);
      } else {
        getProfileServerErr.value = true;
      }
    } catch (e) {
      getProfileServerErr.value = true;
    }
  }

  Future<String?> isNewChat(int contactId, int userId) async {
    try {
      checkIsNewChatServerErr = false;
      await getProfile();
      if (profile.value == null) {
        checkIsNewChatServerErr = true;
        return null;
      }
      if (profile.value!.userChat!.contains(contactId)) {
        String? slug;
        for(final ch in profile.value!.chat!){
          if(ch.profile != null){
            continue;
          }
          if(ch.users![ch.userId == userId ? 1 : 0] == contactId){
            slug = ch.slug!;
          }
        }
        return slug;
      }
      return null;
    } catch (e) {
      checkIsNewChatServerErr = true;
      return null;
    }
  }
}

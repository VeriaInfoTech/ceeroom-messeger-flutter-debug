import 'package:CeeRoom/core/middleware/middleware.dart';
import 'package:CeeRoom/core/models/api.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/services/web_api/messenger_profile_api.dart';
import 'package:get/get.dart';

class CallController extends GetxController{
  Rxn<List<CallModel>> calls = Rxn<List<CallModel>>();
  Rx<bool> getCallServerErr = false.obs;
  final MessengerProfileApi _profileApi = MessengerProfileApi();
  List<CallModel> allCalls = [];
  Rx<int> expandedCall =  Rx<int>(-1);

  void searchCalls({int? userId, required String val}) {
    if (val == '') {
      calls.value = allCalls;
    } else {
      List<CallModel> searchedCalls = [];
      for (CallModel item in allCalls) {
        final isReceiver = userId != item.sender!.id;
        if (isReceiver) {
          if (item.sender!.name!.toLowerCase().contains(val.toLowerCase())) {
            searchedCalls.add(item);
          }
        } else {
          for (var receiver in item.receiver!) {
            if (receiver.name!.toLowerCase().contains(val.toLowerCase())) {
              searchedCalls.add(item);
            }
          }
        }
      }
      calls.value = searchedCalls;
    }
  }




  Future<void> getCalls() async {
    try {
      getCallServerErr.value = false;
      calls.value = null;
      final resp = await _profileApi.getProfile(section: 'call');
      Api api = Middleware.resultValidation(resp);
      if (api.result!) {
        calls.value = getAllCalls(api.data);
      } else {
        getCallServerErr.value = true;
      }
    } catch (e) {
      getCallServerErr.value = true;
    }
  }
}
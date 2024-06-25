import 'dart:math';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String version = '0.0.12';
String marketPlace = 'appstore';
String buildNumber = '12';
String applicant = 'messenger';

String missed = "MISSED";
String video = 'VIDEO';
String voice = 'VOICE';

late Map<String, dynamic> callConfiguration;

void setCallConfiguration(String server) {
  callConfiguration = {
    'iceServers': [
      {
        'urls':
  [
  'stun:stun.1und1.de:3478',
  'stun:stun.gmx.net:3478',
  'stun:stun.l.google.com:19302',
  'stun:stun1.l.google.com:19302',
  'stun:stun2.l.google.com:19302',
  'stun:stun3.l.google.com:19302',
  'stun:stun4.l.google.com:19302',
  'stun:23.21.150.121:3478',
  'stun:iphone-stun.strato-iphone.de:3478',
  'stun:numb.viagenie.ca:3478',
  'stun:stun.12connect.com:3478',
  'stun:stun.12voip.com:3478',
  'stun:stun.1und1.de:3478',
  'stun:stun.2talk.co.nz:3478',
  'stun:stun.2talk.com:3478',
  'stun:stun.3clogic.com:3478',
  'stun:stun.3cx.com:3478',
  'stun:stun.a-mm.tv:3478',
  'stun:stun.aa.net.uk:3478',
  'stun:stun.acrobits.cz:3478',
  'stun:stun.actionvoip.com:3478',
  'stun:stun.advfn.com:3478',
  'stun:stun.aeta-audio.com:3478',
  'stun:stun.aeta.com:3478',
  'stun:stun.altar.com.pl:3478',
  'stun:stun.annatel.net:3478',
  'stun:stun.antisip.com:3478',
  'stun:stun.arbuz.ru:3478',
  'stun:stun.avigora.fr:3478',
  'stun:stun.awa-shima.com:3478',
  'stun:stun.b2b2c.ca:3478',
  'stun:stun.bahnhof.net:3478',
  'stun:stun.barracuda.com:3478',
  'stun:stun.bluesip.net:3478',
  'stun:stun.bmwgs.cz:3478',
  'stun:stun.botonakis.com:3478',
  'stun:stun.budgetsip.com:3478',
  'stun:stun.cablenet-as.net:3478',
  'stun:stun.callromania.ro:3478',
  'stun:stun.callwithus.com:3478',
  'stun:stun.chathelp.ru:3478',
  'stun:stun.cheapvoip.com:3478',
  'stun:stun.ciktel.com:3478',
  'stun:stun.cloopen.com:3478',
  'stun:stun.comfi.com:3478',
  'stun:stun.comtube.com:3478',
  'stun:stun.comtube.ru:3478',
  'stun:stun.cope.es:3478',
  'stun:stun.counterpath.com:3478',
  'stun:stun.counterpath.net:3478',
  'stun:stun.datamanagement.it:3478',
  'stun:stun.dcalling.de:3478',
  'stun:stun.demos.ru:3478',
  'stun:stun.develz.org:3478',
  'stun:stun.dingaling.ca:3478',
  'stun:stun.doublerobotics.com:3478',
  'stun:stun.dus.net:3478',
  'stun:stun.easycall.pl:3478',
  'stun:stun.easyvoip.com:3478',
  'stun:stun.ekiga.net:3478',
  'stun:stun.epygi.com:3478',
  'stun:stun.etoilediese.fr:3478',
  'stun:stun.faktortel.com.au:3478',
  'stun:stun.freecall.com:3478',
  'stun:stun.freeswitch.org:3478',
  'stun:stun.freevoipdeal.com:3478',
  'stun:stun.gmx.de:3478',
  'stun:stun.gmx.net:3478',
  'stun:stun.gradwell.com:3478',
  'stun:stun.halonet.pl:3478',
  'stun:stun.hellonanu.com:3478',
  'stun:stun.hoiio.com:3478',
  'stun:stun.hosteurope.de:3478',
  'stun:stun.ideasip.com:3478',
  'stun:stun.infra.net:3478',
  'stun:stun.internetcalls.com:3478',
  'stun:stun.intervoip.com:3478',
  'stun:stun.ipcomms.net:3478',
  'stun:stun.ipfire.org:3478',
  'stun:stun.ippi.fr:3478',
  'stun:stun.ipshka.com:3478',
  'stun:stun.irian.at:3478',
  'stun:stun.it1.hr:3478',
  'stun:stun.ivao.aero:3478',
  'stun:stun.jumblo.com:3478',
  'stun:stun.justvoip.com:3478',
  'stun:stun.kanet.ru:3478',
  'stun:stun.kiwilink.co.nz:3478',
  'stun:stun.l.google.com:19302',
  'stun:stun.linea7.net:3478',
  'stun:stun.linphone.org:3478',
  'stun:stun.liveo.fr:3478',
  'stun:stun.lowratevoip.com:3478',
  'stun:stun.lugosoft.com:3478',
  'stun:stun.lundimatin.fr:3478',
  'stun:stun.magnet.ie:3478',
  'stun:stun.mgn.ru:3478',
  'stun:stun.mit.de:3478',
  'stun:stun.mitake.com.tw:3478',
  'stun:stun.miwifi.com:3478',
  'stun:stun.modulus.gr:3478',
  'stun:stun.myvoiptraffic.com:3478',
  'stun:stun.mywatson.it:3478',
  'stun:stun.nas.net:3478',
  'stun:stun.neotel.co.za:3478',
  ]
      }
    ]
  };
}

bool isPersianText(String text) {
  if (RegExp(r'[\u0600-\u06FF\uFB50-\uFDFF\uFE70-\uFEFF]+').hasMatch(text)) {
    return true;
  }
  return false;
}

bool checkPasswordRegex(String password) {
  final rgx =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#%])[A-Za-z\d!@#%]{8,}$');

  return rgx.hasMatch(password);
}

Map<String, List<ContactModel>> sortingContacts(List<ContactModel> contacts) {
  Map<String, List<ContactModel>> sortedContacts = {};
  contacts.sort((a, b) => a.name!.compareTo(b.name!));
  for (ContactModel item in contacts) {
    String firstLetter = item.name!.substring(0, 1).toUpperCase();
    sortedContacts[firstLetter] ??= [];
    sortedContacts[firstLetter]!.add(item);
  }
  return sortedContacts;
}

Map<String, String> prettyTimeStamp(
  int timeStamp, {
  bool selfGenerated = false,
}) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
    selfGenerated ? timeStamp : timeStamp * 1000,
  );
  String dateView = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  String hour =
      dateTime.hour < 10 ? "0${dateTime.hour}" : dateTime.hour.toString();
  String minute =
      dateTime.minute < 10 ? "0${dateTime.minute}" : dateTime.minute.toString();

  return {"time": "$hour:$minute", "date": dateView};
}

bool isEqualList(
  List<dynamic>? list1,
  List<dynamic>? list2, {
  bool isOrderImportant = true,
}) {
  if (list1 == null || list2 == null) {
    return false;
  }
  if (isOrderImportant) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  } else {
    Set<dynamic> set1 = Set.from(list1.toList());
    Set<dynamic> set2 = Set.from(list2.toList());

    return set1.length == set2.length && set1.containsAll(set2);
  }
}

String prettyPhoneNumber(String number) {
  number = number.replaceAll(' ', '');
  number = number.replaceAll('(', '');
  number = number.replaceAll(')', '');
  number = number.replaceAll('-', '');
  if(number.startsWith('+')){
    return number;
  } else if (number.startsWith('00')) {
    return number.replaceFirst('00', '+');
  } else if (number.startsWith('09')) {
    return "+98${number.substring(1)}";
  }else {
    return "+1$number";
  }
  // number = number.replaceAll(' ', '');
  // if (number.contains('+98') && !number[3].contains('0')) {
  //   return number;
  // } else if (number[0].contains('0')) {
  //   return "+98${number.substring(1)}";
  // } else {
  //   return number;
  // }
}

void logout(BuildContext context) {
  BaseWidget.generalDialog(
    context: context,
    icon: Variable.imageVar.exit,
    title: Variable.stringVar.confirmLogout.tr,
    desc: Variable.stringVar.areYouSureToLogout.tr,
    confirmBtnTxt: Variable.stringVar.logout.tr,
    iconColor: Variable.colorVar.smoky,
    confirmBtnOnTap: () {
      Get.put(UserController()).logout();
    },
  );
}

String generateRandomString(int length) {
  Random random = Random();
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(
        random.nextInt(chars.length),
      ),
    ),
  );
}

BorderRadius messageBorderRadius(bool fromFriend, BuildContext context){
  return BorderRadius.only(
    bottomLeft: Radius.circular(
      fromFriend ? 0 : ResponsiveUtil.ratio(context, 24.0),
    ),
    topLeft: Radius.circular(
      ResponsiveUtil.ratio(context, 24.0),
    ),
    topRight: Radius.circular(
      ResponsiveUtil.ratio(context, 24.0),
    ),
    bottomRight: Radius.circular(
      fromFriend ? ResponsiveUtil.ratio(context, 24.0) : 0,
    ),
  );
}

// class MiuiPermissions {
//   static const MethodChannel _channel = MethodChannel('miui_permissions');
//
//   static Future<void> openPermissionsEditor() async {
//     try {
//       await _channel.invokeMethod('openPermissionsEditor');
//     } on PlatformException catch (e) {
//       print("Failed to open permissions editor: '${e.message}'.");
//     }
//   }
// }

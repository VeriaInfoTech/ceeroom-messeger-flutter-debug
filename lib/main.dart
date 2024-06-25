import 'dart:io';

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/i18n/locale_string.dart';
import 'package:CeeRoom/core/services/fcm/firebase.dart';
import 'package:CeeRoom/utils/app_shared_preferences.dart';
import 'package:CeeRoom/utils/incoming_call.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

const debug = true;
bool appWasClosed = false;
dynamic currentCall;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    AppFirebase().initFirebase();
    WidgetsBinding.instance.addObserver(this);
    /// TODO => Kerloper => check this
    checkActiveCalls(isFromStartApp: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      locale: const Locale('en', 'US'),
      title: 'CeeRoom',
      theme: ThemeData(
        primaryColor: Variable.colorVar.primaryColor,
        brightness: Brightness.light,
        canvasColor: Colors.transparent,
        fontFamily: "PoppinsLatin",
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      onGenerateRoute: Routes.onGenerateRoute,
      builder: (context, widget) {
        return ResponsiveWrapper.builder(
          SafeArea(child: widget!),
          maxWidth: ResponsiveUtil.portraitMaxWidth,
          maxWidthLandscape: ResponsiveUtil.landScapeMaxWidth,
          background: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          breakpoints: [
            const ResponsiveBreakpoint.resize(200.0, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800.0, name: TABLET),
            const ResponsiveBreakpoint.resize(800.0, name: DESKTOP),
          ],
          breakpointsLandscape: [
            const ResponsiveBreakpoint.resize(200.0, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(800.0, name: TABLET),
            const ResponsiveBreakpoint.resize(800.0, name: DESKTOP),
          ],
        );
      },
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {

    // Kerloper => add bottom code for check lifecycle state of app in incoming call (for handle incoming call in lock screen ios)
    final AppSharedPreferences pref = AppSharedPreferences();
    pref.saveLifeCycleState(state.name??'unknown');

    debugPrint("Kerloper log => life cycle in ${Platform.isIOS?'IOS':'Android'} is  ${state.name}");
    ///TODO: Kerloper => for ios must use switch in actionCallToggleAudioSession and actionCallAccept in FlutterCallkitIncoming.onEvent
    if(Platform.isAndroid){
      if (state == AppLifecycleState.resumed && !callShowed) {
      debugPrint("Kerloper log => check life cycle in ${Platform.isIOS?'IOS':'Android'}.");
        checkActiveCalls();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

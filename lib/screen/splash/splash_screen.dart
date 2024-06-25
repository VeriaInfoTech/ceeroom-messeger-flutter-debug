import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/main_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/gradient_screen.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserController userController = Get.put(UserController());
  final MainController mainController = Get.put(MainController());
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {

    ///TODO: complete this section for handle exception of check version in incoming call and chat via notification when app is closed
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final bool openedFromNotification = prefs.getBool('from_notification') ?? false;
    // if (openedFromNotification) {
    //   await prefs.setBool('from_notification', false);
    //   userController.navigationDirectory();
    // }else{
      mainController.versionCheck(() {
        userController.splashServerError.value = true;
      }, context).then((value) {
        if (value) {
          userController.checkUserLogin();
        }
      });
    // }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () {
            return GradientScreen(
              child: userController.splashServerError.value
                  ? Center(
                      child: RetryButton(
                        onTap: () {
                          userController.splashServerError.value = false;
                          _init();
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              Variable.imageVar.logo,
                              width: ResponsiveUtil.ratio(_context, 328.0),
                            ),
                          ),
                        ),
                        const AppLoading(color: Colors.white),
                        SizedBox(height: ResponsiveUtil.ratio(_context, 12.0)),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

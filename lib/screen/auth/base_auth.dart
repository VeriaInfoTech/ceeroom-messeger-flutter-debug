import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseAuth extends StatelessWidget {
  final Widget child;
  final String headerTitle;
  final Widget? headerDescription;
  final bool hasBack;
  final bool isLogin;

  final UserController _userCtl = Get.put(UserController());

  BaseAuth({
    Key? key,
    required this.child,
    required this.headerTitle,
    this.headerDescription,
    this.hasBack = false,
    this.isLogin = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Variable.colorVar.lightGray,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        ResponsiveUtil.ratio(context, 60.0),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          hasBack
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    right: ResponsiveUtil.ratio(context, 40.0),
                                    left: ResponsiveUtil.ratio(context, 16.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _userCtl.cancelTimer();
                                      Get.back();
                                    },
                                    child: Icon(
                                      Icons.keyboard_arrow_left,
                                      size: ResponsiveUtil.ratio(context, 30.0),
                                    ),
                                  ),
                                )
                              : SizedBox(width: ResponsiveUtil.ratio(context, 60.0)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: ResponsiveUtil.ratio(context, 14.0)),
                              Text(
                                headerTitle,
                                style: TextStyle(
                                  color: Variable.colorVar.boldBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: ResponsiveUtil.ratio(context, 20.0),
                                ),
                              ),
                              SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
                              isLogin
                                  ? Text(
                                      Variable.stringVar
                                          .helloWelcomeBackToOurAccount.tr,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: ResponsiveUtil.ratio(context, 14.0),
                                      ),
                                    )
                                  : headerDescription!,
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtil.ratio(context, 50.0)),
                      isLogin
                          ? ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                  ResponsiveUtil.ratio(context, 60.0),
                                ),
                              ),
                              child: Image.asset(
                                Variable.imageVar.loginImage,
                                height: ResponsiveUtil.ratio(context, 355.0),
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              ),
                            )
                          : Image.asset(
                              Variable.imageVar.verifyOtpImage,
                              width: ResponsiveUtil.ratio(context, 280.0),
                              height: ResponsiveUtil.ratio(context, 350.0)
                            ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: ResponsiveUtil.ratio(context, 354.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Variable.colorVar.lightGray,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                          ResponsiveUtil.ratio(context, 60.0)
                      ),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:CeeRoom/core/base/base_variable.dart';
// import 'package:CeeRoom/core/controllers/main_controller.dart';
// import 'package:CeeRoom/widgets/main_app_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class BaseAuth extends StatelessWidget {
//   final Widget child;
//   final String image;
//   final double imageSize;
//   final String type;
//
//   const BaseAuth({
//     Key? key,
//     required this.child,
//     required this.image,
//     required this.imageSize,
//     this.type = 'login',
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           alignment: Alignment.bottomCenter,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 type == 'verifyOtp'
//                     ? MainAppBar(
//                         title: Variable.stringVar.oTPVerification.tr,
//                       )
//                     : const SizedBox(),
//                 Image.asset(
//                   image,
//                   width: MainController.ratio * imageSize,
//                   height: MainController.ratio * imageSize,
//                 ),
//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   height: MainController.ratio * 400.0,
//                   padding: EdgeInsets.symmetric(
//                     vertical: MainController.ratio * 10.0,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(MainController.ratio * 50.0),
//                       topRight: Radius.circular(MainController.ratio * 50.0),
//                     ),
//                     gradient: LinearGradient(
//                       colors: [
//                         Variable.colorVar.loginGradiant1,
//                         Variable.colorVar.loginGradiant2,
//                         Variable.colorVar.loginGradiant1
//                       ],
//                       transform: const GradientRotation(-118.6),
//                     ),
//                   ),
//                   child: child,
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

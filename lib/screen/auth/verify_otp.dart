import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/screen/auth/base_auth.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class VerifyOtp extends StatelessWidget {
  final String mobile;
  final UserController _userCtl = Get.put(UserController());
  late PinTheme defaultPinTheme;
  late BuildContext _context;

  VerifyOtp({Key? key, required this.mobile}) : super(key: key) {
    _userCtl.startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    defaultPinTheme = PinTheme(
      width: ResponsiveUtil.ratio(context, 70.0),
      height: ResponsiveUtil.ratio(context, 55.0),
      textStyle: TextStyle(
        fontSize: ResponsiveUtil.ratio(context, 24.0),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Variable.colorVar.gray),
        borderRadius: BorderRadius.circular(
          ResponsiveUtil.ratio(context, 16.0),
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        _userCtl.cancelTimer();
        return true;
      },
      child: BaseAuth(
        headerTitle: Variable.stringVar.enterOTP.tr,
        headerDescription: _headerDescription(),
        isLogin: false,
        hasBack: true,
        child: _child(),
      ),
    );
  }

  Widget _child() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtil.ratio(_context, 30.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ResponsiveUtil.ratio(_context, 50.0),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              onChanged: (pin) {
                if (pin.length == 6) {
                  _userCtl.otpCode = pin;
                  _userCtl.verifyOtp(mobile.replaceAll(' ', ''), _context);
                }
              },
            ),
          ),
          SizedBox(height: ResponsiveUtil.ratio(_context, 40.0)),
          _resend(),
          SizedBox(height: ResponsiveUtil.ratio(_context, 40.0)),
          Obx(
            () {
              return _userCtl.loadingForOtp.value
                  ? const Center(child: AppLoading())
                  : const SizedBox();
            },
          )
        ],
      ),
    );
  }

  Widget _resend() {
    return Obx(
      () {
        int resendTime = _userCtl.resendSeconds.toInt();
        String seconds =
            "00:${resendTime < 10 ? "0${resendTime.toString()}" : resendTime.toString()}";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: ResponsiveUtil.ratio(_context, 354.0),
              height: ResponsiveUtil.ratio(_context, 16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtil.ratio(_context, 20.0),
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: ResponsiveUtil.ratio(
                    _context,
                    _userCtl.resendContainerWidth.toDouble(),
                  ),
                  height: ResponsiveUtil.ratio(_context, 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtil.ratio(_context, 20.0),
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: ResponsiveUtil.ratio(
                        _context,
                        0.5,
                      ),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Variable.colorVar.primaryColor.withOpacity(0.05),
                        Variable.colorVar.primaryColor,
                      ],
                      stops: const [0.2, 0.8],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtil.ratio(_context, 8.0)),
            resendTime > 0
                ? Text(
                    seconds,
                    style: TextStyle(
                      color: Variable.colorVar.primaryColor,
                      fontSize: ResponsiveUtil.ratio(_context, 14.0),
                    ),
                  )
                : InkWell(
                    child: Text(
                      Variable.stringVar.resendCode.tr,
                      style: TextStyle(
                        color: Variable.colorVar.primaryColor,
                        fontSize: ResponsiveUtil.ratio(_context, 14.0),
                      ),
                    ),
                    onTap: () {
                      _userCtl.cancelTimer();
                      _userCtl.loginViaMobile(mobile, _context, isResend: true);
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _headerDescription() {
    return Row(
      children: [
        Text(
          Variable.stringVar.codeHasBeenSentTo.tr,
          style: TextStyle(
            color: Variable.colorVar.darkGrayish,
            fontSize: ResponsiveUtil.ratio(_context, 14.0),
          ),
        ),
        SizedBox(width: ResponsiveUtil.ratio(_context, 4.0)),
        Text(
          mobile,
          style: TextStyle(
            color: Variable.colorVar.darkGrayish,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtil.ratio(_context, 14.0),
          ),
        )
      ],
    );
  }
}

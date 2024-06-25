import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/screen/auth/base_auth.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_button.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginViaUserName extends StatelessWidget {
  final UserController _userCtl = Get.put(UserController());
  late AppTextField _username;
  late AppTextField _password;
  late BuildContext _context;

  LoginViaUserName({Key? key}) : super(key: key) {
    _username = AppTextField(
      hint: Variable.stringVar.username.tr,
      keyboardType: TextInputType.text,
      borderColor: Variable.colorVar.gray,
      focusBorderColor: Variable.colorVar.primaryColor,
      hintTextColor: Variable.colorVar.gray,
    );
    _password = AppTextField(
      hint: Variable.stringVar.password.tr,
      keyboardType: TextInputType.text,
      borderColor: Variable.colorVar.gray,
      focusBorderColor: Variable.colorVar.primaryColor,
      hintTextColor: Variable.colorVar.gray,
      obscure: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return BaseAuth(
      headerTitle: Variable.stringVar.loginAccount.tr,
      child: _child(),
    );
  }

  Widget _child() {
    return AppPadding(
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtil.ratio(_context, 40.0)),
          _username,
          SizedBox(height: ResponsiveUtil.ratio(_context, 20.0)),
          _password,
          SizedBox(height: ResponsiveUtil.ratio(_context, 40.0)),
          Obx(
            () => _userCtl.loadingForLogin.value
                ? const AppLoading()
                : AppButton(
                    title: Variable.stringVar.login.tr,
                    onTap: () {
                        _userCtl.loginViaUsername(
                          userName: _username.controller!.text,
                          password: _password.controller!.text,
                          context: _context,
                        );
                    },
                  ),
          ),
          SizedBox(height: ResponsiveUtil.ratio(_context, 20.0)),
          InkWell(
            onTap: () {
              Get.offAllNamed(Routes.loginViaMobile);
            },
            child: Text(
              Variable.stringVar.loginViaPhoneNumber.tr,
              style: TextStyle(
                color: Variable.colorVar.gray,
                fontSize: ResponsiveUtil.ratio(_context, 14.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

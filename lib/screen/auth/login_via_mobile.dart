import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/screen/auth/base_auth.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_drop_down.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginViaMobile extends StatelessWidget {
  final UserController _userCtl = Get.put(UserController());
  final _focusNode = FocusNode();
  late BuildContext _context;

  LoginViaMobile({Key? key}) : super(key: key) {
    _userCtl.initCounty();
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.ratio(_context, 16.0),
            vertical: ResponsiveUtil.ratio(_context, 46.0),
          ),
          child: Column(
            children: [
              _textField(),
              SizedBox(height: ResponsiveUtil.ratio(_context, 20.0)),
              InkWell(
                onTap: () {
                  Get.offAllNamed(Routes.loginViaUsername);
                },
                child: Text(
                  Variable.stringVar.loginViaUsername.tr,
                  style: TextStyle(
                    color: Variable.colorVar.gray,
                    fontSize: ResponsiveUtil.ratio(_context, 14.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () {
            return _userCtl.loadingForLogin.value
                ? const AppLoading()
                : const SizedBox();
          },
        )
      ],
    );
  }

  Widget _textField() {
    return Form(
      child: TextFormField(
        focusNode: _focusNode,
        maxLength: 10,
        style: TextStyle(
          color: Colors.black,
          fontSize: ResponsiveUtil.ratio(_context, 14.0),
        ),
        decoration: InputDecoration(
          isDense: true,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.ratio(_context, 8.0),
            ),
            child: _dropDown(),
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: ResponsiveUtil.ratio(_context, 28.0),
            minHeight: ResponsiveUtil.ratio(_context, 28.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 20.0),
            ),
            borderSide: BorderSide(
              color: Variable.colorVar.primaryColor,
              width: ResponsiveUtil.ratio(_context, 1.0),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 20.0),
            ),
            borderSide: BorderSide(
              color: Colors.red,
              width: ResponsiveUtil.ratio(_context, 1.0),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 20.0),
            ),
            borderSide: BorderSide(
              color: Colors.red,
              width: ResponsiveUtil.ratio(_context, 1.0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 20.0),
            ),
            borderSide: BorderSide(
              color: Variable.colorVar.gray,
              width: ResponsiveUtil.ratio(_context, 1.0),
            ),
          ),
          hintText: Variable.stringVar.phoneNumber.tr,
          hintStyle: TextStyle(
            color: Variable.colorVar.heavyGray,
            fontWeight: FontWeight.w400,
            fontSize: ResponsiveUtil.ratio(_context, 14.0),
          ),
          counterText: "",
          errorStyle: const TextStyle(
            height: 0,
          ),
        ),
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          if (value.length == 10) {
            _focusNode.unfocus();
            _userCtl.loginViaMobile(value, _context);
          }
        },
      ),
    );
  }

  Widget _dropDown() {
    return Obx(
      () {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: ResponsiveUtil.ratio(_context, 100.0),
              child: AppDropDown<String>(
                hasBorder: false,
                filled: false,
                value: _userCtl.selectedCountry.split(',')[1],
                items: _userCtl.countryFlag
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: DropDownButtonItem(
                          item: e,
                          isFlag: true,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  _userCtl.changeCountry(value!);
                },
              ),
            ),
            Text(
              _userCtl.selectedCountry.value.split(',')[2],
              style: TextStyle(
                fontSize: ResponsiveUtil.ratio(_context, 16.0),
              ),
            )
          ],
        );
      },
    );
  }
}

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_button.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:CeeRoom/widgets/edit_avatar.dart';
import 'package:CeeRoom/widgets/edit_profile_avatar.dart';
import 'package:CeeRoom/widgets/gender_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Register extends StatelessWidget {
  late AppTextField _firstName;
  late AppTextField _lastName;
  final ProfileController _profileCtl = Get.put(ProfileController());
  final UserController _userCtl = Get.put(UserController());
  final _formKey = GlobalKey<FormState>();
  late BuildContext _context;

  Register({Key? key}) : super(key: key) {
    _lastName = AppTextField(
      hint: Variable.stringVar.lastName.tr,
      label: Variable.stringVar.lastName.tr,
      keyboardType: TextInputType.text,
      borderColor: Variable.colorVar.heavyGray,
      dispose: false,
      validation: true,
    );
    _firstName = AppTextField(
      hint: Variable.stringVar.firstName.tr,
      label: Variable.stringVar.firstName.tr,
      keyboardType: TextInputType.text,
      borderColor: Variable.colorVar.heavyGray,
      dispose: false,
      validation: true,
      nextFocusNode: _lastName.focusNode,
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _header(),
              _registerBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _firstName,
          SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
          _lastName,
          SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
          GenderField(
            backgroundColor: Variable.colorVar.primaryColor,
            borderColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _registerBox() {
    return Container(
      width: MediaQuery.of(_context).size.width,
      decoration: BoxDecoration(
        color: Variable.colorVar.lightGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            ResponsiveUtil.ratio(_context, 60.0),
          ),
        ),
      ),
      child: AppPadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveUtil.ratio(_context, 30.0)),
            Obx(
              () => _profileCtl.updateAvatarLoading.value
                  ? SizedBox(
                      width: ResponsiveUtil.ratio(_context, 100.0),
                      height: ResponsiveUtil.ratio(_context, 100.0),
                      child: const Center(
                        child: AppLoading(),
                      ),
                    )
                  : EditProfileAvatar(
                      avatar: _profileCtl.profile.value?.avatar ?? '',
                      isRegister: true,
                    ),
            ),
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
            _registerForm(),
            SizedBox(height: ResponsiveUtil.ratio(_context, 56.0)),
            _updateButton(),
            SizedBox(height: ResponsiveUtil.ratio(_context, 170.0)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: MediaQuery.of(_context).size.width,
      color: Colors.white,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveUtil.ratio(_context, 50.0)),
            Text(
              Variable.stringVar.welcomeToCeeroom.tr,
              style: TextStyle(
                color: Variable.colorVar.primaryColor,
                fontSize: ResponsiveUtil.ratio(_context, 24.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtil.ratio(_context, 14.0)),
            Text(
              Variable.stringVar.pleaseCompleteYourProfile.tr,
              style: TextStyle(
                color: Variable.colorVar.darkGrayish,
                fontSize: ResponsiveUtil.ratio(_context, 18.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtil.ratio(_context, 50.0)),
          ],
        ),
      ),
    );
  }

  Widget _updateButton() {
    return Obx(
      () => _profileCtl.updateProfileLoading.value
          ? const Center(
              child: AppLoading(),
            )
          : AppButton(
              title: Variable.stringVar.done.tr,
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  await _profileCtl.updateUserProfile(
                    {
                      "first_name": _firstName.controller!.text,
                      "last_name": _lastName.controller!.text,
                      'phone_number': _userCtl.user.mobile,
                      'email': _userCtl.user.email,
                      "gender": _profileCtl.userGender.value,
                    },
                    isRegister: true,
                    onSuccessRegister: () {
                      _userCtl.updateUser(
                        _userCtl.user.copyWith(
                          name: _profileCtl.profile.value!.name,
                        ),
                      );
                    },
                    context: _context,
                  );
                }
              },
            ),
    );
  }
}

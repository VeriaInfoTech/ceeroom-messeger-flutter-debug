import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_button.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:CeeRoom/widgets/gender_field.dart';
import 'package:CeeRoom/widgets/profile_header.dart';
import 'package:CeeRoom/widgets/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewProfileScreen extends StatelessWidget {
  final ProfileController _profileCtl = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();
  late AppTextField _firstName;
  late AppTextField _lastName;
  late AppTextField _phoneNumber;
  late AppTextField _email;
  late BuildContext _context;

  ViewProfileScreen({Key? key}) : super(key: key) {
    _init();
  }

  void _init() {
    _lastName = AppTextField(
      hint: Variable.stringVar.lastName.tr,
      label: Variable.stringVar.lastName.tr,
      keyboardType: TextInputType.text,
      dispose: false,
      validation: true,
    );
    _firstName = AppTextField(
      hint: Variable.stringVar.firstName.tr,
      label: Variable.stringVar.firstName.tr,
      keyboardType: TextInputType.text,
      dispose: false,
      validation: true,
      nextFocusNode: _lastName.focusNode,
    );
    _phoneNumber = AppTextField(
      hint: Variable.stringVar.phoneNumber.tr,
      label: Variable.stringVar.phoneNumber.tr,
      readOnly: true,
      dispose: false,
    );
    _email = AppTextField(
      hint: Variable.stringVar.email.tr,
      label: Variable.stringVar.email.tr,
      keyboardType: TextInputType.emailAddress,
      readOnly: true,
      dispose: false,
    );
    if (!_profileCtl.serverError.value) {
      _profileCtl.userGender.value = '';
      _profileCtl.updateTextField(
        controllers: {
          'first name': _firstName.controller!,
          'last name': _lastName.controller!,
          'phone number': _phoneNumber.controller!,
          'email': _email.controller!,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Obx(
                () => ProfileHeader(
                  avatar: _profileCtl.profile.value!.avatar,
                  name: _profileCtl.profile.value!.name ?? 'no Name',
                  phoneNumber: _profileCtl.profile.value!.mobile ?? '',
                  isEditProfile: true,
                ),
              ),
              _viewProfileForm(),
              const AppDivider(),
              ProfileItem(
                iconImage: Variable.imageVar.exit,
                title: Variable.stringVar.logOut.tr,
                onTap: () => logout(_context),
              ),
              // ProfileItem(
              //   iconImage: Variable.imageVar.trashBin,
              //   title: Variable.stringVar.deleteAccount.tr,
              //   onTap: () {},
              //   hasDivider: false,
              // ),
              SizedBox(height: ResponsiveUtil.ratio(context, 30.0)),
              _updateButton(),
              SizedBox(height: ResponsiveUtil.ratio(context, 20.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewProfileForm() {
    return AppPadding(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: ResponsiveUtil.ratio(_context, 12.0)),
            _firstName,
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
            _lastName,
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
            _phoneNumber,
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
            _email,
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
            GenderField(),
            SizedBox(height: ResponsiveUtil.ratio(_context, 24.0)),
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
              title: Variable.stringVar.save.tr,
              onTap: () async {
                if(!_profileCtl.updateAvatarLoading.value) {
                  if (_formKey.currentState!.validate()) {
                    await _profileCtl.updateUserProfile(
                      {
                        "first_name": _firstName.controller!.text,
                        "last_name": _lastName.controller!.text,
                        'phone_number': _phoneNumber.controller!.text,
                        'email': _email.controller!.text,
                        "gender": _profileCtl.userGender.value,
                      },
                      isRegister: false,
                    );
                  }
                }
              },
            ),
    );
  }

  Widget _gender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: ResponsiveUtil.ratio(_context, 8.0),
          ),
          child: Text(
            Variable.stringVar.gender.tr,
            style: TextStyle(
              color: Variable.colorVar.heavyGray,
              fontSize: ResponsiveUtil.ratio(_context, 14.0),
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveUtil.ratio(_context, 12.0),
        ),
        Row(
          children: [
            _genderItem(
              title: Variable.stringVar.male.tr,
              isChecked: false,
            ),
            SizedBox(width: ResponsiveUtil.ratio(_context, 50.0)),
            _genderItem(
              title: Variable.stringVar.female.tr,
              isChecked: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _genderItem({required String title, required bool isChecked}) {
    return InkWell(
      onTap: () {
        _profileCtl.userGender.value = title;
      },
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: title == _profileCtl.userGender.value
                ? Variable.colorVar.blackPearl
                : Variable.colorVar.grey,
            borderRadius: BorderRadius.circular(
              ResponsiveUtil.ratio(_context, 100.0),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            ResponsiveUtil.ratio(_context, 4.0),
            ResponsiveUtil.ratio(_context, 4.0),
            ResponsiveUtil.ratio(_context, 8.0),
            ResponsiveUtil.ratio(_context, 4.0),
          ),
          child: Row(
            children: [
              Container(
                width: ResponsiveUtil.ratio(_context, 28.0),
                height: ResponsiveUtil.ratio(_context, 28.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: title == _profileCtl.userGender.value
                    ? Icon(
                        Icons.check,
                        color: Variable.colorVar.blackPearl,
                        size: ResponsiveUtil.ratio(_context, 24.0),
                      )
                    : const SizedBox(),
              ),
              SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtil.ratio(_context, 14.0),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

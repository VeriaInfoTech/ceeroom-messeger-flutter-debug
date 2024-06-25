import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_back_button.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_loading.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  final ContactController _contactCtl = Get.put(ContactController());
  late BuildContext _context;

  SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            _header(),
            _syncContacts(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        AppPadding(
          child: Row(
            children: [
              const AppBackButton(),
              Expanded(
                child: Center(
                  child: Text(
                    Variable.stringVar.settings.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtil.ratio(_context, 20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtil.ratio(_context, 40.0)),
            ],
          ),
        ),
        const AppDivider(),
      ],
    );
  }

  Widget _syncContacts() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileItem(
                icon: Icons.sync,
                title: Variable.stringVar.syncContacts.tr,
                onTap: () {
                  _contactCtl.getPhoneContact(
                    needSort: false,
                    needSnackBar: true,
                  );
                },
                hasDivider: false,
              ),
            ),
            Obx(
              () => _contactCtl.startInitContacts.value
                  ? Row(
                      children: [
                        const AppLoading(),
                        SizedBox(width: ResponsiveUtil.ratio(_context, 20.0)),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
        const AppDivider()
      ],
    );
  }
}

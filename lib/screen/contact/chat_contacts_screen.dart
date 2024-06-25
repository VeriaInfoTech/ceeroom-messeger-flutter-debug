import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/services/local_storage/contact.dart'
    as contact_local;
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_empty_data.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/contact_header.dart';
import 'package:CeeRoom/widgets/contacts_list.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatContactsScreen extends StatelessWidget {
  final ContactController _contactCtl = Get.put(ContactController());
  late BuildContext _context;

  ChatContactsScreen({Key? key}) : super(key: key) {
    _init();
  }

  void _init() async {
    if (!contact_local.Contact.getContacts()!) {
      await _contactCtl.getPhoneContact();
    } else {
      await _contactCtl.getContacts();
    }
    _contactCtl.allContacts = _contactCtl.sortedContacts.value!;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ContactHeader(
              title: Variable.stringVar.newChat.tr,
              onSearch: (val) {
                if (!_contactCtl.getContactServerErr.value &&
                    _contactCtl.sortedContacts.value != null) {
                  _contactCtl.searchContact(val!);
                  _contactCtl.searchInviteContact(val);
                }
              },
            ),
            Expanded(
              child: Obx(
                () => _contactCtl.getContactServerErr.value
                    ? RetryButton(onTap: _init)
                    : _contactCtl.sortedContacts.value != null &&
                            _contactCtl.sortedContacts.value!.isEmpty &&
                            _contactCtl.searchedInviteContacts.value.isEmpty
                        ? AppEmptyData(
                            title: Variable.stringVar.contact.tr,
                            hasSubTitle: false,
                          )
                        : Column(
                            children: [
                              if (_contactCtl.sortedContacts.value != null) ...[
                                _groupSection(),
                                const AppDivider(),
                              ],
                              ContactsList(isChatContact: true),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupSection() {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.chooseGroupMembers);
      },
      child: AppPadding(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtil.ratio(_context, 10.0),
              ),
              decoration: BoxDecoration(
                color: Variable.colorVar.whiteSmoke,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                Variable.imageVar.group,
                fit: BoxFit.fill,
                color: Variable.colorVar.heavyGray,
                width: ResponsiveUtil.ratio(_context, 30.0),
                height: ResponsiveUtil.ratio(_context, 30.0),
              ),
            ),
            SizedBox(width: ResponsiveUtil.ratio(_context, 16.0)),
            Text(
              Variable.stringVar.newGroup.tr,
              style: TextStyle(
                color: Variable.colorVar.heavyGray,
                fontSize: ResponsiveUtil.ratio(_context, 16.0),
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

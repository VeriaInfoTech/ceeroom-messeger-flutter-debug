import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/services/local_storage/contact.dart'
    as contact_local;
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_empty_data.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_selected_contact.dart';
import 'package:CeeRoom/widgets/contact_header.dart';
import 'package:CeeRoom/widgets/contacts_list.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallContactScreen extends StatelessWidget {
  final ContactController _contactCtl = Get.put(ContactController());
  late BuildContext _context;

  CallContactScreen({Key? key}) : super(key: key) {
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
        body: SafeArea(
          child: Column(
            children: [
              ContactHeader(
                title: Variable.stringVar.newCall.tr,
                onSearch: (val) {
                  if (!_contactCtl.getContactServerErr.value &&
                      _contactCtl.sortedContacts.value != null) {
                    _contactCtl.searchContact(val!);
                    _contactCtl.searchInviteContact(val);
                  }
                },
              ),
              _callSection(),
              Obx(
                () => _contactCtl.getContactServerErr.value
                    ? Expanded(
                        child: RetryButton(onTap: _init),
                      )
                    : _contactCtl.sortedContacts.value != null &&
                            _contactCtl.sortedContacts.value!.isEmpty &&
                    _contactCtl.searchedInviteContacts.value.isEmpty
                        ? Expanded(
                            child: AppEmptyData(
                              title: Variable.stringVar.contact.tr,
                              hasSubTitle: false,
                            ),
                          )
                        : ContactsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callSection() {
    return Obx(
      () => _contactCtl.selectedContact.value != null
          ? Column(
              children: [
                AppPadding(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppSelectedContact(
                        avatar: _contactCtl.selectedContact.value!.avatar,
                        name: _contactCtl.selectedContact.value!.name!,
                        onTap: () {
                          _contactCtl.selectedContact.value = null;
                        },
                      ),
                      Row(
                        children: [
                          _callSectionBtn(
                            icon: Variable.imageVar.fillVideoCam,
                            onTap: () {
                              Get.toNamed(
                                Routes.videoCall,
                                arguments: {
                                  'contact': _contactCtl.selectedContact.value,
                                  'call_id': null,
                                },
                              );
                            },
                          ),
                          SizedBox(width: ResponsiveUtil.ratio(_context, 16.0)),
                          _callSectionBtn(
                            icon: Variable.imageVar.fillCall,
                            onTap: () {
                              Get.toNamed(
                                Routes.voiceCall,
                                arguments: {
                                  'contact': _contactCtl.selectedContact.value,
                                  'call_id': null,
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const AppDivider(),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _callSectionBtn({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtil.ratio(_context, 10.0),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Variable.colorVar.whiteSmoke,
        ),
        child: Image.asset(
          icon,
          color: Variable.colorVar.primaryColor,
          width: ResponsiveUtil.ratio(_context, 30.0),
          height: ResponsiveUtil.ratio(_context, 30.0),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

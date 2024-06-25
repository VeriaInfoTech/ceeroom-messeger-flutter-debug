import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/conatct_item_padding.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ContactsList extends StatelessWidget {
  final ContactController _contactCtl = Get.put(ContactController());
  final bool isChatContact;
  late BuildContext _context;

  ContactsList({
    Key? key,
    this.isChatContact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _contactCtl.sortedContacts.value == null
                  ? 9
                  : _contactCtl.sortedContacts.value!.entries.length,
              itemBuilder: (BuildContext context, int index) {
                return _contactCtl.sortedContacts.value == null
                    ? const ShimmerLoading()
                    : _contacts(
                        _contactCtl.sortedContacts.value!.entries
                            .toList()[index],
                      );
              },
            ),
            _contactCtl.sortedContacts.value != null
                ? _contactCtl.searchedInviteContacts.value.isNotEmpty
                    ? _inviteContacts()
                    : const SizedBox()
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _contacts(MapEntry<String, List<ContactModel>> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUtil.ratio(_context, 10.0)),
        AppPadding(
          child: Text(
            contacts.key,
            style: TextStyle(
              fontSize: ResponsiveUtil.ratio(_context, 14.0),
              fontWeight: FontWeight.bold,
              color: Variable.colorVar.mediumGray,
            ),
          ),
        ),
        const AppDivider(),
        ...List.generate(
          contacts.value.length,
          (index) => _contactItem(
            contact: contacts.value[index],
            hasDivider: index + 1 != contacts.value.length,
          ),
        )
      ],
    );
  }

  Widget _inviteContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppPadding(
          child: Text(
            Variable.stringVar.inviteToCeeRoom.tr,
            style: TextStyle(
              fontSize: ResponsiveUtil.ratio(_context, 14.0),
              fontWeight: FontWeight.bold,
              color: Variable.colorVar.mediumGray,
            ),
          ),
        ),
        const AppDivider(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _contactCtl.searchedInviteContacts.value.length,
          itemBuilder: (BuildContext context, int index) {
            return _inviteContactItem(
              contact: _contactCtl.searchedInviteContacts.value[index],
              hasDivider:
                  index + 1 != _contactCtl.searchedInviteContacts.value.length,
            );
          },
        ),
      ],
    );
  }

  Widget _inviteContactItem({
    required ContactModel contact,
    required bool hasDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (contact.inviteMobile!.length <= 1) {
              await launchUrl(Uri.parse(
                  'sms:${contact.inviteMobile![0]}${Platform.isAndroid ? '?' : '&'}body=${Variable.stringVar.inviteMessage.tr}'));
            } else {
              _contactCtl.selectedInvitePhone.value = contact.inviteMobile![0];
              BaseWidget.inviteDialog(
                name: contact.name!,
                confirmBtnOnTap: () async {
                  await launchUrl(Uri.parse(
                      'sms:${_contactCtl.selectedInvitePhone}${Platform.isAndroid ? '?' : '&'}body=${Variable.stringVar.inviteMessage.tr}'));
                  Get.back();
                },
                content: _inviteDialog(contact),
                context: _context,
              );
            }
          },
          child: ContactItemPadding(
            child: Column(
              children: [
                Row(
                  children: [
                    CacheImage(
                      contact.avatar,
                      // size: 40.0,
                    ),
                    SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
                    Expanded(
                      child: AppDynamicFontText(
                        text: contact.name!,
                        style: TextStyle(
                          fontSize: ResponsiveUtil.ratio(_context, 14.0),
                          fontWeight: FontWeight.bold,
                          color: Variable.colorVar.darkGray,
                        ),
                      ),
                    ),
                    Text(
                      Variable.stringVar.invite.tr,
                      style: TextStyle(
                        color: Variable.colorVar.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtil.ratio(_context, 12.0),
                      ),
                    )
                  ],
                ),
                SizedBox(height: ResponsiveUtil.ratio(_context, 10.0)),
              ],
            ),
          ),
        ),
        hasDivider
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtil.ratio(_context, 16.0),
                ),
                child: const AppDivider(),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _inviteDialog(ContactModel contact) {
    return SizedBox(
      height: ResponsiveUtil.ratio(_context, 130.0),
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: contact.inviteMobile!.length,
          itemBuilder: (BuildContext context, int index) {
            return Obx(
                  () => InkWell(
                onTap: () {
                  _contactCtl.selectedInvitePhone.value =
                  contact.inviteMobile![index];
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtil.ratio(_context, 12.0),
                    horizontal: ResponsiveUtil.ratio(_context, 8.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUtil.ratio(_context, 2.0),
                        ),
                        width: ResponsiveUtil.ratio(_context, 20.0),
                        height:
                        ResponsiveUtil.ratio(_context, 20.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width:
                            ResponsiveUtil.ratio(_context, 2.0),
                            color: _contactCtl.selectedInvitePhone
                                .value ==
                                contact.inviteMobile![index]
                                ? Variable.colorVar.primaryColor
                                : Variable.colorVar.gray,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child:
                        _contactCtl.selectedInvitePhone.value ==
                            contact.inviteMobile![index]
                            ? Container(
                          decoration: BoxDecoration(
                            color: Variable
                                .colorVar.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        )
                            : const SizedBox(),
                      ),
                      SizedBox(
                        width: ResponsiveUtil.ratio(_context, 8.0),
                      ),
                      Text(
                        contact.inviteMobile![index],
                        style: TextStyle(
                          color: Variable.colorVar.gray,
                          fontSize:
                          ResponsiveUtil.ratio(_context, 12.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },),
    );
  }

  Widget _contactItem({
    required ContactModel contact,
    required bool hasDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: isChatContact
              ? () {
                  Get.back();
                  Get.toNamed(
                    Routes.singleChat,
                    arguments: {'chat': null, 'contact': contact},
                  );
                }
              : () {
                  if (_contactCtl.selectedContact.value == contact) {
                    _contactCtl.selectedContact.value = null;
                  } else {
                    _contactCtl.selectedContact.value = contact;
                  }
                },
          child: ContactItemPadding(
            child: Column(
              children: [
                Row(
                  children: [
                    CacheImage(
                      contact.avatar,
                      // size: 40.0,
                    ),
                    SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppDynamicFontText(
                            text: contact.name!,
                            style: TextStyle(
                              fontSize: ResponsiveUtil.ratio(_context, 14.0),
                              fontWeight: FontWeight.bold,
                              color: Variable.colorVar.darkGray,
                            ),
                          ),
                          isChatContact
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: ResponsiveUtil.ratio(
                                        _context,
                                        4.0,
                                      ),
                                    ),
                                    AppDynamicFontText(
                                      text: contact.mobile!,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtil.ratio(
                                          _context,
                                          12.0,
                                        ),
                                        color: Variable.colorVar.gray,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    !isChatContact
                        ? Obx(
                            () => Container(
                              width: ResponsiveUtil.ratio(_context, 26.0),
                              height: ResponsiveUtil.ratio(_context, 26.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Variable.colorVar.primaryColor,
                                  width: ResponsiveUtil.ratio(_context, 2.0),
                                ),
                                color:
                                    _contactCtl.selectedContact.value == contact
                                        ? Variable.colorVar.primaryColor
                                        : Colors.white,
                                // color: Colors.white,
                              ),
                              child:
                                  _contactCtl.selectedContact.value == contact
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: ResponsiveUtil.ratio(
                                            _context,
                                            20.0,
                                          ),
                                        )
                                      : const SizedBox(),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
                SizedBox(height: ResponsiveUtil.ratio(_context, 10.0)),
              ],
            ),
          ),
        ),
        hasDivider
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtil.ratio(_context, 16.0),
                ),
                child: const AppDivider(),
              )
            : const SizedBox(),
      ],
    );
  }
}

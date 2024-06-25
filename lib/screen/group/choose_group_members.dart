import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/controllers/group/group_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_selected_contact.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/contact_header.dart';
import 'package:CeeRoom/widgets/floating_button.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseGroupMembers extends StatelessWidget {
  final ContactController _contactCtl = Get.put(ContactController());
  final GroupController _groupCtl = Get.put(GroupController());
  late BuildContext _context;

  ChooseGroupMembers({Key? key}) : super(key: key) {
    _groupCtl.createGPContacts.value = _contactCtl.allContacts;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            Get.delete<GroupController>();
            return true;
          },
          child: Column(
            children: [
              ContactHeader(
                title: Variable.stringVar.newGroup.tr,
                isGroup: true,
                subTitle: _subTitle(),
                onSearch: (val) {
                  if (!_contactCtl.getContactServerErr.value &&
                      _groupCtl.createGPContacts.value != null) {
                    _groupCtl.searchContact(val!, _contactCtl.allContacts);
                  }
                },
              ),
              _selectedMembersList(),
              Expanded(
                child: Obx(
                  () {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _groupCtl.createGPContacts.value == null
                          ? 9
                          : _groupCtl.createGPContacts.value!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _groupCtl.createGPContacts.value == null
                            ? const ShimmerLoading()
                            : _contacts(
                                _groupCtl.createGPContacts.value!.entries
                                    .toList()[index],
                              );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingButton(
          icon: Variable.imageVar.arrowRight,
          onTap: () {
            if (_groupCtl.selectedMembers.isEmpty) {
              BaseWidget.snackBar(
                Variable.stringVar.atLeastContactMustBeSelected.tr,
              );
            } else {
              Get.toNamed(Routes.createGroup);
            }
          },
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

  Widget _contactItem({
    required ContactModel contact,
    required bool hasDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (_groupCtl.selectedMembers.contains(contact)) {
              _groupCtl.selectedMembers.removeWhere(
                (element) => element == contact,
              );
            } else {
              _groupCtl.selectedMembers.add(contact);
            }
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtil.ratio(_context, 16.0),
              ResponsiveUtil.ratio(_context, 8.0),
              ResponsiveUtil.ratio(_context, 16.0),
              ResponsiveUtil.ratio(_context, 2.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CacheImage(
                      contact.avatar,
                      size: 40.0,
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
                    Obx(
                      () => Container(
                        width: ResponsiveUtil.ratio(_context, 26.0),
                        height: ResponsiveUtil.ratio(_context, 26.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Variable.colorVar.primaryColor,
                            width: ResponsiveUtil.ratio(_context, 2.0),
                          ),
                          color: _groupCtl.selectedMembers.contains(contact)
                              ? Variable.colorVar.primaryColor
                              : Colors.white,
                          // color: Colors.white,
                        ),
                        child: _groupCtl.selectedMembers.contains(contact)
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
                    ),
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

  Widget _selectedMembersList() {
    return Obx(
      () => _groupCtl.selectedMembers.isNotEmpty
          ? Column(
              children: [
                Container(
                  width: MediaQuery.of(_context).size.width,
                  height: ResponsiveUtil.ratio(_context, 100.0),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtil.ratio(_context, 10.0),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _groupCtl.selectedMembers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AppSelectedContact(
                        avatar: _groupCtl.selectedMembers[index].avatar,
                        name: _groupCtl.selectedMembers[index].name!,
                        onTap: () {
                          _groupCtl.selectedMembers.removeWhere(
                            (element) =>
                                element == _groupCtl.selectedMembers[index],
                          );
                        },
                      );
                    },
                  ),
                ),
                const AppDivider(),
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _subTitle() {
    return Obx(
      () {
        List<ContactModel> allContactsLength = [];
        if (_groupCtl.createGPContacts.value != null) {
          for (final v in _groupCtl.createGPContacts.value!.values.toList()) {
            allContactsLength.addAll(v);
          }
        }
        return Text(
          _groupCtl.selectedMembers.isEmpty ||
                  _groupCtl.createGPContacts.value == null
              ? Variable.stringVar.addMembers.tr
              : "${_groupCtl.selectedMembers.length} ${Variable.stringVar.of.tr} ${allContactsLength.length} ${Variable.stringVar.selected.tr}",
          style: TextStyle(
            fontSize: ResponsiveUtil.ratio(_context, 10.0),
            color: Colors.black,
          ),
        );
      },
    );
  }
}

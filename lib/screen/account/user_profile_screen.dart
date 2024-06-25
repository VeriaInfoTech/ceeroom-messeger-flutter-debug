import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/widgets/base_widget.dart';
import 'package:CeeRoom/widgets/profile_header.dart';
import 'package:CeeRoom/widgets/profile_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatelessWidget {
  ContactModel contact;

  UserProfileScreen({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ProfileHeader(
              avatar: contact.avatar ?? '',
              name: contact.name ?? 'no Name',
              phoneNumber: contact.mobile ?? '',
            ),
            ProfileItem(
              title: Variable.stringVar.muteNotification.tr,
              onTap: () {
                BaseWidget.snackBar(
                  Variable.stringVar.thisPartIsBeingImplemented.tr,
                );
              },
              iconImage: Variable.imageVar.notifications,
            ),
            ProfileItem(
              title: Variable.stringVar.block.tr,
              name: contact.name ?? 'no Name',
              onTap: () {
                BaseWidget.snackBar(
                  Variable.stringVar.thisPartIsBeingImplemented.tr,
                );
              },
              iconImage: Variable.imageVar.block,
            ),
            ProfileItem(
              title: Variable.stringVar.report.tr,
              name: contact.name ?? 'no Name',
              onTap: () {
                BaseWidget.snackBar(
                  Variable.stringVar.thisPartIsBeingImplemented.tr,
                );
              },
              iconImage: Variable.imageVar.dislike,
              hasDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

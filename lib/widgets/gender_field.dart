import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/profile/profile_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenderField extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final ProfileController _profileCtl = Get.put(ProfileController());
  late BuildContext _context;

  GenderField({
    Key? key,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xff99D5FF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _context = context;
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
            ),
            SizedBox(width: ResponsiveUtil.ratio(_context, 50.0)),
            _genderItem(
              title: Variable.stringVar.female.tr,
            ),
          ],
        ),
      ],
    );
  }


  Widget _genderItem({required String title}) {
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

  // Widget _genderItem({required String title}) {
  //   return InkWell(
  //     onTap: () {
  //       _profileCtl.userGender.value = title;
  //     },
  //     child: Row(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Variable.colorVar.primaryColor,
  //             borderRadius: BorderRadius.circular(
  //               ResponsiveUtil.ratio(_context, 100.0),
  //             ),
  //           ),
  //           padding: EdgeInsets.fromLTRB(
  //             ResponsiveUtil.ratio(_context, 4.0),
  //             ResponsiveUtil.ratio(_context, 4.0),
  //             ResponsiveUtil.ratio(_context, 8.0),
  //             ResponsiveUtil.ratio(_context, 4.0),
  //           ),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: ResponsiveUtil.ratio(_context, 28.0),
  //                 height: ResponsiveUtil.ratio(_context, 28.0),
  //                 decoration: const BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: Colors.white,
  //                 ),
  //                 child: Obx(
  //                   () => title == _profileCtl.userGender.value
  //                       ? Icon(
  //                           Icons.check,
  //                           color: Variable.colorVar.primaryColor,
  //                           size: ResponsiveUtil.ratio(_context, 24.0),
  //                         )
  //                       : const SizedBox(),
  //                 ),
  //               ),
  //               SizedBox(width: ResponsiveUtil.ratio(_context, 8.0)),
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   fontSize: ResponsiveUtil.ratio(_context, 14.0),
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               )
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
}

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/controllers/group/group_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactHeader extends StatefulWidget {
  final String title;
  final bool isGroup;
  final Widget? subTitle;
  final ValueChanged<String?> onSearch;

  const ContactHeader({
    Key? key,
    required this.title,
    required this.onSearch,
    this.isGroup = false,
    this.subTitle,
  }) : super(key: key);

  @override
  State<ContactHeader> createState() => _ContactHeaderState();
}

class _ContactHeaderState extends State<ContactHeader> {
  late AppTextField _search;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search = AppTextField(
      hint: Variable.stringVar.searchNameOrNumber.tr,
      fillColor: Variable.colorVar.lightGary,
      borderColor: Colors.white,
      focusBorderColor: Colors.white,
      keyboardType: TextInputType.text,
      prefixIcon: Image.asset(
        Variable.imageVar.search,
        width: ResponsiveUtil.ratio(context, 24.0),
        height: ResponsiveUtil.ratio(context, 24.0),
        color: Variable.colorVar.mediumGray,
      ),
      borderWidth: 0,
      onChange: widget.onSearch,
      dispose: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPadding(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtil.ratio(context, 17.0),
                              color: Colors.black,
                            ),
                          ),
                          widget.isGroup ? widget.subTitle! : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.isGroup) {
                        Get.delete<GroupController>();
                      }
                      Get.back();
                    },
                    child: Container(
                      width: ResponsiveUtil.ratio(context, 24.0),
                      height: ResponsiveUtil.ratio(context, 24.0),
                      decoration: BoxDecoration(
                        color: Variable.colorVar.mediumGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: ResponsiveUtil.ratio(context, 20.0),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: ResponsiveUtil.ratio(context, 10.0)),
              _search
            ],
          ),
        ),
        const AppDivider(),
      ],
    );
  }
}

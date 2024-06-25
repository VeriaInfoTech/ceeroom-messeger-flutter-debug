import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const RetryButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          Variable.imageVar.error,
          width: ResponsiveUtil.ratio(context, 250.0),
          height: ResponsiveUtil.ratio(context, 250.0),
        ),
        SizedBox(height: ResponsiveUtil.ratio(context, 8.0)),
        Text(
          Variable.stringVar.unknownError.tr,
          style: TextStyle(
            fontSize: ResponsiveUtil.ratio(context, 18.0),
            color: Variable.colorVar.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtil.ratio(context, 12.0)),
        AppButton(
          title: Variable.stringVar.tryAgain.tr,
          width: ResponsiveUtil.ratio(context, 220.0),
          height: ResponsiveUtil.ratio(context, 50.0),
          onTap: onTap,
          fontSize: 16,
        ),
      ],
    );
  }
}

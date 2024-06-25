import 'package:CeeRoom/utils/utils.dart';
import 'package:flutter/material.dart';

class AppDynamicFontText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AppDynamicFontText({
    super.key,
    this.style,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style != null
          ? style!.copyWith(
              fontFamily: isPersianText(text) ? "VazirmatnFA" : "PoppinsLatin",
            )
          : TextStyle(
              fontFamily: isPersianText(text) ? "VazirmatnFA" : "PoppinsLatin",
            ),
    );
  }
}

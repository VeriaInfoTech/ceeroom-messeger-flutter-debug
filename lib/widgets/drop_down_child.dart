import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/flags.dart';
import 'package:flutter/material.dart';

class DropDownButtonChild extends StatelessWidget {
  final String selectedItem;
  final bool isFlag;
  final Color textColor;
  final double textSize;
  double? width;
  double? height;

  DropDownButtonChild({
    Key? key,
    required this.selectedItem,
    this.width,
    this.height,
    this.isFlag = false,
    this.textColor = const Color(0xff9B1EB4),
    this.textSize = 18.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    width ??= MediaQuery.of(context).size.width;
    height ??= ResponsiveUtil.ratio(context, 45.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ResponsiveUtil.ratio(context, 4.0)),
        border: !isFlag
            ? Border.all(
                color: Variable.colorVar.textFieldText,
                width: ResponsiveUtil.ratio(context, 1.5),
              )
            : null,
        color: Colors.white,
      ),
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtil.ratio(context, 8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            isFlag
                ? Flags(flagName: selectedItem)
                : Text(
                    selectedItem,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: ResponsiveUtil.ratio(context, textSize),
                    ),
                  ),
            if (!isFlag)
              Icon(
                Icons.keyboard_arrow_down,
                color: Variable.colorVar.hintText,
                size: ResponsiveUtil.ratio(context, 24.0),
              )
          ],
        ),
      ),
    );
  }
}

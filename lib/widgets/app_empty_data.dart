import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppEmptyData extends StatelessWidget {
  final String title;
  final bool hasSubTitle;

  const AppEmptyData({
    Key? key,
    required this.title,
    this.hasSubTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Variable.imageVar.emptyScreen,
            width: ResponsiveUtil.ratio(context, 250.0),
            height: ResponsiveUtil.ratio(context, 250.0),
          ),
          SizedBox(height: ResponsiveUtil.ratio(context, 10)),
          Text(
            "${Variable.stringVar.no.tr} $title",
            style: TextStyle(
              fontSize: ResponsiveUtil.ratio(context, 18.0),
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtil.ratio(context, 10.0)),
          hasSubTitle
              ? Text(
                  "${Variable.stringVar.startNew.tr} $title",
                  style: TextStyle(
                    fontSize: ResponsiveUtil.ratio(context, 18.0),
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Flags extends StatelessWidget {
  final String flagName;
  const Flags({Key? key, required this.flagName}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final double ratio = MediaQuery.of(context).size.width / 430.0;
    return SizedBox(
      key: UniqueKey(),
      height: ratio * 26.0,
      width: ratio * 30.0,
      child: Image.asset(
        flagName,
        fit: BoxFit.fill,
      ),
    );
  }
}
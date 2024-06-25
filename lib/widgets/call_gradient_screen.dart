import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:flutter/material.dart';

class CallGradientScreen extends StatelessWidget {
  final Widget child;

  const CallGradientScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Variable.colorVar.grey,
          ],
          stops: const [0.1, 0.9],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

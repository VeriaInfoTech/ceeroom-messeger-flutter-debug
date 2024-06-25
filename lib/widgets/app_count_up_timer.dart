import 'dart:async';

import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppCountUpTimer extends StatefulWidget {
  final bool isVoiceCall;
  const AppCountUpTimer({super.key, this.isVoiceCall = true});


  @override
  State<AppCountUpTimer> createState() => _AppCountUpTimerState();
}

class _AppCountUpTimerState extends State<AppCountUpTimer> {

  int seconds = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) {
        setState(
          () {
            seconds++;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds ~/ 60) % 60;
    int remainingSeconds = seconds % 60;
    return Text(
      '${_formatTime(hours)}:${_formatTime(minutes)}:${_formatTime(remainingSeconds)}',
      style: TextStyle(
        fontSize: ResponsiveUtil.ratio(context, 16.0),
        color: widget.isVoiceCall ? Colors.black :Colors.white,
        fontWeight:  widget.isVoiceCall ? FontWeight.normal:FontWeight.bold,
      ),
    );
  }

  String _formatTime(int timeUnit) {
    return timeUnit < 10 ? '0$timeUnit' : '$timeUnit';
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

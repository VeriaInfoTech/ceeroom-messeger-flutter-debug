import 'package:CeeRoom/core/variables/audio_var.dart';
import 'package:CeeRoom/core/variables/color_var.dart';
import 'package:CeeRoom/core/variables/images.dart';
import 'package:CeeRoom/core/variables/strings.dart';

enum CallStatus { connecting, connected, ringing }

class Variable {
  static ColorVar colorVar = ColorVar();
  static Strings stringVar = Strings();
  static Images imageVar = Images();
  static AudioVar audioVar = AudioVar();
}

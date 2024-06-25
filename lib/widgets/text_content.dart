import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/message_seen_status.dart';
import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  final MessageModel message;
  final bool fromFriend;
  final bool hasBeenSeen;

  const TextMessage({
    super.key,
    required this.message,
    required this.fromFriend,
    required this.hasBeenSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtil.ratio(context, 12.0),
        horizontal: ResponsiveUtil.ratio(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment:
            fromFriend ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Directionality(
            textDirection: isPersianText(message.text!)
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: AppDynamicFontText(
              text: message.text!,
              style: TextStyle(
                fontSize: ResponsiveUtil.ratio(context, 14.0),
                color: fromFriend ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          MessageSeenStatus(
            message: message,
            fromFriend: fromFriend,
            hasBeenSeen: hasBeenSeen,
          ),
        ],
      ),
    );
  }
}

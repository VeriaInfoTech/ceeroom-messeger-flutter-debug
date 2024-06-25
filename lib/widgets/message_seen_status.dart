import 'package:CeeRoom/core/models/message_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:flutter/material.dart';

class MessageSeenStatus extends StatelessWidget {
  final MessageModel message;
  final bool fromFriend;
  final bool hasBeenSeen;
  late Map<String, String> sendTime;

  MessageSeenStatus({
    super.key,
    required this.message,
    required this.fromFriend,
    required this.hasBeenSeen,
  }) {
    sendTime = prettyTimeStamp(
      message.timeSend ?? 0,
      selfGenerated: message.timeSend.toString().length == 13,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sendTime['time']!,
          style: TextStyle(
            fontSize: ResponsiveUtil.ratio(
              context,
              12.0,
            ),
            color: fromFriend ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(
          width: ResponsiveUtil.ratio(context, 12.0),
        ),
        !fromFriend
            ? hasBeenSeen
                ? Icon(
                    Icons.done_all_rounded,
                    color: Colors.white,
                    size: ResponsiveUtil.ratio(
                      context,
                      16.0,
                    ),
                  )
                : message.status == 0
                    ? const SizedBox()
                    : message.status == 1
                        ? Icon(
                            Icons.done_rounded,
                            color: Colors.white,
                            size: ResponsiveUtil.ratio(
                              context,
                              16.0,
                            ),
                          )
                        : Icon(
                            Icons.info_outline_rounded,
                            color: Colors.red,
                            size: ResponsiveUtil.ratio(
                              context,
                              16.0,
                            ),
                          )
            : const SizedBox(),
      ],
    );
  }
}

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/call_controller.dart';
import 'package:CeeRoom/core/controllers/user/user_controller.dart';
import 'package:CeeRoom/core/models/call_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:CeeRoom/widgets/app_cache_image.dart';
import 'package:CeeRoom/widgets/app_divider.dart';
import 'package:CeeRoom/widgets/app_dynamic_font_text.dart';
import 'package:CeeRoom/widgets/app_empty_data.dart';
import 'package:CeeRoom/widgets/app_header.dart';
import 'package:CeeRoom/widgets/app_padding.dart';
import 'package:CeeRoom/widgets/app_refresh_indicator.dart';
import 'package:CeeRoom/widgets/avatar_container.dart';
import 'package:CeeRoom/widgets/group_avatar.dart';
import 'package:CeeRoom/widgets/retry_button.dart';
import 'package:CeeRoom/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallScreen extends StatelessWidget {
  final CallController _callCtl = Get.put(CallController());
  final UserController _userCtl = Get.put(UserController());
  late BuildContext _context;

  CallScreen({Key? key}) : super(key: key) {
    _init();
  }

  void _init() async {
    await _callCtl.getCalls();
    _callCtl.expandedCall.value = -1;
    _callCtl.allCalls = _callCtl.calls.value!;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return SafeArea(
      child: Column(
        children: [
          AppHeader(
            title: Variable.stringVar.calls.tr,
            onSearch: (val) {
              if (!_callCtl.getCallServerErr.value &&
                  _callCtl.calls.value != null) {
                _callCtl.searchCalls(val: val!, userId: _userCtl.user.id!);
              }
            },
          ),
          Obx(
            () => _callCtl.getCallServerErr.value
                ? Expanded(
                    child: Center(
                      child: RetryButton(onTap: _init),
                    ),
                  )
                : _callCtl.calls.value != null && _callCtl.calls.value!.isEmpty
                    ? Expanded(
                        child: AppRefreshIndicator(
                          onRefresh: () async {
                            _init();
                          },
                          child: ListView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            children: [
                              SizedBox(
                                height: ResponsiveUtil.ratio(_context, 150.0),
                              ),
                              AppEmptyData(title: Variable.stringVar.call.tr)
                            ],
                          ),
                        ),
                      )
                    : _callsList(),
          ),
        ],
      ),
    );
  }

  Widget _callsList() {
    return Expanded(
      child: AppRefreshIndicator(
        onRefresh: () async {
          _init();
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount:
              _callCtl.calls.value == null ? 9 : _callCtl.calls.value!.length,
          itemBuilder: (BuildContext context, int index) {
            return _callCtl.calls.value == null
                ? const ShimmerLoading()
                : _callItem(
                    _callCtl.calls.value![index],
                    index,
                  );
          },
        ),
      ),
    );
  }

  Widget _callItem(CallModel call, int index) {
    if (call.lastObject != null) {
      call = call.lastObject!;
    }
    bool isReceiver = call.sender!.id != _userCtl.user.id;
    bool isMissed = call.callInformation?.callStatus == null ||
            call.callInformation!.isGroupCall
        ? false
        : call.callInformation!.callStatus!.toUpperCase() == missed;
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (_callCtl.expandedCall.value == index) {
              _callCtl.expandedCall.value = -1;
            } else {
              _callCtl.expandedCall.value = index;
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtil.ratio(_context, 10.0),
              horizontal: ResponsiveUtil.ratio(_context, 16.0),
            ),
            child: Row(
              children: [
                call.callInformation!.isGroupCall
                    ? const AvatarContainer(icon: GroupAvatar())
                    : CacheImage(
                        !isReceiver
                            ? call.receiver![0].avatar
                            : call.sender!.avatar,
                      ),
                SizedBox(width: ResponsiveUtil.ratio(_context, 10.0)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDynamicFontText(
                        text: call.callInformation!.isGroupCall
                            ? call.callInformation!.caller!.name ?? ''
                            : isReceiver
                                ? call.sender!.name ?? 'no name'
                                : call.receiver![0].name ?? 'no name',
                        style: TextStyle(
                          color: isMissed && isReceiver
                              ? Colors.red
                              : Variable.colorVar.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUtil.ratio(_context, 14.0),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtil.ratio(_context, 4.0)),
                      _callStatus(
                        isMissed: isMissed,
                        isReceiver: isReceiver,
                        callType: call.callType ?? 'voice',
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtil.ratio(_context, 14.0)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${prettyTimeStamp(call.timeCreate!)['date']}",
                      style: TextStyle(
                        color: Variable.colorVar.gray,
                        fontSize: ResponsiveUtil.ratio(_context, 12.0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtil.ratio(_context, 6.0)),
                    Text(
                      "${prettyTimeStamp(call.timeCreate!)['time']}",
                      style: TextStyle(
                        color: Variable.colorVar.gray,
                        fontSize: ResponsiveUtil.ratio(_context, 12.0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Obx(
          () {
            bool isExpanded = _callCtl.expandedCall.value == index;
            return AnimatedContainer(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveUtil.ratio(_context, 16.0),
                vertical:
                    isExpanded ? ResponsiveUtil.ratio(_context, 8.0) : 0.0,
              ),
              duration: const Duration(milliseconds: 300),
              height: isExpanded ? ResponsiveUtil.ratio(_context, 44.0) : 0.0,
              decoration: BoxDecoration(
                color: Variable.colorVar.primaryColor,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtil.ratio(_context, 16.0),
                ),
              ),
              child: AppPadding(
                child: Row(
                  children: [
                    _callBtn(
                      onTap: () {
                        if (call.callInformation!.isGroupCall) {
                          Get.toNamed(
                            Routes.groupVoiceCall,
                            arguments: {
                              'contacts': <ContactModel>[
                                ContactModel(
                                  id: _userCtl.user.id,
                                  mobile: _userCtl.user.mobile,
                                ),
                                ...call.receiver!,
                              ],
                              'call_id': null,
                              'gp_name': call.callInformation!.caller!.name,
                            },
                          );
                        } else {
                          Get.toNamed(
                            Routes.voiceCall,
                            arguments: {
                              'contact':
                                  isReceiver ? call.sender : call.receiver![0],
                              'call_id': null,
                            },
                          );
                        }
                      },
                      icon: Variable.imageVar.fillCall,
                    ),
                    _callBtn(
                      onTap: () {
                        if (call.callInformation!.isGroupCall) {
                          Get.toNamed(
                            Routes.groupVideoCall,
                            arguments: {
                              'contacts': <ContactModel>[
                                ContactModel(
                                  id: _userCtl.user.id,
                                  mobile: _userCtl.user.mobile,
                                ),
                                ...call.receiver!,
                              ],
                              'call_id': null,
                              'gp_name': call.callInformation!.caller!.name,
                            },
                          );
                        } else {
                          Get.toNamed(
                            Routes.videoCall,
                            arguments: {
                              'contact':
                                  isReceiver ? call.sender : call.receiver![0],
                              'call_id': null,
                            },
                          );
                        }
                      },
                      icon: Variable.imageVar.videoCam,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const AppDivider(),
      ],
    );
  }

  Widget _callBtn({
    required VoidCallback onTap,
    required String icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          icon,
          width: ResponsiveUtil.ratio(_context, 30.0),
          height: ResponsiveUtil.ratio(_context, 30.0),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _callStatus({
    required bool isMissed,
    required bool isReceiver,
    required String callType,
  }) {
    return Row(
      children: [
        Image.asset(
          (callType.toUpperCase() == video && isMissed && isReceiver)
              ? Variable.imageVar.missedVideoCall
              : (callType.toUpperCase() == voice && isMissed && isReceiver)
                  ? Variable.imageVar.missedCall
                  : (callType.toUpperCase() == voice && isReceiver)
                      ? Variable.imageVar.incomingCall
                      : (callType.toUpperCase() == voice && !isReceiver)
                          ? Variable.imageVar.outgoingCall
                          : (callType.toUpperCase() == video && isReceiver)
                              ? Variable.imageVar.incomingVideoCall
                              : (callType.toUpperCase() == video && !isReceiver)
                                  ? Variable.imageVar.outgoingVideoCall
                                  : '',
          width: isMissed && isReceiver
              ? ResponsiveUtil.ratio(_context, 16.0)
              : ResponsiveUtil.ratio(_context, 20.0),
          height: isMissed && isReceiver
              ? ResponsiveUtil.ratio(_context, 16.0)
              : ResponsiveUtil.ratio(_context, 20.0),
          color: isMissed && isReceiver ? Colors.red : Variable.colorVar.gray,
        ),
        SizedBox(width: ResponsiveUtil.ratio(_context, 6.0)),
        Text(
          (isMissed && isReceiver)
              ? Variable.stringVar.missed.tr
              : isReceiver
                  ? Variable.stringVar.incoming.tr
                  : Variable.stringVar.outgoing.tr,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Variable.colorVar.gray,
            fontSize: ResponsiveUtil.ratio(_context, 12.0),
          ),
        ),
      ],
    );
  }
}

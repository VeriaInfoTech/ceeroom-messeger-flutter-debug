import 'package:CeeRoom/core/controllers/main_controller.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/screen/account/register.dart';
import 'package:CeeRoom/screen/account/settings_screen.dart';
import 'package:CeeRoom/screen/account/user_profile_screen.dart';
import 'package:CeeRoom/screen/account/view_profile_screen.dart';
import 'package:CeeRoom/screen/auth/login_via_mobile.dart';
import 'package:CeeRoom/screen/auth/login_via_username.dart';
import 'package:CeeRoom/screen/auth/verify_otp.dart';
import 'package:CeeRoom/screen/bottom_nav.dart';
import 'package:CeeRoom/screen/call/video_call/group_video_call.dart';
import 'package:CeeRoom/screen/call/video_call/video_call_screen.dart';
import 'package:CeeRoom/screen/call/voice_call/group_voice_call.dart';
import 'package:CeeRoom/screen/call/voice_call/voice_call_screen.dart';
import 'package:CeeRoom/screen/chat/single_chat_screen.dart';
import 'package:CeeRoom/screen/contact/call_contact_screen.dart';
import 'package:CeeRoom/screen/contact/chat_contacts_screen.dart';
import 'package:CeeRoom/screen/group/choose_group_members.dart';
import 'package:CeeRoom/screen/group/create_group_screen.dart';
import 'package:CeeRoom/screen/group/group_profile_screen.dart';
import 'package:CeeRoom/screen/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  static final MainController _mainCtl = Get.put(MainController());
  static int transactionDuration = 300;
  static int transactionReverseDuration = 250;

  /// message------------------
  static const String home = '/home';
  static const String singleChat = '/single_chat';
  static const String verifyOtp = '/verify_otp';
  static const String loginViaMobile = '/login_via_mobile';
  static const String viewProfile = '/view_profile';
  static const String videoCall = '/video_call';
  static const String voiceCall = '/voice_call';
  static const String userProfile = '/user_profile';
  static const String groupProfile = '/group_profile';
  static const String chatContacts = '/chat_contacts';
  static const String callContacts = '/call_contacts';
  static const String register = '/register';
  static const String setting = '/settings';
  static const String loginViaUsername = '/login_via_username';
  static const String chooseGroupMembers = '/choose_group_members';
  static const String createGroup = '/create_group';
  static const String groupVoiceCall = '/group_voice_call';
  static const String groupVideoCall = '/group_video_call';

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return PageTransition(
          child: const SplashScreen(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case home:
        return PageTransition(
          child: const BottomNav(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case singleChat:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: SingleChatScreen(
            contact: arg['contact'],
            chat: arg['chat'],
          ),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case viewProfile:
        return PageTransition(
          child: ViewProfileScreen(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case userProfile:
        final contact = settings.arguments as ContactModel;
        return PageTransition(
          child: UserProfileScreen(contact: contact),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case groupProfile:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: GroupProfileScreen(
            tag: arg['tag'],
            groupName: arg['groupName'],
            slug: arg['slug'],
          ),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(milliseconds: transactionReverseDuration),
        );
      case loginViaMobile:
        return PageTransition(
          child: LoginViaMobile(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case chatContacts:
        return PageTransition(
          child: ChatContactsScreen(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case callContacts:
        return PageTransition(
          child: CallContactScreen(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case videoCall:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: VideoCallScreen(
            contact: arg['contact'],
            callId: arg['call_id'],
          ),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case register:
        return PageTransition(
          child: Register(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case voiceCall:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: VoiceCallScreen(
            contact: arg['contact'],
            callId: arg['call_id'],
          ),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case groupVoiceCall:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: GroupVoiceCall(
            members: arg['contacts'],
            callId: arg['call_id'],
            gpName: arg['gp_name'],
          ),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case groupVideoCall:
        final arg = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: GroupVideoCall(
            members: arg['contacts'],
            callId: arg['call_id'],
            gpName: arg['gp_name'],
          ),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case verifyOtp:
        final mobile = settings.arguments as String;
        return PageTransition(
          child: VerifyOtp(mobile: mobile),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case setting:
        return PageTransition(
          child: SettingsScreen(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case loginViaUsername:
        return PageTransition(
          child: LoginViaUserName(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case chooseGroupMembers:
        return PageTransition(
          child: ChooseGroupMembers(),
          type: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      case createGroup:
        return PageTransition(
          child: CreateGroupScreen(),
          type: PageTransitionType.rightToLeft,
          duration: Duration(milliseconds: transactionDuration),
          reverseDuration: Duration(
            milliseconds: transactionReverseDuration,
          ),
        );
      default:
        return null;
    }
  }
}

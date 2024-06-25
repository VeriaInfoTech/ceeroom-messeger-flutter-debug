import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/call/call_controller.dart';
import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/controllers/contact/contact_controller.dart';
import 'package:CeeRoom/core/controllers/main_controller.dart';
import 'package:CeeRoom/core/services/local_storage/contact.dart'
    as contact_local;
import 'package:CeeRoom/screen/account/profile_screen.dart';
import 'package:CeeRoom/screen/call/call_screen.dart';
import 'package:CeeRoom/screen/chat/chat_screen.dart';
import 'package:CeeRoom/utils/permission_request.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:CeeRoom/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

late BuildContext appContext;

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final ContactController _contactCtl = Get.put(ContactController());
  final CallController _callCtl = Get.put(CallController());
  final MainController _mainCtl = Get.put(MainController());
  final ChatController _chatCtl = Get.put(ChatController());
  int currentPage = 1;
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await requestPermission();
    _contactCtl.getPhoneContact(needSort: false);
  }

  final List<Widget> pages = [
    CallScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    _context = context;
    appContext = context;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: currentPage != 2
            ? FloatingButton(
                icon: currentPage == 0
                    ? Variable.imageVar.calls
                    : Variable.imageVar.message,
                onTap: () {
                  currentPage == 0
                      ? Get.toNamed(Routes.callContacts)
                      : Get.toNamed(Routes.chatContacts);
                },
              )
            : null,
        body: pages[currentPage],
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtil.ratio(_context, 6.0),
          ),
          decoration: BoxDecoration(
            color: Variable.colorVar.lightGray,
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0.0, 1.0),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: BottomNavigationBar(
            selectedFontSize: ResponsiveUtil.ratio(_context, 14.0),
            unselectedFontSize: ResponsiveUtil.ratio(_context, 12.0),
            onTap: (int index) {
              _mainCtl.isSearchable.value = false;
              _chatCtl.searchChats(val: '');
              _callCtl.searchCalls(val: '');
              setState(() {
                currentPage = index;
              });
            },
            currentIndex: currentPage,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                backgroundColor: Variable.colorVar.primaryColor,
                icon: Image.asset(
                  Variable.imageVar.call,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.gray,
                ),
                activeIcon: Image.asset(
                  Variable.imageVar.fillCall,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.primaryColor,
                ),

                label: Variable.stringVar.calls.tr,
              ),
              BottomNavigationBarItem(
                backgroundColor: Variable.colorVar.primaryColor,
                icon: Image.asset(
                  Variable.imageVar.chat,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.gray,
                ),
                activeIcon: Image.asset(
                  Variable.imageVar.fillChat,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.primaryColor,
                ),
                label: Variable.stringVar.chats.tr,
              ),
              BottomNavigationBarItem(
                backgroundColor: Variable.colorVar.primaryColor,
                icon: Image.asset(
                  Variable.imageVar.person,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.gray,
                ),
                activeIcon: Image.asset(
                  Variable.imageVar.fillPerson,
                  width: ResponsiveUtil.ratio(_context, 32.0),
                  color: Variable.colorVar.primaryColor,
                ),
                label: Variable.stringVar.profile.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

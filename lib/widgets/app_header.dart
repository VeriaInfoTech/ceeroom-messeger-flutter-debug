import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/core/controllers/main_controller.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final ValueChanged<String?> onSearch;

  const AppHeader({
    Key? key,
    required this.title,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  late AppTextField _search;
  final MainController _mainCtl = Get.put(MainController());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _search = AppTextField(
        hint: Variable.stringVar.searchNameOrNumber.tr,
        fillColor: Variable.colorVar.lightGary,
        borderColor: Colors.white,
        focusBorderColor: Colors.white,
        keyboardType: TextInputType.text,
        prefixIcon: Image.asset(
          Variable.imageVar.search,
          width: ResponsiveUtil.ratio(context, 24.0),
          height: ResponsiveUtil.ratio(context, 24.0),
          color: Variable.colorVar.mediumGray,
        ),
        onChange: widget.onSearch,
        borderWidth: 0,
        dispose: false,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.ratio(context, 20.0),
            vertical: ResponsiveUtil.ratio(context, 10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: ResponsiveUtil.ratio(context, 20.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap: () {
                    _mainCtl.isSearchable.value = !_mainCtl.isSearchable.value;
                    if (!_mainCtl.isSearchable.value) {
                      _search.controller!.text = '';
                      widget.onSearch.call('');
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtil.ratio(context, 6.0),
                    ),
                    child: Image.asset(
                      _mainCtl.isSearchable.value
                          ? Variable.imageVar.close
                          : Variable.imageVar.search,
                      width: ResponsiveUtil.ratio(context, 20.0),
                      height: ResponsiveUtil.ratio(context, 20.0),
                      color: Variable.colorVar.gray,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        // SizedBox(height: MainController.ratio * 10.0),
        Obx(
          () => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtil.ratio(context, 16.0),
              vertical: ResponsiveUtil.ratio(context, 4.0),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _mainCtl.isSearchable.value
                  ? MediaQuery.of(context).size.width
                  : 0.0,
              height: _mainCtl.isSearchable.value
                  ? ResponsiveUtil.ratio(context, 55.0)
                  : 0,
              child: _search,
            ),
          ),
        ),
        // Obx(
        //   () => _mainCtl.isSearchable.value
        //       ? AppPadding(child: _search)
        //       : const SizedBox(),
        // ),
        Divider(
          thickness: ResponsiveUtil.ratio(context, 1.0),
          height: 0.0,
        ),
      ],
    );
  }
}

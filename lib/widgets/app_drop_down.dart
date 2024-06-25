import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/widgets/app_text_form_field.dart';
import 'package:CeeRoom/widgets/flags.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class AppDropDown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final void Function(T?) onChanged;
  final TextEditingController _search = TextEditingController();
  final bool searchable;
  final T? value;
  final bool Function(DropdownMenuItem<T>, String)? searchMatchFn;
  final bool hasBorder;
  final bool filled;

  AppDropDown({
    Key? key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText = '',
    this.searchable = false,
    this.searchMatchFn,
    this.hasBorder = true,
    this.filled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: filled,
        fillColor: Colors.white,
        border: UnderlineInputBorder(
          borderSide: !hasBorder
              ? BorderSide.none
              : BorderSide(
                  strokeAlign: ResponsiveUtil.ratio(context, 1.0),
                ),
        ),
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                // borderSide: BorderSide(color: Variable.colorVar.secondBorderColor),
              )
            : null,
        // border: hasBorder ? OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(12.0),
        //   // borderSide: BorderSide(color: Variable.colorVar.secondBorderColor),
        // ) : null,
        focusedBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                // borderSide: BorderSide(
                //   color: Colors.red
                //   // !darkModeEnabled()
                //   //     ? Variable.colorVar.primaryColor
                //   //     : Variable.colorVar.darkPrimaryColor,
                // ),
              )
            : null,
      ),
      hint: Text(
        hintText,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: ResponsiveUtil.ratio(context, 14.0),
        ),
      ),
      items: items,
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        height: ResponsiveUtil.ratio(context, 60.0),
        padding: const EdgeInsets.all(8.0),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => Colors.transparent,
        ),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: ResponsiveUtil.ratio(context, 24.0),
          color: Colors.black,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: ResponsiveUtil.ratio(context, 200),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), color: Colors.white
            // !darkModeEnabled()
            //     ? Colors.white
            //     : Variable.colorVar.secondDarkPrimaryColor,
            ),
      ),
      dropdownSearchData: searchable
          ? DropdownSearchData(
              searchController: _search,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                padding: EdgeInsets.all(ResponsiveUtil.ratio(context, 8.0)),
                child: AppTextField(
                  controller: _search,
                  dispose: false,
                  isRequired: false,
                  hint: '',
                  // hint: t.search,
                ),
              ),
              searchMatchFn: searchMatchFn,
            )
          : null,
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          _search.clear();
        }
      },
    );
  }
}

class DropDownButtonItem extends StatelessWidget {
  final String? item;
  final bool isFlag;

  const DropDownButtonItem({
    Key? key,
    required this.item,
    required this.isFlag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isFlag
        ? Center(child: Flags(flagName: item!))
        : Text(
            item ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtil.ratio(context, 14.0),
            ),
          );
  }
}

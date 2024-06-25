// ignore_for_file: must_be_immutable

import 'package:CeeRoom/core/base/base_variable.dart';
import 'package:CeeRoom/utils/responsive_utils.dart';
import 'package:CeeRoom/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTextField extends StatefulWidget {
  FocusNode focusNode = FocusNode();
  FormFieldValidator<String>? validator;
  final void Function(String?)? onChange;
  TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String hint;
  final TextInputType keyboardType;
  final int? maxLength;
  final Color? fillColor;
  final double borderRadius;
  final Color focusBorderColor;
  final Color borderColor;
  final double borderWidth;
  final Color hintTextColor;
  final bool readOnly;
  final FocusNode? nextFocusNode;
  final Function(String)? onSubmit;
  final Color textColor;
  final bool validation;
  final bool isRequired;
  final int? maxLines;
  final int? minLines;
  final String? label;
  final bool dispose;
  final TextInputAction? textInputAction;
  String fontFamily;
  TextDirection textDirection;
  bool obscure;

  AppTextField({
    Key? key,
    this.validator,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChange,
    required this.hint,
    this.keyboardType = TextInputType.phone,
    this.maxLength,
    this.fillColor,
    this.borderWidth = 1.0,
    this.hintTextColor = const Color(0xff465564),
    this.borderColor = const Color(0xFFE1E1E1),
    this.focusBorderColor = const Color(0xFF0045F5),
    this.readOnly = false,
    this.onTap,
    this.onSubmit,
    this.textColor = Colors.black,
    this.validation = false,
    this.label,
    this.isRequired = true,
    this.borderRadius = 20.0,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscure = false,
    this.dispose = true,
    this.fontFamily = "PoppinsLatin",
    this.textDirection = TextDirection.ltr,
    this.nextFocusNode,
    this.textInputAction,
  }) : super(key: key) {
    controller ??= TextEditingController();
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late void Function(String) onChange;

  @override
  void initState() {
    super.initState();
    onChange = (val) {
      if (isPersianText(val)) {
        widget.textDirection = TextDirection.rtl;
        widget.fontFamily = "VazirmatnFA";
      } else {
        widget.textDirection = TextDirection.ltr;
        widget.fontFamily = "PoppinsLatin";
      }
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      validator: widget.validation ? widget.validator ?? selfValidator : null,
      maxLength: widget.maxLength,
      controller: widget.controller,
      onFieldSubmitted: widget.onSubmit ?? selfSubmit,
      obscureText: widget.obscure,
      focusNode: widget.focusNode,
      textInputAction:
          widget.textInputAction as bool? ?? widget.nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
      style: TextStyle(
        color: widget.textColor,
        fontSize: ResponsiveUtil.ratio(context, 14.0),
        fontFamily: isPersianText(widget.controller!.text)
            ? "VazirmatnFA"
            : "PoppinsLatin",
      ),
      textDirection: widget.textDirection,
      autovalidateMode:
          widget.validation ? AutovalidateMode.onUserInteraction : null,
      decoration: InputDecoration(
        isDense: true,
        filled: widget.fillColor != null ? true : false,
        fillColor: widget.fillColor,
        label: widget.label != null
            ? Text(
                widget.label!,
                style: TextStyle(
                  fontSize: ResponsiveUtil.ratio(context, 16.0),
                  color: Variable.colorVar.heavyGray,
                ),
              )
            : null,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtil.ratio(context, 10.0),
                ),
                child: widget.prefixIcon,
              )
            : null,
        suffixIconConstraints: BoxConstraints(
          minWidth: ResponsiveUtil.ratio(context, 28.0),
          minHeight: ResponsiveUtil.ratio(context, 54.0),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtil.ratio(context, 26.0),
          ),
          child: widget.suffixIcon,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          borderSide: BorderSide(
            color: widget.focusBorderColor,
            width: 1.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius,
          ),
          borderSide: BorderSide(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: widget.hintTextColor,
          fontWeight: FontWeight.w400,
          fontSize: ResponsiveUtil.ratio(context, 14.0),
        ),
        counterText: "",
        errorStyle: const TextStyle(
          height: 0,
        ),
      ),
      keyboardType: widget.keyboardType,
      onChanged: (val) {
        onChange(val);
        widget.onChange?.call(val);
      },
    );
  }

  String? selfValidator(String? value) {
    String temp = '${Variable.stringVar.enterSelf.tr} ${widget.label}';
    if (value!.isEmpty) {
      return '${Variable.stringVar.please.tr} $temp';
    } else if (widget.maxLength != null && value.length < widget.maxLength!) {
      return '${widget.maxLength} ${Variable.stringVar.number.tr}';
    }
    return null;
  }

  void selfSubmit(String value) {
    widget.focusNode.unfocus();
    if (widget.nextFocusNode != null) widget.nextFocusNode!.requestFocus();
  }

  @override
  void dispose() {
    if (widget.dispose) {
      widget.controller!.dispose();
    }
    super.dispose();
  }
}

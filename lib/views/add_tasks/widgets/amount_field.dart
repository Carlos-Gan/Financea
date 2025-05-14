import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final TextStyle? labelStyle;
  final Color focusedBorderColor;
  final Color enabledBorderColor;
  final double borderWidth;

  const AmountField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.onChanged,
    this.padding,
    this.width,
    this.labelStyle,
    this.focusedBorderColor = const Color(0xFF2E7D32), // Default to secondaryColorDark
    this.enabledBorderColor = Colors.grey,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 15.0),
      child: SizedBox(
        width: width ?? MediaQuery.of(context).size.width - 180,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          focusNode: focusNode,
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            labelText: labelText,
            labelStyle: labelStyle ??  TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: enabledBorderColor,
                width: borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: borderWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
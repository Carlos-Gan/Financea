import 'package:flutter/material.dart';

class TypeSelector extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextStyle? textStyle;

  const TypeSelector({
    super.key,
    required this.options,
    required this.onChanged,
    required this.hintText,
    this.initialValue,
    this.textStyle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TypeSelectorState createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey[300]!),
        ),
        child: DropdownButton<String>(
          value: selectedValue,
          onChanged: (String? value) {
            if (value != null) {
              setState(() => selectedValue = value);
              widget.onChanged(value);
            }
          },
          items: widget.options.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset('img/$e.png'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e,
                    style: widget.textStyle ?? const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return widget.options.map((e) {
              return Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Image.asset('img/$e.png'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e,
                    style: widget.textStyle ?? const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          hint: Text(
            widget.hintText,
            style: widget.textStyle ?? const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }
}
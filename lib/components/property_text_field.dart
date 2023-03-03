import 'package:flutter/material.dart';

class PropertyTextField extends StatelessWidget {
  const PropertyTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.maxLines,
    this.suffix,
    this.labelMinWidth,
    this.onSubmitted,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final int? maxLines;
  final Widget? suffix;
  final double? labelMinWidth;
  final void Function()? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        maxLines: maxLines,
        onSubmitted: (text) => onSubmitted?.call(),
        onEditingComplete: () => onSubmitted?.call(),
        decoration: InputDecoration(
          isDense: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          prefixIcon: _buildPrefixLabel(context),
          prefixIconConstraints: BoxConstraints(minWidth: labelMinWidth ?? 48),
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(maxWidth: 80),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          border: const OutlineInputBorder(),
        ),
        style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget? _buildPrefixLabel(BuildContext context) {
    if (labelText == null) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        labelText!,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

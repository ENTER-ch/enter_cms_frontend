import 'package:flutter/material.dart';

class PropertyDropdownField extends StatefulWidget {
  const PropertyDropdownField({
    Key? key,
    required this.items,
    this.onChanged,
    this.value,
    this.labelText,
    this.helperText,
    this.errorText,
    this.suffix,
    this.labelMinWidth,
  }) : super(key: key);
  final List<DropdownMenuItem<dynamic>> items;
  final void Function(dynamic)? onChanged;

  final dynamic value;

  final String? labelText;
  final String? helperText;
  final String? errorText;
  final Widget? suffix;

  final double? labelMinWidth;

  @override
  State<PropertyDropdownField> createState() => _PropertyDropdownFieldState();
}

class _PropertyDropdownFieldState extends State<PropertyDropdownField> {
  final _focusNode = FocusNode();

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void didUpdateWidget(covariant PropertyDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _focusNode.unfocus();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      isFocused: _isFocused,
      decoration: InputDecoration(
        isDense: true,
        helperText: widget.helperText,
        errorText: widget.errorText,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        prefixIcon: _buildPrefixLabel(context),
        prefixIconConstraints: BoxConstraints(minWidth: widget.labelMinWidth ?? 48),
        suffixIconConstraints: const BoxConstraints(maxWidth: 80),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
          child: DropdownButton(
            focusNode: _focusNode,
            isDense: true,
            style: Theme.of(context).textTheme.bodyMedium,
            icon: widget.suffix,
            value: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
          ),
      ),
    );
  }

  Widget? _buildPrefixLabel(BuildContext context) {
    if (widget.labelText == null) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        widget.labelText!,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

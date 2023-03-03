import 'package:enter_cms_flutter/components/property_dropdown_field.dart';
import 'package:flutter/material.dart';

class InteractivePropertyDropdownField extends StatefulWidget {
  const InteractivePropertyDropdownField({
    Key? key,
    required this.items,
    this.initialValue,
    this.labelText,
    this.helperText,
    this.onValidate,
    required this.onSave,
  }) : super(key: key);

  final List<DropdownMenuItem<dynamic>> items;
  final dynamic initialValue;
  final String? labelText;
  final String? helperText;

  final Future<String?> Function(dynamic initialValue)? onValidate;
  final Future<void> Function(dynamic value) onSave;

  @override
  State<InteractivePropertyDropdownField> createState() => _InteractivePropertyDropdownFieldState();
}

class _InteractivePropertyDropdownFieldState extends State<InteractivePropertyDropdownField> {
  dynamic dropdownValue;
  String? _errorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  @override
  void didUpdateWidget(covariant InteractivePropertyDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _initForm();
    }
  }

  void _initForm() {
    setState(() {
      dropdownValue =  widget.initialValue ?? '';
      _errorMessage = null;
    });
  }

  void _save() async {
    if (!_isChanged) {
      return;
    }
    if (widget.onValidate != null) {
      final errorMessage = await widget.onValidate!(dropdownValue);
      if (errorMessage != null) {
        setState(() {
          _errorMessage = errorMessage;
        });
        return;
      }
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await widget.onSave(dropdownValue);
    setState(() {
      _isLoading = false;
    });
  }

  bool get _isChanged => dropdownValue != widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return PropertyDropdownField(
      labelText: widget.labelText,
      helperText: widget.helperText,
      items: widget.items,
      value: dropdownValue,
      onChanged: (value) {
        setState(() {
          dropdownValue = value;
        });
        _save();
      },
    );
  }
}

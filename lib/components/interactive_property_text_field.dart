import 'package:enter_cms_flutter/components/property_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractivePropertyTextField extends StatefulWidget {
  const InteractivePropertyTextField({
    Key? key,
    this.labelText,
    this.maxLines,
    this.initialValue,
    this.onValueChanged,
    this.onValidate,
    this.controller,
    required this.onSave,
  }) : super(key: key);

  final String? labelText;
  final int? maxLines;

  final String? initialValue;
  final Future<void> Function(String value)? onValueChanged;
  final Future<String?> Function(String value)? onValidate;
  final Future<void> Function(String value) onSave;

  final TextEditingController? controller;

  @override
  State<InteractivePropertyTextField> createState() =>
      _InteractivePropertyTextFieldState();
}

class _InteractivePropertyTextFieldState
    extends State<InteractivePropertyTextField> {
  late TextEditingController _controller;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      widget.onValueChanged?.call(_controller.text);
      setState(() {});
    });

    _initForm();
  }

  @override
  void didUpdateWidget(covariant InteractivePropertyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _initForm();
    }
  }

  void _initForm() {
    _controller.text = widget.initialValue ?? '';

    setState(() {
      _errorMessage = null;
    });
  }

  void _save() async {
    if (!_isChanged) {
      return;
    }
    if (widget.onValidate != null) {
      final errorMessage = await widget.onValidate!(_controller.text);
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
    await widget.onSave(_controller.text);
    setState(() {
      _isLoading = false;
    });
  }

  bool get _isChanged => _controller.text != widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter): _save,
      },
      child: PropertyTextField(
        controller: _controller,
        labelText: widget.labelText,
        errorText: _errorMessage,
        maxLines: widget.maxLines,
        suffix: _buildSuffix(),
        onSubmitted: _save,
      ),
    );
  }

  Widget? _buildSuffix() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_isChanged) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInlineButton(
            icon: Icons.close,
            foregroundColor: Theme.of(context).colorScheme.error,
            onPressed: _initForm,
          ),
          const SizedBox(width: 4),
          _buildInlineButton(
            icon: Icons.check,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            onPressed: _save,
          ),
          const SizedBox(width: 8),
        ],
      );
    }
    return null;
  }

  Widget _buildInlineButton({
    required IconData icon,
    required void Function() onPressed,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        minimumSize: Size.zero,
        fixedSize: const Size(24, 24),
        padding: const EdgeInsets.all(0),
      ),
      child: Icon(
        icon,
        size: 16,
      ),
    );
  }
}

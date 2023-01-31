import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    Key? key,
    required this.icon,
    this.label,
    this.tooltipText,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final String? label;
  final String? tooltipText;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return _buildTooltip(
      context,
      child: Material(
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(icon, size: 20,),
                if (label != null) ...[
                  const SizedBox(width: 8,),
                  Text(label!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, {required Widget child}) {
    return tooltipText != null ? Tooltip(
      message: tooltipText,
      waitDuration: const Duration(milliseconds: 500),
      child: child,
    ) : child;
  }
}
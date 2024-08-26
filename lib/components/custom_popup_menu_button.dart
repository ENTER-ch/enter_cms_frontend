import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:flutter/material.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String? tooltipText;
  final List<PopupMenuItem> items;

  const CustomPopupMenuButton({
    super.key,
    required this.icon,
    required this.items,
    this.label,
    this.tooltipText,
  });

  void showPopupMenu(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final position =
        RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy);
    showMenu(
      context: context,
      position: position,
      elevation: 1,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      icon: icon,
      label: label,
      tooltipText: tooltipText,
      onTap: () => showPopupMenu(context),
    );
  }
}

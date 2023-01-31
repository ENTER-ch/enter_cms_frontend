import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:flutter/material.dart';

class ContentToolbar extends StatelessWidget {
  const ContentToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ToolbarButton(
        icon: Icons.headphones,
        tooltipText: 'Create Audioguide Touchpoint',
        onTap: () {},
      ),
    ]);
  }
}
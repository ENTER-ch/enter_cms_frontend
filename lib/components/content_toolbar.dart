import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/components/create_touchpoint_dialog.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';

class ContentToolbar extends StatelessWidget {
  const ContentToolbar({
    Key? key,
    required this.contentBloc,
  }) : super(key: key);

  final ContentBloc contentBloc;

  void _onCreateTouchpoint(BuildContext context, TouchpointType type) {
    contentBloc.add(ContentEventCreateTouchpoint(type: type));
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ToolbarButton(
        icon: Icons.headphones,
        tooltipText: 'Create Audioguide Touchpoint',
        onTap: () => _onCreateTouchpoint(context, TouchpointType.audioguide),
      ),
    ]);
  }
}
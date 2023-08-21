import 'package:enter_cms_flutter/bloc/touchpoint_editor/touchpoint_editor_bloc.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MPTouchpointEditor extends StatelessWidget {
  const MPTouchpointEditor({
    Key? key,
    required this.touchpointEditorBloc,
  }) : super(key: key);

  final TouchpointEditorBloc touchpointEditorBloc;

  @override
  Widget build(BuildContext context) {
    return ContentNavWidget(
      title: const Text('Mediaplayer'),
      child: BlocBuilder<TouchpointEditorBloc, TouchpointEditorState>(
        bloc: touchpointEditorBloc,
        builder: (context, state) {
          if (state is TouchpointEditorLoaded) {
            //final mpConfig = state.touchpoint.mpConfig;

            return const Column(
              children: [],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

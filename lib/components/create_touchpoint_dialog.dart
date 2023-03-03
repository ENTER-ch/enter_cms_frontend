import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';

class CreateTouchpointDialog extends StatefulWidget {
  const CreateTouchpointDialog({
    Key? key,
    required this.type,
  }) : super(key: key);

  final TouchpointType type;

  @override
  State<CreateTouchpointDialog> createState() => _CreateTouchpointDialogState();
}

class _CreateTouchpointDialogState extends State<CreateTouchpointDialog> {

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Create Touchpoint'),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

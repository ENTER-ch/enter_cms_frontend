import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _controller = TextEditingController();

  String _label = 'This is a test';
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _controller.text = _label;
    _controller.addListener(() {
      setState(() {
        _label = _controller.text;
      });
    });
  }

  void _setShowPreview(BuildContext context, bool showPreview) {
    setState(() {
      _showPreview = showPreview;
    });

    if (_showPreview) {
      showMenu<bool>(
          context: context,
          position: const RelativeRect.fromLTRB(0, 0, 0, 0),
          items: [
            PopupMenuItem(
              enabled: false,
              child: AGContentPreview(
                  content: MAGContent(
                    type: AGContentType.audio,
                    label: _label,
                  )
              ),
            ),
          ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                child: TextField(
                  maxLines: 5,
                  controller: _controller,
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

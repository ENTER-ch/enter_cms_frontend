// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

class AGContentPreview extends StatefulWidget {
  const AGContentPreview({
    super.key,
    required this.content,
    this.touchpointId = 0,
  });

  final int? touchpointId;
  final MAGContent content;

  @override
  State<AGContentPreview> createState() => _AGContentPreviewState();
}

class _AGContentPreviewState extends State<AGContentPreview> {
  bool _showPrompt = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFrame(
          context,
          child: _buildIFrameView(context),
        ),
        Column(
          children: [
            ToolbarButton(
              icon: _showPrompt ? Icons.message : Icons.message_outlined,
              onTap: _togglePrompt,
            ),
          ],
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data["type"] == "ready") _sendContent();
    });
  }

  @override
  void didUpdateWidget(covariant AGContentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) _sendContent();
  }

  void _sendContent() {
    html.window.postMessage({
      "type": "content",
      "data": "${widget.content.label}",
    }, '*');
  }

  void _togglePrompt() {
    setState(() {
      _showPrompt = !_showPrompt;
    });
    html.window.postMessage({
      "type": "show_prompt",
      "data": _showPrompt,
    }, '*');
  }

  Widget _buildFrame(BuildContext context, {Widget? child}) {
    return FittedBox(
      child: Container(
        width: 240,
        height: 320,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: child,
      ),
    );
  }

  Widget _buildIFrameView(BuildContext context) {
    final html.IFrameElement iframeElement = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.borderRadius = '8px'
      ..src = '/content_preview.html';

    ui_web.platformViewRegistry.registerViewFactory(
      'iframe',
      (int viewId) => iframeElement,
    );

    return const SizedBox(
      width: 240,
      height: 320,
      child: HtmlElementView(
        viewType: 'iframe',
      ),
    );
  }
}

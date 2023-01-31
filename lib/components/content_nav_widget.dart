import 'package:flutter/material.dart';

class ContentNavWidget extends StatelessWidget {
  const ContentNavWidget({
    Key? key,
    this.title,
    this.child,
  }) : super(key: key);

  final Widget? title;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const Divider(),
        if (child != null) Expanded(child: child!),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.titleSmall,
      child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
          child: Row(children: [
            if (title != null) title!,
          ])),
    );
  }
}

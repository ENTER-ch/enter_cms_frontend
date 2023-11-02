import 'package:flutter/material.dart';

class ContentNavWidget extends StatelessWidget {
  const ContentNavWidget({
    super.key,
    this.title,
    this.child,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(),
          if (child != null) child!,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.titleSmall,
      child: Row(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
              child: title!,
            ),
          if (actions.isNotEmpty) ...[
            const Spacer(),
            ...actions,
            const SizedBox(
              width: 8.0,
            ),
          ],
        ],
      ),
    );
  }
}

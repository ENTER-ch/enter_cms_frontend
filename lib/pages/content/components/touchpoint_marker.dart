import 'package:flutter/material.dart';

enum TouchpointMarkerStyle { tiny, icon, full }

class TouchpointMarker extends StatelessWidget {
  const TouchpointMarker({
    Key? key,
    this.style = TouchpointMarkerStyle.full,
    this.icon = Icons.location_on,
    this.label,
    this.tooltip,
    this.foregroundColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  final TouchpointMarkerStyle style;

  final Color? foregroundColor;
  final Color? backgroundColor;

  final IconData icon;
  final String? label;
  final String? tooltip;

  final void Function()? onTap;

  final sizes = const {
    TouchpointMarkerStyle.tiny: Size(14, 14),
    TouchpointMarkerStyle.icon: Size(26, 26),
    TouchpointMarkerStyle.full: Size(74, 34),
  };

  final _styleTransitionDuration = const Duration(milliseconds: 200);

  Color _getForegroundColor(BuildContext context) {
    return foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
  }

  Color _getBackgroundColor(BuildContext context) {
    return backgroundColor ?? Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTooltip(
      context,
      child: _buildContainer(
        context,
        child: _buildBody(
          context,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(context),
              if (label != null) _buildLabel(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(BuildContext context, {Widget? child}) {
    return Tooltip(
      message: tooltip ?? '',
      child: child,
    );
  }

  Widget _buildContainer(BuildContext context, {Widget? child}) {
    return SizedBox(
      width: 74,
      height: 34,
      child: Center(
        child: AnimatedContainer(
          duration: _styleTransitionDuration,
          width: sizes[style]!.width,
          height: sizes[style]!.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getForegroundColor(context),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            type: MaterialType.button,
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              child: FittedBox(
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {Widget? child}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: AnimatedScale(
        duration: _styleTransitionDuration,
        scale: style == TouchpointMarkerStyle.tiny ? 0.0 : 1.0,
        child: child,
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Icon(
      icon,
      color: _getForegroundColor(context),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return AnimatedSize(
      duration: _styleTransitionDuration,
      alignment: Alignment.centerLeft,
      child: style == TouchpointMarkerStyle.full
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(label!,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: _getForegroundColor(context))),
            )
          : const SizedBox(),
    );
  }
}

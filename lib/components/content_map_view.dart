import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/bloc/map/map_bloc.dart';
import 'package:enter_cms_flutter/components/pan_zoom_map_view.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class ContentMapView extends StatelessWidget {
  const ContentMapView({
    Key? key,
    required this.mapBloc,
    required this.contentBloc,
  }) : super(key: key);

  final MapBloc mapBloc;
  final ContentBloc contentBloc;

  bool _isPositionInView(Offset position, vector_math.Quad viewport) {
    return viewport.point0.x <= position.dx &&
        viewport.point1.x >= position.dx &&
        viewport.point0.y <= position.dy &&
        viewport.point2.y >= position.dy;
  }

  void _selectTouchpoint(MTouchpoint? touchpoint) {
    contentBloc.add(ContentEventSelectTouchpoint(touchpoint: touchpoint));
  }

  void _contextBlocListener(BuildContext context, ContentState state) {
    if (state is ContentLoaded) {
      if (state.selectedTouchpoint != null) {
        // TODO: Scroll to selected touchpoint
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      bloc: mapBloc,
      builder: (context, state) {
        if (state is MapLoaded) {
          return Stack(
            children: [
              PanZoomMapView(
                floorplan: state.selectedFloorplan,
                overlayBuilder: _buildOverlay,
                onTap: (position) => _selectTouchpoint(null),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildOverlay(
      BuildContext context, vector_math.Quad viewport, double scale) {
    return BlocConsumer<ContentBloc, ContentState>(
      bloc: contentBloc,
      listener: _contextBlocListener,
      builder: (context, state) {
        if (state is ContentLoaded) {
          final filteredTouchpoints = state.touchpoints.where((touchpoint) {
            if (touchpoint.position == null) {
              return false;
            }
            return _isPositionInView(touchpoint.position!.toOffset(), viewport);
          });

          return Stack(
            children: [
              ...filteredTouchpoints.map((t) {
                final offset = t.position!.toOffset();
                return Positioned(
                  key: ValueKey(t.id),
                  left: offset.dx,
                  top: offset.dy,
                  child: Transform.scale(
                    scale: 1 / scale,
                    child: TouchpointMarker(
                      onTap: () => _selectTouchpoint(t),
                      label: t.touchpointId != null
                          ? t.touchpointId!.toString().padLeft(3, '0')
                          : 'XXX',
                      tooltip: t.internalTitle,
                      icon: t.type.icon,
                      backgroundColor: t.type.color,
                      foregroundColor: t.type.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      style: state.selectedTouchpoint == t ? TouchpointMarkerStyle.full : scale > 0.5
                          ? TouchpointMarkerStyle.full
                          : scale > 0.2
                              ? TouchpointMarkerStyle.icon
                              : TouchpointMarkerStyle.tiny,
                    ),
                  ),
                );
              }),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

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
    return AnimatedContainer(
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
                      .titleSmall!
                      .copyWith(color: _getForegroundColor(context))),
            )
          : const SizedBox(),
    );
  }
}

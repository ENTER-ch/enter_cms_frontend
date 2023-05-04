import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/bloc/map/map_bloc.dart';
import 'package:enter_cms_flutter/components/pan_zoom_map_view.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

import '../models/position.dart';

class ContentMapView extends StatefulWidget {
  const ContentMapView({
    Key? key,
    required this.mapBloc,
    required this.contentBloc,
  }) : super(key: key);

  final MapBloc mapBloc;
  final ContentBloc contentBloc;

  @override
  State<ContentMapView> createState() => _ContentMapViewState();
}

class _ContentMapViewState extends State<ContentMapView> {
  Offset? _mousePosition;

  bool _isPositionInView(Offset position, vector_math.Quad viewport) {
    return viewport.point0.x <= position.dx &&
        viewport.point1.x >= position.dx &&
        viewport.point0.y <= position.dy &&
        viewport.point2.y >= position.dy;
  }

  void _selectTouchpoint(MTouchpoint? touchpoint) {
    widget.contentBloc
        .add(ContentEventSelectTouchpoint(touchpoint: touchpoint));
  }

  void _contextBlocListener(BuildContext context, ContentState state) {
    if (state is ContentLoaded) {
      if (state.selectedTouchpoint != null) {
        // TODO: Scroll to selected touchpoint
      }
    }
  }

  void _onMapClicked(Offset position) {
    final state = widget.contentBloc.state;
    final mapState = widget.mapBloc.state;
    if (state is ContentLoaded && mapState is MapLoaded) {
      if (state.intent == ContentIntent.placeTouchpoint) {
        // Place touchpoint
        print('Placing touchpoint at $position');
        widget.contentBloc.add(ContentEventPlaceTouchpoint(
          touchpoint: state.selectedTouchpoint!,
          position: MPosition(
            parentId: mapState.selectedFloorplan!.id,
            x: position.dx,
            y: position.dy,
          ),
        ));
        return;
      }
    }
    _selectTouchpoint(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      bloc: widget.mapBloc,
      builder: (context, state) {
        if (state is MapLoaded) {
          return Stack(
            children: [
              PanZoomMapView(
                floorplan: state.selectedFloorplan,
                overlayBuilder: _buildOverlay,
                onTap: (position) => _onMapClicked(position),
              ),
              Positioned.fill(child: _buildMouseRegion()),
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
      bloc: widget.contentBloc,
      listener: _contextBlocListener,
      builder: (context, state) {
        if (state is ContentLoaded) {
          final filteredTouchpoints = state.touchpoints.where((touchpoint) {
            if (touchpoint.position == null) {
              return false;
            }
            return _isPositionInView(touchpoint.position!.toOffset(), viewport);
          });

          final filteredBeacons = state.beacons.where((beacon) {
            return _isPositionInView(beacon.position.toOffset(), viewport);
          });

          return Stack(
            children: [
              ...filteredBeacons.map((b) {
                final offset = b.position.toOffset();
                return Positioned(
                  key: ValueKey("beacon-${b.beaconId}"),
                  left: offset.dx,
                  top: offset.dy,
                  child: BeaconMarker(
                    beacon: b,
                  ),
                );
              }),
              ...filteredTouchpoints.map((t) {
                final offset = t.position!.toOffset();
                return Positioned(
                  key: ValueKey(t.id),
                  left: offset.dx,
                  top: offset.dy,
                  child: Transform.scale(
                    scale: 1 / scale,
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(-74 / 2 * scale, -34 / 2 * scale),
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
                        style: state.selectedTouchpoint == t
                            ? TouchpointMarkerStyle.full
                            : scale > 0.5
                                ? TouchpointMarkerStyle.full
                                : scale > 0.2
                                    ? TouchpointMarkerStyle.icon
                                    : TouchpointMarkerStyle.tiny,
                      ),
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

  Widget _buildMouseRegion() {
    return BlocBuilder<ContentBloc, ContentState>(
        bloc: widget.contentBloc,
        builder: (context, state) {
          if (state is ContentLoaded && state.intent != null) {
            return MouseRegion(
              opaque: false,
              onHover: (event) {
                setState(() {
                  _mousePosition = event.localPosition;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  width: 8,
                )),
                child: Stack(
                  children: [
                    if (_mousePosition != null &&
                        state.intent == ContentIntent.placeTouchpoint)
                      Positioned(
                          left: _mousePosition!.dx - 8,
                          top: _mousePosition!.dy - 8,
                          child: Transform.translate(
                            offset: const Offset(-74 / 2, -34 / 2),
                            child: TouchpointMarker(
                              style: TouchpointMarkerStyle.icon,
                              icon: state.selectedTouchpoint!.type.icon,
                              backgroundColor:
                                  state.selectedTouchpoint!.type.color,
                              foregroundColor: state
                                          .selectedTouchpoint!.type.color
                                          .computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          )),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        });
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

class BeaconMarker extends StatelessWidget {
  const BeaconMarker({
    Key? key,
    required this.beacon,
  }) : super(key: key);

  final MBeacon beacon;

  @override
  Widget build(BuildContext context) {
    final double radius = beacon.radius ?? 200.0;
    return Transform.translate(
      offset: Offset(-radius / 2, -radius / 2),
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(.2),
            width: 8,
          ),
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        ),
      ),
    );
  }
}

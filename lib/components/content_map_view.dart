import 'package:enter_cms_flutter/components/pan_zoom_map_view.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/components/beacon_marker.dart';
import 'package:enter_cms_flutter/pages/content/components/touchpoint_marker.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/pages/content/content_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class ContentMapView extends ConsumerWidget {
  const ContentMapView({super.key});

  void _onMapClicked(WidgetRef ref, Offset position) {
    final tool = ref.read(contentMapToolControllerProvider);
    tool?.onMapClicked(position.dx, position.dy);
  }

  void _onSelectTouchpoint(WidgetRef ref, MTouchpoint touchpoint) {
    ref
        .read(contentViewControllerProvider.notifier)
        .selectTouchpoint(touchpoint.id!);
  }

  List<MTouchpoint> _touchpointsInView(
      List<MTouchpoint> touchpoints, vector_math.Quad viewport) {
    return touchpoints.where((touchpoint) {
      if (touchpoint.position == null) {
        return false;
      }
      return PanZoomMapView.isPositionInView(
          touchpoint.position!.toOffset(), viewport);
    }).toList();
  }

  List<MBeacon> _beaconsInView(
      List<MBeacon> beacons, vector_math.Quad viewport) {
    return beacons.where((beacon) {
      return PanZoomMapView.isPositionInView(
          beacon.position.toOffset(), viewport);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floorplan = ref.watch(selectedFloorplanProvider);
    return Stack(
      children: [
        PanZoomMapView(
          floorplan: floorplan,
          onTap: (position) => _onMapClicked(ref, position),
          overlayBuilder: (context, viewport, scale) => Stack(
            children: [
              _buildBeaconsOverlay(
                ref: ref,
                context: context,
                viewport: viewport,
                scale: scale,
              ),
              _buildTouchpointsOverlay(
                ref: ref,
                context: context,
                viewport: viewport,
                scale: scale,
              ),
            ],
          ),
        ),
        const ContentMapMouseRegion(),
      ],
    );
  }

  Widget _buildTouchpointsOverlay({
    required WidgetRef ref,
    required BuildContext context,
    required vector_math.Quad viewport,
    required double scale,
  }) {
    final touchpoints = ref.watch(touchpointsInViewProvider);
    final selectedTouchpointId = ref.watch(selectedTouchpointIdProvider);

    return Stack(
      children: [
        ..._touchpointsInView(touchpoints, viewport).map((t) {
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
                  onTap: () => _onSelectTouchpoint(ref, t),
                  label: t.touchpointId != null
                      ? t.touchpointId!.toString().padLeft(3, '0')
                      : 'XXX',
                  tooltip: t.internalTitle,
                  icon: t.type.icon,
                  backgroundColor: t.type.color,
                  foregroundColor: t.type.color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  style: t.id == selectedTouchpointId
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

  Widget _buildBeaconsOverlay({
    required WidgetRef ref,
    required BuildContext context,
    required vector_math.Quad viewport,
    required double scale,
  }) {
    final beacons = ref.watch(beaconsInViewProvider);

    return Stack(
      children: [
        ..._beaconsInView(beacons, viewport).map((b) {
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
      ],
    );
  }
}

class ContentMapMouseRegion extends ConsumerStatefulWidget {
  const ContentMapMouseRegion({super.key});

  @override
  ConsumerState<ContentMapMouseRegion> createState() =>
      _ContentMapMouseRegionState();
}

class _ContentMapMouseRegionState extends ConsumerState<ContentMapMouseRegion> {
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final tool = ref.watch(contentMapToolControllerProvider);

    if (tool == null) {
      return const SizedBox.shrink();
    }

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
            color: Theme.of(context).colorScheme.secondaryContainer,
            width: 8,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: tool,
              builder: (context, child) => Positioned(
                left: _mousePosition.dx - 8,
                top: _mousePosition.dy - 8,
                child: tool.cursor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

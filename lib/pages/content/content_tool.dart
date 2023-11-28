import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/models/position.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/components/beacon_marker.dart';
import 'package:enter_cms_flutter/pages/content/components/touchpoint_marker.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_tool.g.dart';

@riverpod
class ContentMapToolController extends _$ContentMapToolController {
  @override
  Raw<ContentTool?> build() {
    return null;
  }

  void selectTool(ContentTool tool) {
    // Cancel the previous tool, if any
    if (state != null) {
      state!.dispose();
    }

    state = tool;
    tool.onCreated();
  }

  void cancelTool() {
    if (state != null) {
      state!.dispose();
      state = null;
    }
  }
}

abstract class ContentTool extends ChangeNotifier {
  final WidgetRef ref;

  ContentTool(this.ref);

  Widget get cursor => const SizedBox.shrink();

  Future<void> onCreated() async {}
  Future<void> onMapClicked(double x, double y) async {}
}

class CreateTouchpointTool extends ContentTool {
  final TouchpointType type;

  CreateTouchpointTool(
    super.ref, {
    required this.type,
  });

  @override
  Widget get cursor {
    final bgColor = type.color;
    return Transform.translate(
      offset: const Offset(-74 / 2, -34 / 2),
      child: TouchpointMarker(
        style: TouchpointMarkerStyle.icon,
        icon: type.icon,
        backgroundColor: bgColor,
        foregroundColor:
            bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      ),
    );
  }

  @override
  Future<void> onMapClicked(double x, double y) async {
    final floorplanId = ref.read(selectedFloorplanIdProvider);

    final cmsApi = ref.read(cmsApiProvider);
    final touchpoint = await cmsApi.createTouchpoint(type,
        position: MPosition(
          parentId: floorplanId,
          x: x,
          y: y,
        ));

    ref
        .read(contentViewControllerProvider.notifier)
        .updateTouchpointInView(touchpoint, select: true);

    ref.invalidate(contentViewControllerProvider);

    ref.read(contentMapToolControllerProvider.notifier).cancelTool();
  }
}

class MoveBeaconTool extends ContentTool {
  final MBeacon beacon;

  MoveBeaconTool(
    super.ref, {
    required this.beacon,
  });

  @override
  Widget get cursor => BeaconMarker(
        beacon: beacon,
        forcedRadius: 100,
      );

  @override
  Future<void> onMapClicked(double x, double y) async {
    final floorplanId = ref.read(selectedFloorplanIdProvider);

    final cmsApi = ref.read(cmsApiProvider);
    await cmsApi.updateBeacon(
      beacon.id!,
      position: MPosition(
        parentId: floorplanId,
        x: x,
        y: y,
      ),
    );

    ref.invalidate(contentViewControllerProvider);
    ref.read(contentMapToolControllerProvider.notifier).cancelTool();
  }
}

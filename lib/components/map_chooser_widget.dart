import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/model/floorplan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MapChooserWidget extends ConsumerWidget {
  const MapChooserWidget({
    super.key,
  });

  void _onSelectFloorplan(
      BuildContext context, WidgetRef ref, int floorplanId) {
    final selectedFloorplanId = ref.read(selectedFloorplanIdProvider);
    if (selectedFloorplanId != floorplanId) {
      context.goNamed(
        'content-floorplan',
        pathParameters: {
          'floorplanId': floorplanId.toString(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContentNavWidget(
      title: const Text('Floorplan'),
      child: _buildBody(context, ref),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return ref.watch(floorplanManagerProvider).maybeWhen(
          data: (data) => _buildFloorplanList(
            context: context,
            ref: ref,
            floorplans: data,
          ),
          loading: () => const LinearProgressIndicator(),
          orElse: () => const SizedBox.shrink(),
        );
  }

  Widget _buildFloorplanList({
    required BuildContext context,
    required WidgetRef ref,
    required List<MFloorplan> floorplans,
  }) {
    final selectedFloorplanId = ref.watch(selectedFloorplanIdProvider);
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: floorplans.length,
        itemBuilder: (context, index) {
          final floorplan = floorplans[index];
          final isSelected = floorplan.id == selectedFloorplanId;
          return ListTile(
            dense: true,
            selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
            selectedColor: Theme.of(context).colorScheme.onSecondaryContainer,
            title: Text(
              floorplan.title ?? 'Untitled',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
            selected: isSelected,
            onTap: () => _onSelectFloorplan(context, ref, floorplan.id),
          );
        },
      ),
    );
  }
}

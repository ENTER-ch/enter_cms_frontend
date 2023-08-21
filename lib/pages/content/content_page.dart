import 'package:enter_cms_flutter/components/content_list_view.dart';
import 'package:enter_cms_flutter/components/content_map_view.dart';
import 'package:enter_cms_flutter/components/content_toolbar.dart';
import 'package:enter_cms_flutter/components/map_chooser_widget.dart';
import 'package:enter_cms_flutter/components/touchpoint_editor.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/model/floorplan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetIt getIt = GetIt.instance;

class ContentPageLoader extends ConsumerWidget {
  final String? floorplanId;

  const ContentPageLoader({
    super.key,
    this.floorplanId,
  });

  // void _tryRedirect(BuildContext context, WidgetRef ref) {
  //   if (floorplanId != null) {
  //     SchedulerBinding.instance.addPostFrameCallback((_) {
  //       context.goNamed(
  //         'content-floorplan',
  //         pathParameters: {
  //           'floorplanId': floorplanId!,
  //         },
  //       );
  //     });
  //   }
  // }

  void _redirectToFloorplan(BuildContext context, String floorplanId) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.goNamed(
        'content-floorplan',
        pathParameters: {
          'floorplanId': floorplanId,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(floorplanManagerProvider).when(
          data: (floorplans) {
            if (floorplans.isEmpty) {
              // TODO Prettier placeholder
              return const Center(
                child: Text('Create a floorplan on the admin page to continue'),
              );
            }

            if (floorplanId == null) {
              _redirectToFloorplan(context, floorplans.first.id.toString());
              return _buildLoadingPlaceholder(context);
            }

            return ContentPage(
              floorplanId: int.parse(floorplanId!),
            );
          },
          loading: () => _buildLoadingPlaceholder(context),
          error: (error, stackTrace) {
            // TODO More informative error page
            return Center(
              child: Text(error.toString()),
            );
          },
        );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    // TODO Prettier loading placeholder
    return const Column(
      children: [
        LinearProgressIndicator(),
      ],
    );
  }
}

class ContentPage extends ConsumerWidget {
  final int floorplanId;

  const ContentPage({
    super.key,
    required this.floorplanId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        selectedFloorplanIdProvider.overrideWithValue(floorplanId),
      ],
      child: const Row(
        children: [
          SizedBox(
            width: 200,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapChooserWidget(),
                  Divider(),
                  TouchpointSearch(),
                  Divider(),
                ],
              ),
            ),
          ),
          VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                ContentToolbar(),
                Divider(),
                Expanded(
                  child: ContentMapView(),
                ),
                Divider(),
                SizedBox(
                  height: 250,
                  child: ContentListView(),
                )
              ],
            ),
          ),
          VerticalDivider(),
          InspectorPane(),
        ],
      ),
    );
  }
}

class InspectorPane extends ConsumerWidget {
  const InspectorPane({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTouchpointId = ref.watch(selectedTouchpointIdProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: selectedTouchpointId != null ? 300 : 0,
      child: Stack(
        children: [
          Positioned(
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedTouchpointId != null)
                    TouchpointEditorWidget(
                      key: ValueKey(selectedTouchpointId),
                      touchpointId: selectedTouchpointId,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TouchpointSearch extends HookConsumerWidget {
  const TouchpointSearch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(floorplanViewSearchProvider);

    final searchController = useTextEditingController(text: searchQuery);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          isDense: true,
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: () {
              searchController.clear();
              ref.invalidate(floorplanViewSearchProvider);
            },
            icon: Icon(
              Icons.clear,
              size: 16,
            ),
          ),
          // suffix: ToolbarButton(
          //   icon: Icons.clear,
          // ),
        ),
        onChanged: (value) {
          ref.read(floorplanViewSearchProvider.notifier).updateQuery(value);
        },
      ),
    );
  }
}

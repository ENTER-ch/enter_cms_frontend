import 'package:enter_cms_flutter/components/content_list_view.dart';
import 'package:enter_cms_flutter/components/content_map_view.dart';
import 'package:enter_cms_flutter/components/content_toolbar.dart';
import 'package:enter_cms_flutter/pages/content/components/content_inspector.dart';
import 'package:enter_cms_flutter/pages/content/components/release_panel.dart';
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
      child: Row(
        key: ValueKey("content-$floorplanId"),
        children: const [
          Expanded(
            child: Column(
              children: [
                ContentToolbar(),
                Divider(),
                ContentMainView(),
                Divider(),
                ReleasePanel(),
              ],
            ),
          ),
          VerticalDivider(),
          SizedBox(
            width: 500,
            height: double.infinity,
            child: InspectorPane(),
          ),
        ],
      ),
    );
  }
}

class ContentMainView extends ConsumerWidget {
  const ContentMainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContentView = ref.watch(selectedContentViewProvider);

    return Expanded(
      child: switch (selectedContentView) {
        ContentView.map => const ContentMapView(),
        ContentView.list => const ContentListView(),
      },
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
            icon: const Icon(
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

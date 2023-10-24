import 'package:enter_cms_flutter/components/content_list_view.dart';
import 'package:enter_cms_flutter/components/content_map_view.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/content_toolbar.dart';
import 'package:enter_cms_flutter/components/map_chooser_widget.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/components/touchpoint_editor.dart';
import 'package:enter_cms_flutter/models/release.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:enter_cms_flutter/providers/model/floorplan_provider.dart';
import 'package:enter_cms_flutter/providers/model/release_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:enter_cms_flutter/providers/state/touchpoint_detail.dart';
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

class InspectorPane extends ConsumerWidget {
  const InspectorPane({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTouchpointId = ref.watch(selectedTouchpointIdProvider);
    return ContentNavWidget(
      title: const Text('Editor'),
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedTouchpointId != null)
                TouchpointEditorWidget(
                  key: ValueKey(selectedTouchpointId),
                  touchpointId: selectedTouchpointId,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Select a touchpoint to start editing.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReleasePanel extends ConsumerWidget {
  const ReleasePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRelease = ref.watch(releaseProvider(null));

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: currentRelease.maybeWhen(
                data: (release) => Tooltip(
                  message: release.title ?? '',
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: release.status.color),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "Latest Release: ${release.label}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
          const VerticalDivider(),
          ToolbarButton(
            icon: Icons.publish,
            label: 'Create Release',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const CreateReleaseDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CreateReleaseDialog extends HookConsumerWidget {
  const CreateReleaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releasePreview = ref.watch(releasePreviewProvider);

    final releaseNotesController = useTextEditingController();

    onCreate() async {
      await ref.read(cmsApiProvider).createRelease(
            title: releaseNotesController.text,
          );
      ref.invalidate(releaseProvider(null));
      ref.invalidate(touchpointProvider);
      if (context.mounted) Navigator.of(context).pop();
    }

    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 800,
        height: 500,
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                title: Text('Create Release',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(),
              Expanded(
                child: releasePreview.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  data: (data) {
                    return Column(
                      children: [
                        ListTile(
                            title: Text(
                                "This release will contain ${data.count} touchpoints.")),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: releaseNotesController,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              hintText: 'Release notes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onCreate,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

import 'package:cross_file/cross_file.dart';
import 'package:enter_cms_flutter/components/ag_content_edit_dialog.dart';
import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/ag_touchpoint_config.dart';
import 'package:enter_cms_flutter/models/media_track.dart';
import 'package:enter_cms_flutter/providers/model/ag_config_provider.dart';
import 'package:enter_cms_flutter/providers/model/ag_content_provider.dart';
import 'package:enter_cms_flutter/providers/model/media_language_provider.dart';
import 'package:enter_cms_flutter/providers/model/media_track_provider.dart';
import 'package:enter_cms_flutter/providers/model/touchpoint_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetIt getIt = GetIt.instance;

class AGTouchpointEditor extends HookConsumerWidget {
  final int id;

  const AGTouchpointEditor({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGTouchpointConfigProvider(id));
    ref.watch(mediaLanguageListProvider);

    return state.maybeWhen(
      data: (config) => ContentNavWidget(
        title: const Text('Audioguide Settings'),
        child: Column(
          children: [
            AGPlaybackModeTile(id: id),
            const Divider(),
            ContentNavWidget(
              title: const Text("Content"),
              child: Column(
                children: [
                  ...config.contents.map(
                    (e) => AGContentListTile(id: e.id!),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.add),
                    title: const Text('Add Content'),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AGContentEditDialog.create(
                          agTouchpointId: id,
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class AGPlaybackModeTile extends ConsumerWidget {
  const AGPlaybackModeTile({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGTouchpointConfigProvider(id));

    return state.maybeWhen(
      data: (config) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            children: [
              const Expanded(
                child: ListTile(
                  dense: true,
                  title: Text('Playback Mode'),
                ),
              ),
              ToggleButtons(
                renderBorder: false,
                isSelected: [
                  config.playbackMode == AGPlaybackMode.autoSingle,
                  config.playbackMode == AGPlaybackMode.autoLoop,
                  config.playbackMode == AGPlaybackMode.prompt,
                ],
                onPressed: (int index) {
                  ref
                      .read(aGTouchpointConfigProvider(id).notifier)
                      .updateConfig(
                        playbackMode: AGPlaybackMode.values[index],
                      );
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.autoSingle.label),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.autoLoop.label),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AGPlaybackMode.prompt.label),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class AGContentListTile extends HookConsumerWidget {
  final int id;

  const AGContentListTile({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aGContentProvider(id));

    return state.maybeWhen(
      data: (content) {
        final mediaTrackState = content.mediaTrackId != null
            ? ref.watch(mediaTrackProvider(content.mediaTrackId!))
            : const AsyncValue.data(null);

        return Row(
          children: [
            Expanded(
              child: ListTile(
                dense: true,
                title: Text(content.shortLabel),
                subtitle: mediaTrackState.valueOrNull?.previewUrl != null
                    ? InlineAudioPlayer(url: mediaTrackState.value!.previewUrl!)
                    : const Text('No Media'),
                leading: CircleAvatar(
                  child: Text(
                    (content.language ?? 'Unknown').toUpperCase(),
                  ),
                ),
              ),
            ),
            ToolbarButton(
                icon: Icons.edit,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AGContentEditDialog.edit(
                      agContentId: id,
                    ),
                  );
                }),
            const SizedBox(width: 8),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

import 'package:enter_cms_flutter/components/ag_content_preview.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:enter_cms_flutter/components/inline_audio_player.dart';
import 'package:enter_cms_flutter/components/media_upload_list_tile.dart';
import 'package:enter_cms_flutter/models/ag_content.dart';
import 'package:enter_cms_flutter/models/media_language.dart';
import 'package:enter_cms_flutter/providers/model/ag_config_provider.dart';
import 'package:enter_cms_flutter/providers/model/ag_content_provider.dart';
import 'package:enter_cms_flutter/providers/model/media_language_provider.dart';
import 'package:enter_cms_flutter/providers/model/media_track_provider.dart';
import 'package:enter_cms_flutter/providers/model/touchpoint_provider.dart';
import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AGContentEditDialog extends HookConsumerWidget {
  final int? agTouchpointId;
  final int? agContentId;
  final bool edit;

  const AGContentEditDialog({
    super.key,
    this.agTouchpointId,
    this.agContentId,
    this.edit = false,
  });

  const AGContentEditDialog.create({
    super.key,
    required this.agTouchpointId,
  })  : edit = false,
        agContentId = null;

  const AGContentEditDialog.edit({
    super.key,
    required this.agContentId,
  })  : edit = true,
        agTouchpointId = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languages = ref.watch(mediaLanguageListProvider);
    final initializedForm = useState(false);
    final selectedLanguage = useState(MMediaLanguage.empty());
    final labelController = useTextEditingController();
    final labelText = useState<String>('');

    final mediaTrackId = useState<int?>(null);

    labelController.addListener(() {
      labelText.value = labelController.text;
    });

    if (edit && initializedForm.value == false) {
      final contentState = ref.watch(aGContentProvider(agContentId!));
      contentState.whenData((content) {
        labelController.text = content.label ?? '';
        labelText.value = content.label ?? '';
        languages.whenData((data) {
          selectedLanguage.value = data.firstWhere(
            (lang) => lang.shortCode == content.language,
            orElse: () => MMediaLanguage.empty(),
          );
        });
        mediaTrackId.value = content.mediaTrackId;
        initializedForm.value = true;
      });
    }

    onSave() async {
      final cmsApi = ref.read(cmsApiProvider);

      if (edit) {
        await cmsApi.updateAGContent(
          agContentId!,
          label: labelText.value,
          language: selectedLanguage.value.shortCode,
          mediaTrackId: mediaTrackId.value,
          clearMediaTrackId: mediaTrackId.value == null,
        );

        ref.invalidate(aGContentProvider(agContentId!));
      } else {
        await cmsApi.createAGContent(
          agTouchpointId!,
          label: labelText.value,
          language: selectedLanguage.value.shortCode,
          mediaTrackId: mediaTrackId.value,
        );

        ref.invalidate(aGTouchpointConfigProvider(agTouchpointId!));
      }

      // TODO This could be made more specific
      ref.invalidate(touchpointProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    onDelete() async {
      final cmsApi = ref.read(cmsApiProvider);
      final confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this content?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
      if (confirmDelete) {
        await cmsApi.deleteAGContent(agContentId!);
        ref.invalidate(aGContentProvider(agContentId!));
        // TODO This could be made more specific
        ref.invalidate(touchpointProvider);
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    buildLanguageTile() {
      return Row(
        children: [
          const Expanded(
            child: ListTile(
              dense: true,
              title: Text('Language'),
            ),
          ),
          languages.when(
            data: (languages) => DropdownButton<MMediaLanguage>(
              underline: const SizedBox(),
              padding: const EdgeInsets.only(left: 8.0),
              value: selectedLanguage.value,
              hint: const Text('Select Language'),
              onChanged: (MMediaLanguage? newValue) {
                if (newValue != null) {
                  selectedLanguage.value = newValue;
                }
              },
              items: languages.map<DropdownMenuItem<MMediaLanguage>>(
                (MMediaLanguage lang) {
                  return DropdownMenuItem<MMediaLanguage>(
                    value: lang,
                    child: Text(lang.name ?? 'Unknown'),
                  );
                },
              ).toList(),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      );
    }

    buildLabelTile() => ListTile(
          title: TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
            ),
            maxLines: 4,
          ),
        );

    buildPreview() => Column(
          children: [
            ContentNavWidget(
              title: const Text('Preview'),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                ),
                child: SizedBox(
                  height: 200,
                  child: AGContentPreview(
                      content: MAGContent(
                    label: labelText.value,
                  )),
                ),
              ),
            ),
          ],
        );

    buildMediaTile() {
      if (mediaTrackId.value == null) {
        return Column(
          children: [
            const ListTile(
              dense: true,
              title: Text('Media'),
            ),
            MediaUploadListTile(
              onUpload: (track) {
                mediaTrackId.value = track.id;
              },
            ),
          ],
        );
      } else {
        final mediaTrackState =
            ref.watch(mediaTrackProvider(mediaTrackId.value!));

        return Column(
          children: [
            const ListTile(
              dense: true,
              title: Text('Media'),
            ),
            mediaTrackState.maybeWhen(
              data: (track) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: InlineAudioPlayer(url: track.previewUrl!),
              ),
              loading: () => const LinearProgressIndicator(),
              orElse: () => const SizedBox.shrink(),
            ),
            ListTile(
              dense: true,
              title: const Text('Delete Media'),
              leading: const Icon(Icons.delete),
              onTap: () {
                mediaTrackId.value = null;
              },
            ),
          ],
        );
      }
    }

    buildActions() => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (edit)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              )
            ],
          ),
        );

    return Dialog(
      elevation: 0,
      child: SizedBox(
        width: 800,
        height: 500,
        child: IntrinsicHeight(
          child: Column(
            children: [
              ListTile(
                title: Text(edit ? 'Edit Content' : 'Create Content',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Divider(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          buildLanguageTile(),
                          const Divider(),
                          buildLabelTile(),
                          const Divider(),
                          buildMediaTile(),
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    buildPreview(),
                  ],
                ),
              ),
              const Divider(),
              buildActions(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/release.dart';
import 'package:enter_cms_flutter/pages/content/components/create_release_dialog.dart';
import 'package:enter_cms_flutter/providers/model/release_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

import 'package:data_table_2/data_table_2.dart';
import 'package:enter_cms_flutter/components/beacon_edit_dialog.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:enter_cms_flutter/providers/model/beacon_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BeaconsPage extends ConsumerWidget {
  const BeaconsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beacons = ref.watch(beaconListProvider);

    final List<MBeacon> elements = beacons.maybeWhen(
      data: (beacons) => beacons,
      loading: () => const [],
      error: (e, _) => throw e,
      orElse: () => const [],
    );

    return Column(
      children: [
        Expanded(
          child: DataTable2(
            headingRowHeight: 36,
            dataRowHeight: 36,
            horizontalMargin: 16,
            columns: const [
              DataColumn2(
                label: Text('ID'),
                fixedWidth: 150,
              ),
              DataColumn2(
                label: Text('Location'),
                fixedWidth: 200,
              ),
              DataColumn2(
                label: Text('Touchpoint'),
                fixedWidth: 400,
              ),
              DataColumn2(
                label: Text('Actions'),
              ),
            ],
            rows: elements
                .map((e) => DataRow2(
                      //selected: e.id == selectedTouchpointId,
                      //onTap: () => _onSelectTouchpoint(ref, e),
                      cells: [
                        DataCell(Text(e.idHexString ?? 'N/A')),
                        DataCell(Row(
                          children: [
                            Text(e.position?.parentTitle ?? 'Not set'),
                            const Spacer(),
                            if (e.position?.parentId != null)
                              ToolbarButton(
                                  icon: Icons.open_in_new,
                                  onTap: () {
                                    context
                                        .go('/content/${e.position?.parentId}');
                                  }),
                          ],
                        )),
                        DataCell(Text(e.touchpointTitle ??
                            (e.touchpointId != null
                                ? 'Touchpoint ${e.touchpointId.toString()}'
                                : 'N/A'))),
                        DataCell(
                          Row(
                            children: [
                              ToolbarButton(
                                icon: Icons.delete,
                                onTap: () async {
                                  await ref
                                      .read(beaconProvider(e.id!).notifier)
                                      .delete();
                                  ref.invalidate(beaconListProvider);
                                },
                              ),
                              ToolbarButton(
                                icon: Icons.edit,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BeaconEditDialog(
                                      beaconId: e.id!,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

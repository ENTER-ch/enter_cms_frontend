import 'package:data_table_2/data_table_2.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:enter_cms_flutter/pages/content/content_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentListView extends ConsumerStatefulWidget {
  const ContentListView({
    super.key,
  });

  @override
  ConsumerState<ContentListView> createState() => _ContentListViewState();
}

class _ContentListViewState extends ConsumerState<ContentListView> {
  void _onSort(WidgetRef ref, int columnIndex, bool ascending) {
    ref
        .read(floorplanViewSortingStateProvider.notifier)
        .setByColIndex(columnIndex, ascending: ascending);
  }

  void _onSelectTouchpoint(WidgetRef ref, MTouchpoint touchpoint) {
    ref
        .read(contentViewControllerProvider.notifier)
        .selectTouchpoint(touchpoint.id!);
  }

  @override
  Widget build(BuildContext context) {
    final sorting = ref.watch(floorplanViewSortingStateProvider);
    final elements = ref.watch(touchpointsSortedProvider);
    final selectedTouchpointId = ref.watch(selectedTouchpointIdProvider);
    return DataTable2(
      headingRowHeight: 36,
      dataRowHeight: 36,
      horizontalMargin: 16,
      sortColumnIndex: sorting.colIndex,
      sortAscending: sorting.ascending,
      columns: [
        DataColumn2(
          label: const Text('Type'),
          fixedWidth: 80,
          onSort: (index, ascending) => _onSort(ref, index, ascending),
        ),
        DataColumn2(
          label: const Text('ID'),
          fixedWidth: 90,
          onSort: (index, ascending) => _onSort(ref, index, ascending),
        ),
        DataColumn2(
          label: const Text('Title'),
          onSort: (index, ascending) => _onSort(ref, index, ascending),
        ),
        DataColumn2(
          label: const Text(
            'Status',
            textAlign: TextAlign.right,
          ),
          fixedWidth: 90,
          onSort: (index, ascending) => _onSort(ref, index, ascending),
        ),
        // const DataColumn2(
        //   label: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       // if (widget.expanded != null) ToolbarButton(
        //       //   icon: widget.expanded! ? Icons.close_fullscreen : Icons.open_in_full,
        //       //   onTap: () => widget.onExpand?.call(!widget.expanded!),
        //       // ),
        //     ],
        //   ),
        // ),
      ],
      rows: elements
          .map((e) => DataRow2(
                selected: e.id == selectedTouchpointId,
                onTap: () => _onSelectTouchpoint(ref, e),
                cells: [
                  DataCell(Tooltip(
                    message: e.type.uiTitle,
                    child: Icon(
                      e.type.icon,
                      color: e.type.color,
                      size: 20,
                    ),
                  )),
                  DataCell(Text(e.touchpointIdString)),
                  DataCell(Text(e.title)),
                  DataCell(Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: e.statusLabel,
                        child: Icon(
                          Icons.circle,
                          color: e.getStatusColor(context),
                          size: 16,
                        ),
                      ),
                    ],
                  )),
                  //const DataCell(SizedBox()),
                ],
              ))
          .toList(),
    );
  }
}

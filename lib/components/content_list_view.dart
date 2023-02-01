import 'package:data_table_2/data_table_2.dart';
import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/components/toolbar_button.dart';
import 'package:enter_cms_flutter/models/touchpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentListView extends StatefulWidget {
  const ContentListView({
    Key? key,
    required this.contentBloc,
    this.expanded,
    this.onExpand,
  }) : super(key: key);

  final ContentBloc contentBloc;
  final bool? expanded;
  final void Function(bool expanded)? onExpand;

  @override
  State<ContentListView> createState() => _ContentListViewState();
}

class _ContentListViewState extends State<ContentListView> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<MTouchpoint> _sortRows(List<MTouchpoint> items) {
    if (_sortColumnIndex == null) {
      return items;
    }
    final isAscending = _sortAscending;
    switch (_sortColumnIndex) {
      case 0:
        items.sort((a, b) => a.type.name.compareTo(b.type.name));
        break;
      case 1:
        items.sort((a, b) => a.touchpointId?.compareTo(b.touchpointId ?? 0) ?? 0);
        break;
      case 2:
        items.sort((a, b) => a.internalTitle?.compareTo(b.internalTitle ?? '') ?? 0);
        break;
    }
    if (!isAscending) {
      items = items.reversed.toList();
    }
    return items;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onSelectTouchpoint(MTouchpoint touchpoint) {
    widget.contentBloc
        .add(ContentEventSelectTouchpoint(touchpoint: touchpoint));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContentBloc, ContentState>(
      bloc: widget.contentBloc,
      builder: (context, state) {
        if (state is ContentLoaded) {
          return DataTable2(
            headingRowHeight: 36,
            dataRowHeight: 36,
            horizontalMargin: 16,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            columns: [
              DataColumn2(
                label: const Text('Type'),
                fixedWidth: 80,
                onSort: _onSort,
              ),
              DataColumn2(
                label: const Text('ID'),
                fixedWidth: 90,
                onSort: _onSort,
              ),
              DataColumn2(
                label: const Text('Title'),
                onSort: _onSort,
              ),
              DataColumn2(label: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.expanded != null) ToolbarButton(
                    icon: widget.expanded! ? Icons.close_fullscreen : Icons.open_in_full,
                    onTap: () => widget.onExpand?.call(!widget.expanded!),
                  ),
                ]
              )),
            ],
            rows: _sortRows(state.touchpoints)
                .map((e) => DataRow2(
                      selected: state.selectedTouchpoint?.id == e.id,
                      onTap: () => _onSelectTouchpoint(e),
                      cells: [
                        DataCell(Tooltip(
                          message: e.type.uiTitle,
                          child: Icon(
                            e.type.icon,
                            color: e.type.color,
                            size: 20,
                          ),
                        )),
                        DataCell(
                            Text(e.touchpointId.toString().padLeft(3, '0'))),
                        DataCell(Text(e.internalTitle ?? '')),
                        const DataCell(SizedBox()),
                      ],
                    ))
                .toList(),
          );
        }
        return Column(
          children: const [
            LinearProgressIndicator(),
          ],
        );
      },
    );
  }
}

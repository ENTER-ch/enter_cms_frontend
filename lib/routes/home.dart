import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/bloc/map/map_bloc.dart';
import 'package:enter_cms_flutter/components/content_list_view.dart';
import 'package:enter_cms_flutter/components/content_map_view.dart';
import 'package:enter_cms_flutter/components/content_toolbar.dart';
import 'package:enter_cms_flutter/components/map_chooser_widget.dart';
import 'package:enter_cms_flutter/components/touchpoint_editor.dart';
import 'package:enter_cms_flutter/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

GetIt getIt = GetIt.instance;

class ContentScreen extends StatefulWidget {
  const ContentScreen({
    Key? key,
    this.floorplanId,
    this.touchpointId,
  }) : super(key: key);

  final int? floorplanId;
  final int? touchpointId;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late MapBloc _mapBloc;
  late ContentBloc _contentBloc;

  bool _expandMap = false;
  bool _expandList = false;

  @override
  void initState() {
    super.initState();

    final cmsApi = getIt<CmsApi>();

    _mapBloc = MapBloc(cmsApi: cmsApi);
    _mapBloc.add(MapEventLoad(floorplanId: widget.floorplanId));

    _contentBloc = ContentBloc(cmsApi: cmsApi);
  }

  void _mapBlocListener(BuildContext context, MapState state) {
    if (state is MapLoaded && state.selectedFloorplan != null) {
      _contentBloc.add(ContentEventLoad(
        floorplanId: state.selectedFloorplan!.id,
        touchpointId: widget.touchpointId,
      ));
      _updateQuery();
    }
  }

  void _contentBlocListener(BuildContext context, ContentState state) {
    if (state is ContentLoaded && state.selectedTouchpoint?.id != null) {
      _updateQuery();
    }
  }

  void _updateQuery() {
    String query = '';
    if (_mapBloc.state is MapLoaded) {
      final mapState = _mapBloc.state as MapLoaded;
      if (mapState.selectedFloorplan?.id != null) {
        query += 'f=${mapState.selectedFloorplan?.id}';
      }
    }
    if (_contentBloc.state is ContentLoaded) {
      final contentState = _contentBloc.state as ContentLoaded;
      if (contentState.selectedTouchpoint?.id != null) {
        if (query.isNotEmpty) {
          query += '&';
        }
        query += 't=${contentState.selectedTouchpoint?.id}';
      }
    }
    if (query.isNotEmpty) {
      context.go('/content?$query');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
            bloc: _mapBloc, listener: _mapBlocListener),
        BlocListener<ContentBloc, ContentState>(
            bloc: _contentBloc, listener: _contentBlocListener),
      ],
      child: Row(
        children: [
          SizedBox(
              width: 200,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapChooserWidget(mapBloc: _mapBloc),
                    const Divider(),
                  ],
                ),
              )),
          const VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                ContentToolbar(
                  contentBloc: _contentBloc,
                ),
                const Divider(),
                if (!_expandList)
                  Expanded(
                      child: ContentMapView(
                    mapBloc: _mapBloc,
                    contentBloc: _contentBloc,
                  )),
                if (!_expandList && !_expandMap) const Divider(),
                if (!_expandMap)
                  SizedBox(
                    height: 250,
                    child: ContentListView(
                      contentBloc: _contentBloc,
                      onExpand: (expand) {
                        setState(() {
                          if (expand) _expandMap = false;
                          _expandList = expand;
                          print('expand list: $_expandList');
                        });
                      },
                      expanded: _expandList,
                    ),
                  )
              ],
            ),
          ),
          const VerticalDivider(),
          SizedBox(
            width: 300,
            height: double.infinity,
            child: InspectorPane(
              contentBloc: _contentBloc,
            ),
          ),
        ],
      ),
    );
  }
}

class InspectorPane extends StatelessWidget {
  const InspectorPane({
    Key? key,
    required this.contentBloc,
  }) : super(key: key);

  final ContentBloc contentBloc;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<ContentBloc, ContentState>(
            bloc: contentBloc,
            builder: (context, state) {
              if (state is ContentLoaded) {
                if (state.selectedTouchpoint != null) {
                  return TouchpointEditorWidget(
                      key: ValueKey(state.selectedTouchpoint!.id),
                      touchpoint: state.selectedTouchpoint!,
                      onTouchpointLoaded: (touchpoint) {
                        contentBloc.add(ContentEventUpdateTouchpoint(
                          touchpoint: touchpoint,
                          internal: true,
                        ));
                      });
                }
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}

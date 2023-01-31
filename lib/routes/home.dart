import 'package:enter_cms_flutter/api/content_api.dart';
import 'package:enter_cms_flutter/api/mock/content_mock_api.dart';
import 'package:enter_cms_flutter/api/mock/location_mock_api.dart';
import 'package:enter_cms_flutter/bloc/content/content_bloc.dart';
import 'package:enter_cms_flutter/bloc/map/map_bloc.dart';
import 'package:enter_cms_flutter/components/content_list_view.dart';
import 'package:enter_cms_flutter/components/content_map_view.dart';
import 'package:enter_cms_flutter/components/content_toolbar.dart';
import 'package:enter_cms_flutter/components/map_chooser_widget.dart';
import 'package:enter_cms_flutter/components/touchpoint_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key}) : super(key: key);

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late MapBloc _mapBloc;
  late ContentBloc _contentBloc;

  @override
  void initState() {
    super.initState();

    _mapBloc = MapBloc(
      locationApi: LocationMockApi(),
    );
    _mapBloc.add(const MapEventLoad());

    _contentBloc = ContentBloc(
      contentApi: getIt<ContentApi>(),
    );
  }

  void _mapBlocListener(BuildContext context, MapState state) {
    if (state is MapLoaded && state.selectedFloorplan != null) {
      _contentBloc
          .add(ContentEventLoad(floorplanId: state.selectedFloorplan!.id));
    }
  }

  void _contentBlocListener(BuildContext context, ContentState state) {
    // if (state is ContentLoaded && state.selectedTouchpoint == null) {
    //   _contentBloc.add(
    //       ContentEventSelectTouchpoint(touchpoint: state.touchpoints.first));
    // }
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
              child: Column(
                children: [
                  SizedBox(
                      height: 200, child: MapChooserWidget(mapBloc: _mapBloc)),
                  const Divider(),
                ],
              )),
          const VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                const ContentToolbar(),
                const Divider(),
                Expanded(
                    child: ContentMapView(
                  mapBloc: _mapBloc,
                  contentBloc: _contentBloc,
                )),
                const Divider(),
                SizedBox(
                  height: 250,
                  child: ContentListView(contentBloc: _contentBloc),
                )
              ],
            ),
          ),
          const VerticalDivider(),
          SizedBox(
            width: 300,
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
    return Column(
      children: [
        BlocBuilder<ContentBloc, ContentState>(
          bloc: contentBloc,
          builder: (context, state) {
            if (state is ContentLoaded) {
              if (state.selectedTouchpoint != null) {
                return TouchpointEditorWidget(
                  key: ValueKey(state.selectedTouchpoint!.id),
                  contentBloc: contentBloc,
                  touchpoint: state.selectedTouchpoint!,
                );
              }
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}

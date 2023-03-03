import 'package:enter_cms_flutter/bloc/map/map_bloc.dart';
import 'package:enter_cms_flutter/components/content_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapChooserWidget extends StatelessWidget {
  const MapChooserWidget({
    Key? key,
    required this.mapBloc,
  }) : super(key: key);

  final MapBloc mapBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      bloc: mapBloc,
      builder: (context, state) {
        return ContentNavWidget(
          title: const Text('Floorplan'),
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MapState state) {
    if (state is MapLoaded) {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: state.floorplans.length,
          itemBuilder: (context, index) {
            final floorplan = state.floorplans[index];
            return ListTile(
              dense: true,
              selectedTileColor:
              Theme.of(context).colorScheme.surfaceTint.withOpacity(0.1),
              title: Text(floorplan.title ?? 'Untitled'),
              selected: floorplan.id == state.selectedFloorplan?.id,
              onTap: () {
                mapBloc.add(MapEventSelectFloorplan(floorplan: floorplan));
              },
            );
          },
        ),
      );
    }
    return const SizedBox();
  }
}
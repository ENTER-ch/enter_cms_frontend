import 'dart:ui' as ui;

import 'package:bloc/bloc.dart';
import 'package:enter_cms_flutter/services/asset_loader.dart';
import 'package:equatable/equatable.dart';

part 'ag_content_preview_event.dart';

part 'ag_content_preview_state.dart';

class AgContentPreviewBloc extends Bloc<AgContentPreviewEvent, AgContentPreviewState> {
  final AssetLoaderService assetLoaderService;

  AgContentPreviewBloc({
    required this.assetLoaderService,
  }) : super(AgContentPreviewInitial()) {
    on<AgContentPreviewEventLoad>(_onLoad);
  }

  void _onLoad(AgContentPreviewEventLoad event,
      Emitter<AgContentPreviewState> emit) async {
    emit(AgContentPreviewLoading());

    final assets = await assetLoaderService.loadAGPreviewAssets();

    emit(AgContentPreviewLoaded(assets: assets));
  }
}

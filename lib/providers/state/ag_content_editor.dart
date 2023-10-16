// import 'package:enter_cms_flutter/models/ag_content.dart';
// import 'package:enter_cms_flutter/providers/services/cms_api_provider.dart';
// import 'package:enter_cms_flutter/providers/state/ag_touchpoint_editor.dart';
// import 'package:enter_cms_flutter/providers/state/touchpoint_detail.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'ag_content_editor.g.dart';

// @Riverpod(dependencies: [
//   agTouchpointConfig,
// ])
// class SelectedAGContentId extends _$SelectedAGContentId {
//   @override
//   int? build() {
//     final agConfig = ref.watch(agTouchpointConfigProvider);
//     return agConfig?.contents.firstOrNull?.id;
//   }

//   void select(int id) {
//     state = id;
//   }
// }

// @Riverpod(dependencies: [
//   SelectedAGContentId,
//   cmsApi,
// ])
// class AGContentEditor extends _$AGContentEditor {
//   Future<MAGContent> _fetchAGContent(int id) async {
//     final repository = ref.watch(cmsApiProvider);
//     return await repository.getAGContent(id);
//   }

//   @override
//   FutureOr<MAGContent> build() async {
//     final id = ref.watch(selectedAGContentIdProvider);
//     if (id == null) throw Exception('No Content Selected');
//     return _fetchAGContent(id);
//   }

//   Future<MAGContent?> updateContent({
//     String? label,
//     String? language,
//     int? mediaTrackId,
//   }) async {
//     if (state.isLoading || state.hasError) return null;

//     final api = ref.watch(cmsApiProvider);
//     final result = await api.updateAGContent(
//       state.value!.id!,
//       label: label,
//       language: language,
//       mediaTrackId: mediaTrackId,
//     );
//     state = AsyncValue.data(result);
//     ref.invalidate(touchpointDetailStateProvider);
//     return result;
//   }
// }

// @Riverpod(dependencies: [
//   AGContentEditor,
// ])
// class AGContentLabelField extends _$AGContentLabelField {
//   @override
//   FutureOr<String?> build() async {
//     final content = ref.watch(aGContentEditorProvider);
//     return content.value?.label;
//   }

//   Future<void> updateValue(String value) async {
//     final contentEditor = ref.read(aGContentEditorProvider.notifier);
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final updated = await contentEditor.updateContent(
//         label: value,
//       );
//       return updated?.label;
//     });
//   }
// }

// @Riverpod(dependencies: [
//   AGContentEditor,
// ])
// class AGContentLanguageField extends _$AGContentLanguageField {
//   @override
//   FutureOr<String?> build() async {
//     final content = ref.watch(aGContentEditorProvider);
//     return content.value?.language;
//   }

//   Future<void> updateValue(String value) async {
//     final contentEditor = ref.read(aGContentEditorProvider.notifier);
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() async {
//       final updated = await contentEditor.updateContent(
//         language: value,
//       );
//       return updated?.language;
//     });
//   }
// }

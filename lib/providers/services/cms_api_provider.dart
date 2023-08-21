import 'package:enter_cms_flutter/api/cms_api.dart';
import 'package:enter_cms_flutter/api/rest/cms_rest_api.dart';
import 'package:enter_cms_flutter/providers/services/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cms_api_provider.g.dart';

@Riverpod(dependencies: [])
CmsApi cmsApi(CmsApiRef ref) {
  final dio = ref.watch(dioProvider);
  return CmsRestApi(dio: dio);
}

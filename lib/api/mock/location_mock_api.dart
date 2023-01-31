import 'package:enter_cms_flutter/api/location_api.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';

class LocationMockApi extends LocationApi {
  static const _lagDuration = Duration(milliseconds: 250);

  static const _floorplans = [
    MFloorplan(
      id: 1,
      image: '/mock_data/floorplan/floorplan_ug.png',
      width: 7391,
      height: 6139,
      title: 'UG',
    ),
    MFloorplan(
      id: 2,
      image: '/mock_data/floorplan/floorplan_eg.png',
      width: 7391,
      height: 6139,
      title: 'EG',
    ),
    MFloorplan(
      id: 3,
      image: '/mock_data/floorplan/floorplan_1og.png',
      width: 7391,
      height: 6139,
      title: '1. OG',
    ),
    MFloorplan(
      id: 4,
      image: '/mock_data/floorplan/floorplan_2og.png',
      width: 7391,
      height: 6139,
      title: '2. OG',
    ),
  ];

  @override
  Future<List<MFloorplan>> getFloorplans() {
    return Future.delayed(
      _lagDuration,
      () => _floorplans,
    );
  }

  @override
  Future<MFloorplan> getFloorplan(int id) {
    return Future.delayed(
      _lagDuration,
      () => _floorplans.firstWhere((floorplan) => floorplan.id == id),
    );
  }
}

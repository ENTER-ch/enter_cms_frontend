
import 'package:enter_cms_flutter/models/floorplan.dart';

abstract class LocationApi {
  Future<List<MFloorplan>> getFloorplans();
  Future<MFloorplan> getFloorplan(int id);
}
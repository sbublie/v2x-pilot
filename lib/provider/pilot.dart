import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PilotProvider with ChangeNotifier, DiagnosticableTreeMixin {
  int _currentApproachLane = 0;
  int get currentApproachLane => _currentApproachLane;
  void setCurrentApproachLane(int approachLane) {
    _currentApproachLane = approachLane;
    notifyListeners();
  }

  LatLng _currentPosition = LatLng(49, 9);
  LatLng get currentPosition => _currentPosition;
  void setCurrentPosition(LatLng currentPosition) {
    _currentPosition = currentPosition;
    notifyListeners();
  }
}

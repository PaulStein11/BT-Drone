import 'package:armadatest2/Flight_Status.dart';

class ArmadaBrain {
  List<Status> brainState = [
    Status(initial: "TAKE OFF", active: "LAND"),
    Status(initial: "START MISSION", active: "STOP MISSION"),
    Status(initial: "RETURN HOME", active: "STOP RETURN HOME"),
    Status(initial: "EMERGENCY LAND", active: "STOP EMERGENCY LAND"),
  ];

  String getInitial(int number) {
    return brainState[number].initial;
  }
  String getActive(int number) {
    return brainState[number].active;
  }
}

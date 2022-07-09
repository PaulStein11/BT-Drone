import 'package:armadatest2/Flight_Status.dart';

class ArmadaBrain {
  List<Status> brainState = [
    Status(initial: "ARM", active: "DISARM"),
    Status(initial: "START MISSION", active: "RETURN HOME"),
    Status(initial: "START MISSION", active: "RETURN HOME"),
    //Status(initial: "EMERGENCY LAND", active: "STOP EMERGENCY LAND"),
  ];

  String getInitial(int number) {
    return brainState[number].initial;
  }
  String getActive(int number) {
    return brainState[number].active;
  }
}

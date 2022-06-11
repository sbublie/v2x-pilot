class LSA309Util {
  static final approachTypes = {
    1: <int, dynamic>{
      1: "right_straight",
      2: "left",
    },
    2: <int, dynamic>{
      3: "right_straight",
    },
    3: <int, dynamic>{
      4: "right_straight",
      5: "left",
    },
    4: <int, dynamic>{6: "straight", 7: "left"}
  };

  static String getIconAsset(int approachId, int signalGroupId) {
    switch (approachTypes[approachId]![signalGroupId]) {
      case "left":
        return "assets/icons/turn_left.png";
      case "right":
        return "assets/icons/turn_right.png";
      case "right_straight":
        return "assets/icons/turn_right_straight.png";
      case "left_straight":
        return "assets/icons/turn_left_straight.png";
      case "straight":
        return "assets/icons/turn_straight.png";
      default:
        return "assets/icons/turn_straight.png";
    }
  }
}

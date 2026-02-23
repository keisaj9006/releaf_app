class GrowthState {
  static int growthLevel = 0;

  static String get currentStage {
    switch (growthLevel) {
      case 1:
        return '🌱';
      case 2:
        return '🌿';
      case 3:
        return '🍃';
      case 4:
      default:
        return '🌳';
    }
  }

  static void grow() {
    if (growthLevel < 4) {
      growthLevel++;
    }
  }

  static void reset() {
    growthLevel = 0;
  }
}

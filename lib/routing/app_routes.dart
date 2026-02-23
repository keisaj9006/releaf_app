class AppRoutes {
  // Main tabs
  static const home = '/home';
  static const habits = '/habits';
  static const relief = '/relief';
  static const brain = '/brain';

  // Daily Loop (fullscreen poza tabami)
  static const dailyLoop = '/daily-loop';

  // Brain flow (pod-route’y pod /brain)
  // /brain/game/<gameId>
  static const brainGame = 'game/:gameId';
  // /brain/result
  static const brainResult = 'result';

  // Legacy aliases (żeby stare linki nie wysypywały appki)
  static const dashboardLegacy = '/';
  static const gamesLegacy = '/games';
  static const mathRaceLegacy = '/math-race';
  static const labirynthStatsLegacy = '/labirynth-stats';
}
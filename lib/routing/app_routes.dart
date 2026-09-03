// FILE: lib/routing/app_routes.dart
class AppRoutes {
  static const home = '/home';
  static const habits = '/habits';
  static const relief = '/relief';
  static const brain = '/brain';
  static const dailyLoop = '/daily-loop';

  static const brainGame = '/brain/game/:gameId';
  static const brainResult = '/brain/result';

  static String brainGameFor(String gameId) => '/brain/game/$gameId';

  static const reliefSession = '/relief/session/:sessionId';

  static String reliefSessionFor(String sessionId) =>
      '/relief/session/$sessionId';

  static const dashboardLegacy = '/';
  static const gamesLegacy = '/games';
  static const mathRaceLegacy = '/math-race';
  static const labirynthStatsLegacy = '/labirynth-stats';
}

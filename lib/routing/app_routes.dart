// FILE: lib/routing/app_routes.dart
class AppRoutes {
  static const home = '/home';
  static const habits = '/habits';
  static const relief = '/relief';
  static const sound = '/sound';
  static const meditate = '/meditate';
  static const sleep = '/sleep';
  static const brain = '/brain';
  static const dailyLoop = '/daily-loop';
  static const account = '/account';
  static const privacy = '/privacy';
  static const passwordReset = '/account/reset-password';

  static const brainGame = '/brain/game/:gameId';
  static const brainResult = '/brain/result';

  static String brainGameFor(String gameId) => '/brain/game/$gameId';

  static const reliefSession = '/relief/session/:sessionId';
  static const soundPlayer = '/sound/:trackId';
  static const meditationSession = '/meditate/:meditationId';

  static String reliefSessionFor(String sessionId) =>
      '/relief/session/$sessionId';

  static String soundPlayerFor(String trackId) => '/sound/$trackId';

  static String meditationSessionFor(String meditationId) =>
      '/meditate/$meditationId';

  static const dashboardLegacy = '/';
  static const gamesLegacy = '/games';
  static const mathRaceLegacy = '/math-race';
  static const labirynthStatsLegacy = '/labirynth-stats';
}

import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_riverpod/main.dart';
import 'package:bottom_navigation_riverpod/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> createBeamerProviderContainer() async {
  Beamer.setPathUrlStrategy();
  debugLog("main() | Beamer.setPathUrlStrategy executed");

  final sharedPreferences = await SharedPreferences.getInstance();
  debugLog("main() | sharedPreferences instance obtained");

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  final booksInitialPath =
      container.read(navigationStateControllerProvider).booksLocation;
  final articlesInitialPath =
      container.read(navigationStateControllerProvider).articlesLocation;
  final lastInitialPath =
      container.read(navigationStateControllerProvider).lastLocation;

  // * Init Controller with Listenables
  final authStateController =
      container.read(authStateControllerProvider.notifier);
  authStateController.addListener((state) {
    container.read(authStateListenableProvider).refresh();
  });

  // * Init Router Delegate

  container.read(beamerDelegateProvider);
  return container;
}

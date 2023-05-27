import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_riverpod/locations.dart';
import 'package:bottom_navigation_riverpod/main.dart';
import 'package:bottom_navigation_riverpod/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bottom_navigation_riverpod/controllers.dart';

Provider<List<BeamerDelegate>> beamerDelegatesProvider = Provider((ref) => [
      BeamerDelegate(
        initialPath: ref.read(navigationStateControllerProvider).booksLocation,
        updateListenable: ref.read(bluetoothStateListenableProvider),
        guards: [
          // Bluetooth Guards
          BeamGuard(
            pathPatterns: ['/home/books/*'],
            check: (context, location) {
              final isStreamingLoadData = ref
                  .read(bluetoothStateControllerProvider)
                  .toString()
                  .contains('Streaming');
              return isStreamingLoadData;
            },
            beamToNamed: (origin, target) {
              return '/home/bluetooth';
            },
          ),
          BeamGuard(
            pathPatterns: ['/home/bluetooth'],
            check: (context, location) => !ref
                .read(bluetoothStateControllerProvider)
                .toString()
                .contains('Streaming'),
            beamToNamed: (origin, target) =>
                ref.read(navigationStateControllerProvider).booksLocation,
          ),
        ],
        locationBuilder: (routeInformation, _) {
          debugLog("AppScreenState | routerDelegates[0] (books) | "
              "locationBuilder() | "
              "incoming routeInformation: ${routeInformation.location}");
          BeamLocation result = NotFound(path: routeInformation.location!);
          if (routeInformation.location!.contains('books')) {
            result = BooksLocation(routeInformation);
          }
          if (routeInformation.location!.contains('bluetooth')) {
            result = BluetoothLocation(routeInformation);
          }
          debugLog("AppScreenState | routerDelegates[0] (books) | "
              "locationBuilder() | going to return: $result");
          return result;
        },
      ),
      BeamerDelegate(
        initialPath:
            ref.read(navigationStateControllerProvider).articlesLocation,
        locationBuilder: (routeInformation, _) {
          debugLog("AppScreenState | routerDelegates[1] (articles) | "
              "locationBuilder() | "
              "incoming routeInformation: ${routeInformation.location}");
          BeamLocation result = NotFound(path: routeInformation.location!);
          if (routeInformation.location!.contains('articles')) {
            result = ArticlesLocation(routeInformation);
          }
          debugLog("AppScreenState | routerDelegates[1] (articles) | "
              "locationBuilder() | going to return: $result");
          return result;
        },
      ),
    ]);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Overriden in main()
  throw UnimplementedError();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthRepository(sharedPreferences);
});

final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  return BluetoothRepository();
});

final navigationStateRepositoryProvider =
    Provider<NavigationStateRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return NavigationStateRepository(sharedPreferences);
});

final authStateControllerProvider =
    StateNotifierProvider<AuthStateController, AuthState>((ref) {
  final authStateController =
      AuthStateController(ref, ref.watch(bluetoothStateListenableProvider));

  return authStateController;
});

final bluetoothStateControllerProvider =
    StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  final bleController =
      BluetoothController(ref.read(bluetoothRepositoryProvider));

  bleController.addListener((bluetoothState) {
    ref.read(bluetoothStateListenableProvider).refresh();
  });

  return bleController;
});

final navigationStateControllerProvider =
    NotifierProvider<NavigationStateController, NavigationState>(
        NavigationStateController.new);

Provider<RefreshListenable> bluetoothStateListenableProvider = Provider(
  (ref) => RefreshListenable(),
);

Provider<RefreshListenable> authStateListenableProvider = Provider(
  (ref) => RefreshListenable(),
);

StateProvider<String> currentLocationProvider =
    StateProvider<String>((ref) => 'null');

class RefreshListenable extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

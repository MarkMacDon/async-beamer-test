import 'dart:async';
import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_riverpod/app_bootstrap.dart';
import 'package:bottom_navigation_riverpod/controllers.dart';
import 'package:bottom_navigation_riverpod/providers.dart';
import 'package:bottom_navigation_riverpod/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  debugLog("main() | Main function started");

  WidgetsFlutterBinding.ensureInitialized();
  debugLog("main() | WidgetsFlutterBinding.ensureInitialized executed");

  // Beamer.setPathUrlStrategy();
  // debugLog("main() | Beamer.setPathUrlStrategy executed");

  // final sharedPreferences = await SharedPreferences.getInstance();
  // debugLog("main() | sharedPreferences instance obtained");

  final container = await createBeamerProviderContainer();

  // final container = ProviderContainer(
  //   overrides: [
  //     sharedPreferencesProvider.overrideWithValue(sharedPreferences),
  //   ],
  // );

  // final booksInitialPath =
  //     container.read(navigationStateControllerProvider).booksLocation;
  // final articlesInitialPath =
  //     container.read(navigationStateControllerProvider).articlesLocation;
  // final lastInitialPath =
  //     container.read(navigationStateControllerProvider).lastLocation;

  // // * Init Controller with Listenable
  // final authStateController =
  //     container.read(authStateControllerProvider.notifier);
  // authStateController.addListener((state) {
  //   container.read(authStateListenableProvider).refresh();
  // });

  // final mainRouterDelegate = BeamerDelegate(
  //   initialPath: lastInitialPath,
  //   locationBuilder: RoutesLocationBuilder(
  //     routes: {
  //       '/home/*': (context, state, data) => AppScreen(
  //           booksInitialPath, articlesInitialPath, lastInitialPath, context),
  //       '/login': (context, state, data) => BeamPage(
  //             key: ValueKey('login'),
  //             title: 'Login',
  //             child: LoginScreen(),
  //           ),
  //     },
  //   ),
  //   buildListener: (context, delegate) {
  //     final location = Beamer.of(context).configuration.location;
  //     log("routerDelegate | buildListener() | "
  //         "location: $location");
  //   },
  //   updateListenable: container.read(authStateListenableProvider),
  //   routeListener: (routeInformation, delegate) {
  //     final location = routeInformation.location;

  //     Future(() {
  //       if (location != null) {
  //         container.read(currentLocationProvider.notifier).state = location;
  //         debugLog("routerDelegate | routeListener() | "
  //             "about to save location: $location");

  //         if (location.startsWith('/home/books') ||
  //             location.startsWith('/home/articles')) {
  //           container
  //               .read(navigationStateControllerProvider.notifier)
  //               .setLastLocation(location);
  //           debugLog("routerDelegate | routeListener() | "
  //               "just saved last location: $location");
  //         }

  //         if (location.startsWith('/home/books')) {
  //           container
  //               .read(navigationStateControllerProvider.notifier)
  //               .setBooksLocation(location);
  //           debugLog("routerDelegate | routeListener() | "
  //               "just saved books location: $location");
  //         } else if (location.startsWith('/home/articles')) {
  //           container
  //               .read(navigationStateControllerProvider.notifier)
  //               .setArticlesLocation(location);
  //           debugLog("routerDelegate | routeListener() | "
  //               "just saved articles location: $location");
  //         }
  //       }
  //     });
  //   },
  //   guards: [
  //     BeamGuard(
  //       pathPatterns: ['/login'],
  //       guardNonMatching: true,
  //       check: (context, state) {
  //         final authState = container.read(authStateControllerProvider);

  //         debugLog("routerDelegate | "
  //             "BeamGuard | check() Login nonMatching| is about to retrieve signedIn state: $authState");
  //         final signedIn = authState == AuthState.authenticated();
  //         debugLog("routerDelegate | "
  //             "BeamGuard | check() | obtained signedIn state: $signedIn");
  //         return signedIn;
  //       },
  //       beamToNamed: (origin, target) => '/login',
  //     ),
  //     BeamGuard(
  //       pathPatterns: ['/login'],
  //       check: (context, state) {
  //         final authState = container.read(authStateControllerProvider);
  //         log("routerDelegate | "
  //             "BeamGuard | check() Login Matching | is about to retrieve signedIn state: $authState");
  //         final signedIn = authState == AuthState.authenticated();
  //         log("routerDelegate | "
  //             "BeamGuard | check() | obtained signedIn state: $signedIn");
  //         return !signedIn;
  //       },
  //       beamToNamed: (origin, target) => booksInitialPath,
  //     ),
  //   ],
  // );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: container.read(beamerDelegateProvider),
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(
          delegate: container.read(beamerDelegateProvider),
        ),
      ),
    ),
  );
}

void debugLog(String value) {
  final now = DateTime.now();
  print("[$now] $value");
}

Provider<BeamerDelegate> beamerDelegateProvider = Provider((ref) {
  final booksInitialPath =
      ref.read(navigationStateControllerProvider).booksLocation;
  final articlesInitialPath =
      ref.read(navigationStateControllerProvider).articlesLocation;
  final lastInitialPath =
      ref.read(navigationStateControllerProvider).lastLocation;
  return BeamerDelegate(
    initialPath: ref.read(navigationStateControllerProvider).booksLocation,
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/home/*': (context, state, data) => AppScreen(
            booksInitialPath, articlesInitialPath, lastInitialPath, context),
        '/login': (context, state, data) => BeamPage(
              key: ValueKey('login'),
              title: 'Login',
              child: LoginScreen(),
            ),
      },
    ),
    buildListener: (context, delegate) {
      final location = Beamer.of(context).configuration.location;
      log("routerDelegate | buildListener() | "
          "location: $location");
    },
    updateListenable: ref.read(authStateListenableProvider),
    routeListener: (routeInformation, delegate) {
      final location = routeInformation.location;

      Future(() {
        if (location != null) {
          ref.read(currentLocationProvider.notifier).state = location;
          debugLog("routerDelegate | routeListener() | "
              "about to save location: $location");

          if (location.startsWith('/home/books') ||
              location.startsWith('/home/articles')) {
            ref
                .read(navigationStateControllerProvider.notifier)
                .setLastLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved last location: $location");
          }

          if (location.startsWith('/home/books')) {
            ref
                .read(navigationStateControllerProvider.notifier)
                .setBooksLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved books location: $location");
          } else if (location.startsWith('/home/articles')) {
            ref
                .read(navigationStateControllerProvider.notifier)
                .setArticlesLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved articles location: $location");
          }
        }
      });
    },
    guards: [
      BeamGuard(
        pathPatterns: ['/login'],
        guardNonMatching: true,
        check: (context, state) {
          final authState = ref.read(authStateControllerProvider);

          debugLog("routerDelegate | "
              "BeamGuard | check() Login nonMatching| is about to retrieve signedIn state: $authState");
          final signedIn = authState == AuthState.authenticated();
          debugLog("routerDelegate | "
              "BeamGuard | check() | obtained signedIn state: $signedIn");
          return signedIn;
        },
        beamToNamed: (origin, target) => '/login',
      ),
      BeamGuard(
        pathPatterns: ['/login'],
        check: (context, state) {
          final authState = ref.read(authStateControllerProvider);
          log("routerDelegate | "
              "BeamGuard | check() Login Matching | is about to retrieve signedIn state: $authState");
          final signedIn = authState == AuthState.authenticated();
          log("routerDelegate | "
              "BeamGuard | check() | obtained signedIn state: $signedIn");
          return !signedIn;
        },
        beamToNamed: (origin, target) => booksInitialPath,
      ),
    ],
  );
});

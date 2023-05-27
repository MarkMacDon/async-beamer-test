import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_riverpod/constants.dart';
import 'package:bottom_navigation_riverpod/controllers.dart';
import 'package:bottom_navigation_riverpod/main.dart';
import 'package:bottom_navigation_riverpod/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScreen extends ConsumerStatefulWidget {
  // Context is passed to give access to Provider in AppScreenState Constructor
  AppScreen(this.booksLocation, this.articlesLocation, this.lastLocation,
      this.context);
  final String booksLocation;
  final String articlesLocation;
  final String lastLocation;
  final BuildContext context;

  @override
  AppScreenState createState() =>
      AppScreenState(booksLocation, articlesLocation, lastLocation, context);
}

class AppScreenState extends ConsumerState<AppScreen> {
  AppScreenState(String booksLocation, String articlesLocation,
      String lastLocation, BuildContext context);

  late int bottomNavBarIndex;

  // This method will be called every time the
  // Beamer.of(context) changes.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final location = Beamer.of(context).configuration.location!;
    debugLog("AppScreenState | didChangeDependencies() | "
        "uriString read from Beamer.of(context): $location");
    bottomNavBarIndex = location.contains('books') ? 0 : 1;
    debugLog("AppScreenState | didChangeDependencies() | "
        "computed bottomNavBarIndex: $bottomNavBarIndex");
  }

  @override
  Widget build(BuildContext context) {
    debugLog("AppScreenState | build() | invoked");
    final routerDelegates = ref.read(beamerDelegatesProvider);
    final state = ref.watch(authStateControllerProvider);
    final bleState = ref.watch(bluetoothStateControllerProvider);
    final bleController = ref.read(bluetoothStateControllerProvider.notifier);
    final authController = ref.read(authStateControllerProvider.notifier);
    final currentLocation = ref.watch(currentLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLocation),
        leading: bleState.toString() == 'Loading'
            ? CircularProgressIndicator(
                color: Colors.red,
              )
            : bleState.toString() == 'Connected'
                ? IconButton(
                    icon: Icon(
                      Icons.bluetooth_connected,
                      color: Colors.green,
                    ),
                    onPressed: () async => await bleController.disconnect(),
                  )
                : bleState.toString() == 'Disconnected'
                    ? IconButton(
                        icon: Icon(
                          Icons.bluetooth_disabled,
                          color: Colors.black,
                        ),
                        onPressed: () async => await bleController.connect(),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.bluetooth_connected,
                        ),
                        onPressed: () async => await bleController.disconnect(),
                      ),
        actions: [
          if (state == AuthState.authenticated())
            IconButton(
              onPressed: () async => await authController.signOut(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: IndexedStack(
        index: bottomNavBarIndex,
        children: [
          Beamer(routerDelegate: routerDelegates[0]),
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(32.0),
            child: Beamer(routerDelegate: routerDelegates[1]),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomNavBarIndex,
        items: [
          BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
          BottomNavigationBarItem(label: 'Articles', icon: Icon(Icons.article)),
        ],
        onTap: (index) {
          debugLog("AppScreenState | BottomNavigationBar | onTap() | "
              "new incoming index value: $index "
              "(old value: $bottomNavBarIndex)");
          if (index != bottomNavBarIndex) {
            debugLog("AppScreenState | BottomNavigationBar | onTap() | "
                "index != bottomNavBarIndex");
            setState(() {
              bottomNavBarIndex = index;
            });
            routerDelegates[bottomNavBarIndex].update(rebuild: false);
          }
        },
      ),
    );
  }
}

class BooksScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugLog("BooksScreen | build() | invoked");
    return Scaffold(
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']!),
                subtitle: Text(book['author']!),
                onTap: () {
                  final destination = '/home/books/${book['id']}';
                  debugLog("BooksScreen | going to beam to $destination");
                  ref
                      .read(navigationStateControllerProvider.notifier)
                      .setBooksLocation(destination);

                  log('---->> ${ref.read(navigationStateControllerProvider).booksLocation}');

                  context.beamToNamed(ref
                      .read(navigationStateControllerProvider)
                      .booksLocation);
                  debugLog("BooksScreen | just beamed to: $destination");
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({required this.book});
  final Map<String, String> book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugLog("BookDetailsScreen | build() | invoked");
    final loadState = ref.watch(bluetoothStateControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Author: ${book['author']}'),
            Text('$loadState'),
          ],
        ),
      ),
    );
  }
}

class BluetoothScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bluetoothStateControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.toString(),
            ),
            ElevatedButton(
              onPressed: () async => await ref
                  .read(bluetoothStateControllerProvider.notifier)
                  .connect(),
              child: Text('CONNECT'),
            ),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/home/books'),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugLog("ArticlesScreen | build() | invoked");
    return Scaffold(
      appBar: AppBar(title: Text('Articles')),
      body: ListView(
        children: articles
            .map(
              (article) => ListTile(
                title: Text(article['title']!),
                subtitle: Text(article['author']!),
                onTap: () {
                  final destination = '/home/articles/${article['id']}';
                  debugLog("ArticlesScreen | going to beam to $destination");
                  context.beamToNamed(destination);
                  debugLog("ArticlesScreen | just beamed to: $destination");
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({required this.article});
  final Map<String, String> article;

  @override
  Widget build(BuildContext context) {
    // debugLog("ArticleDetailsScreen.build invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${article['author']}'),
      ),
    );
  }
}

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugLog("LoginScreen | build() | invoked");

    final signedIn =
        ref.read(authStateControllerProvider) == AuthState.authenticated();
    debugLog("LoginScreen | build() | "
        "signedIn provider state before returning a Scaffold: $signedIn");

    final bleState = ref.watch(bluetoothStateControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ref.watch(authStateControllerProvider).toString()),
            Text(bleState.toString()),
            ElevatedButton(
                onPressed: () => ref
                    .read(bluetoothStateControllerProvider.notifier)
                    .connect(),
                child: Text('CONNECT')),
            ElevatedButton(
              onPressed: () async {
                final signedInBefore = ref.read(authStateControllerProvider);
                debugLog("LoginScreen | ElevatedButton | onPressed() | "
                    "signedIn state before controller toggle: $signedInBefore");
                signedIn
                    ? await ref
                        .read(authStateControllerProvider.notifier)
                        .signOut()
                    : await ref
                        .read(authStateControllerProvider.notifier)
                        .signIn();
                final signedInAfter = ref.read(authStateControllerProvider);
                debugLog("LoginScreen | ElevatedButton | onPressed() | "
                    "signedIn state after controller toggle: ${signedInAfter}");

                final lastLocation =
                    ref.read(navigationStateControllerProvider).lastLocation;
                debugLog("LoginScreen | ElevatedButton | onPressed() | "
                    "going to beam to destination: $lastLocation");
                context.beamToNamed(lastLocation);
                debugLog("LoginScreen | ElevatedButton | onPressed() | "
                    "just beamed to destination: $lastLocation");
              },
              child: signedIn ? const Text('Sign out') : const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:beamer/beamer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
  },
];

const List<Map<String, String>> articles = [
  {
    'id': '1',
    'title': 'Explaining Flutter Nav 2.0 and Beamer',
    'author': 'Toby Lewis',
  },
  {
    'id': '2',
    'title': 'Flutter Navigator 2.0 for mobile dev: 101',
    'author': 'Lulupointu',
  },
  {
    'id': '3',
    'title': 'Flutter: An Easy and Pragmatic Approach to Navigator 2.0',
    'author': 'Marco Muccinelli',
  },
];

// SCREENS
class BooksScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugLog("BooksScreen | build() | invoked");
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
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
    final loadState = ref.watch(bluetoothControllerProvider);
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
    final state = ref.watch(bluetoothControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.beamToNamed(
              ref.read(navigationStateControllerProvider).lastLocation),
        ),
        title: Text('Bluetooth Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.toString(),
            ),
            ElevatedButton(
              onPressed: () async => await ref
                  .read(bluetoothControllerProvider.notifier)
                  .connect(),
              child: Text('CONNECT'),
            ),
            ElevatedButton(
              onPressed: () async => await ref
                  .read(bluetoothControllerProvider.notifier)
                  .disconnect(),
              child: Text('DISCONNECT'),
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

    final bleState = ref.watch(bluetoothControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(ref.watch(authStateControllerProvider).toString()),
            Text(bleState.toString()),
            ElevatedButton(
                onPressed: () =>
                    ref.read(bluetoothControllerProvider.notifier).connect(),
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

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/home/books/:bookId',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("BooksLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('books'),
        title: 'Books',
        type: BeamPageType.noTransition,
        child: BooksScreen(),
      ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          title: books.firstWhere(
              (book) => book['id'] == state.pathParameters['bookId'])['title'],
          child: BookDetailsScreen(
            book: books.firstWhere(
                (book) => book['id'] == state.pathParameters['bookId']),
          ),
        ),
    ];

    debugLog("BooksLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}

class BluetoothLocation extends BeamLocation<BeamState> {
  BluetoothLocation(RouteInformation routeInformation)
      : super(routeInformation);
  @override
  List<String> get pathPatterns => [
        '/home/bluetooth',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      BeamPage(
        key: ValueKey('bluetooth'),
        title: 'Bluetooth',
        child: BluetoothScreen(),
      ),
    ];
    return pages;
  }
}

class ArticlesLocation extends BeamLocation<BeamState> {
  ArticlesLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/home/articles/:articleId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("ArticlesLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('articles'),
        title: 'Articles',
        type: BeamPageType.noTransition,
        child: ArticlesScreen(),
      ),
      if (state.pathParameters.containsKey('articleId'))
        BeamPage(
          key: ValueKey('articles-${state.pathParameters['articleId']}'),
          title: articles.firstWhere((article) =>
              article['id'] == state.pathParameters['articleId'])['title'],
          child: ArticleDetailsScreen(
            article: articles.firstWhere((article) =>
                article['id'] == state.pathParameters['articleId']),
          ),
        ),
    ];

    debugLog("ArticlesLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}

// REPOSITORIES
//* Changed to Future
class AuthRepository {
  const AuthRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  Future<bool> getIsSignedIn() async {
    await Future.delayed(Duration(seconds: 2));
    return sharedPreferences.getBool('signedIn') ?? false;
  }

  Future<bool> signInUser() async {
    await Future.delayed(Duration(seconds: 3));
    sharedPreferences.setBool('signedIn', true);
    return true;
  }

  Future<bool> signOutUser() async {
    await Future.delayed(Duration(seconds: 3));
    sharedPreferences.setBool('signedIn', true);
    return false;
  }
}

// ? Maybe good strategy
class NavigationStateRepository {
  const NavigationStateRepository(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  String get booksLocation {
    final result =
        sharedPreferences.getString('booksLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get booksLocation | "
        "location to be returned: $result");
    return result;
  }

  set booksLocation(String location) {
    sharedPreferences.setString('booksLocation', location);
    debugLog("NavigationStateRepository | set booksLocation | "
        "new location was just set: $location");
  }

  String get articlesLocation {
    final result =
        sharedPreferences.getString('articlesLocation') ?? '/home/articles';
    debugLog("NavigationStateRepository | get articlesLocation | "
        "location to be returned: $result");
    return result;
  }

  set articlesLocation(String location) {
    sharedPreferences.setString('articlesLocation', location);
    debugLog("NavigationStateRepository | set articlesLocation | "
        "new location was just set: $location");
  }

  String get lastLocation {
    final result = sharedPreferences.getString('lastLocation') ?? '/home/books';
    debugLog("NavigationStateRepository | get lastLocation | "
        "location to be returned: $result");
    return result;
  }

  set lastLocation(String location) {
    sharedPreferences.setString('lastLocation', location);
    debugLog("NavigationStateRepository | set lastLocation | "
        "new location was just set: $location");
  }
}

class BluetoothRepository {
  Stream<int> getRandomNumberStream() {
    return Stream<int>.periodic(
        Duration(seconds: 1), (index) => Random().nextInt(10));
  }
}

// CONTROLLERS
// * Changed to StateNotifier
class AuthStateController extends StateNotifier<AuthState> {
  final RefreshListenable refreshListenable;
  AuthStateController(Ref ref, this.refreshListenable)
      : repo = ref.read(authRepositoryProvider),
        super(AuthState.loading()) {
    checkUserAuth();
  }

  AuthRepository repo;

  Future<void> checkUserAuth() async {
    state = AuthState.loading();
    final result = await repo.getIsSignedIn();
    result == true
        ? state = AuthState.authenticated()
        : state = AuthState.unauthenticated();
    log('REFRESHING LISTENABLE');
    refreshListenable.refresh();
    log('REFRESHED LISTENABLE | New State $state');
  }

  Future<void> signIn() async {
    log("AuthStateController | toggleSignIn() | "
        "signedIn state before toggle: $state");
    state = AuthState.loading();
    final result = await repo.signInUser();
    result == true
        ? state = AuthState.authenticated()
        : state = AuthState.unauthenticated();
    log("AuthStateController | toggleSignIn() | "
        "signedIn state after toggle: $state");
  }

  Future<void> signOut() async {
    log("AuthStateController | toggleSignIn() | "
        "signedIn state before toggle: $state");
    state = AuthState.loading();
    final result = await repo.signOutUser();
    result == true
        ? state = AuthState.authenticated()
        : state = AuthState.unauthenticated();
    log("AuthStateController | toggleSignIn() | "
        "signedIn state after toggle: $state");
  }
}

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._({this.status = AuthStatus.loading});

  const AuthState.loading() : this._();

  const AuthState.authenticated() : this._(status: AuthStatus.authenticated);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;

  @override
  List<Object?> get props => [status];
}

class NavigationState {
  const NavigationState(
      this.booksLocation, this.articlesLocation, this.lastLocation);
  final String booksLocation;
  final String articlesLocation;
  final String lastLocation;

  String toString() {
    return "NavigationState("
        "booksLocation: $booksLocation, "
        "articlesLocation: $articlesLocation, "
        "lastLocation: $lastLocation)";
  }
}

class BluetoothController extends StateNotifier<BluetoothState> {
  BluetoothController(this.repo) : super(BluetoothState.disconnected());

  final BluetoothRepository repo;
  StreamSubscription? loadStreamSubscription;
  BluetoothState lastState = BluetoothState.disconnected();

  @override
  void dispose() {
    log('Disposing load stream');
    loadStreamSubscription?.cancel();
    super.dispose();
  }

  void updateState(BluetoothState newState) {
    lastState = state;
    state = newState;
  }

  Future<void> connect() async {
    updateState(BluetoothState.loading());
    await Future.delayed(Duration(seconds: 2));
    updateState(BluetoothState.connected());
    await Future.delayed(Duration(seconds: 2));
    loadStreamSubscription = await repo.getRandomNumberStream().listen((load) {
      updateState(BluetoothState.streaming(load));
    });
  }

  Future<void> disconnect() async {
    state = BluetoothState.loading();
    loadStreamSubscription?.cancel();
    await Future.delayed(Duration(seconds: 2));
    state = BluetoothState.disconnected();
  }
}

class BluetoothState {
  final int load;
  final int code;
  const BluetoothState._({this.load = -1, this.code = -1});

  const BluetoothState.loading() : this._(code: 1);
  const BluetoothState.disconnected() : this._(code: 2);
  const BluetoothState.connected() : this._(code: 3);
  const BluetoothState.streaming(int load) : this._(code: 4, load: load);

  @override
  String toString() {
    if (this.code == 1) {
      return 'Loading';
    } else if (this.code == 2) {
      return 'Disconnected';
    } else if (this.code == 3) {
      return 'Connected';
    } else if (this.code == 4) {
      return 'Streaming: $load';
    } else {
      return 'Unknown';
    }
  }
}

// Sync so it can be Notifier. Pro of SharedPreferences
class NavigationStateController extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    final provider = ref.watch(navigationStateRepositoryProvider);
    final result = NavigationState(provider.booksLocation,
        provider.articlesLocation, provider.lastLocation);
    debugLog("NavigationStateController | build() | "
        "about to return ${result.toString()}");
    return result;
  }

  void setBooksLocation(String location) {
    debugLog("NavigationStateController | setBooksLocation() | "
        "state.booksLocation before: ${state.booksLocation}");
    state =
        NavigationState(location, state.articlesLocation, state.lastLocation);
    ref.read(navigationStateRepositoryProvider).booksLocation = location;
    debugLog("NavigationStateController | setBooksLocation() | "
        "state.booksLocation after: ${state.booksLocation}");
  }

  void setArticlesLocation(String location) {
    debugLog("NavigationStateController | setArticlesLocation() | "
        "state.articlesLocation before: ${state.articlesLocation}");
    state = NavigationState(state.booksLocation, location, state.lastLocation);
    ref.read(navigationStateRepositoryProvider).articlesLocation = location;
    debugLog("NavigationStateController | setArticlesLocation() | "
        "state.articlesLocation after: ${state.articlesLocation}");
  }

  void setLastLocation(String location) {
    debugLog("NavigationStateController | setLastLocation() | "
        "state.articlesLocation before: ${state.lastLocation}");
    state =
        NavigationState(state.booksLocation, state.articlesLocation, location);
    ref.read(navigationStateRepositoryProvider).lastLocation = location;
    debugLog("NavigationStateController | setLastLocation() | "
        "state.articlesLocation after: ${state.lastLocation}");
  }
}

// ** PROVIDERS  **
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthRepository(sharedPreferences);
});

final bluetoothRepositoryProvider = Provider<BluetoothRepository>((ref) {
  return BluetoothRepository();
});

// * Updated to StateNotifier
final authStateControllerProvider =
    StateNotifierProvider<AuthStateController, AuthState>((ref) {
  final authStateController =
      AuthStateController(ref, ref.watch(bluetoothStateListenableProvider));

  return authStateController;
});

final bluetoothControllerProvider =
    StateNotifierProvider<BluetoothController, BluetoothState>((ref) {
  final bleController =
      BluetoothController(ref.read(bluetoothRepositoryProvider));

  bleController.addListener((bluetoothState) {
    ref.read(bluetoothStateListenableProvider).refresh();
  });

  return bleController;
});

Provider<RefreshListenable> bluetoothStateListenableProvider = Provider(
  (ref) => RefreshListenable(),
);

Provider<RefreshListenable> authStateListenableProvider = Provider(
  (ref) => RefreshListenable(),
);

class RefreshListenable extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final navigationStateRepositoryProvider =
    Provider<NavigationStateRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return NavigationStateRepository(sharedPreferences);
});

final navigationStateControllerProvider =
    NotifierProvider<NavigationStateController, NavigationState>(
        NavigationStateController.new);

// APP
class AppScreen extends ConsumerStatefulWidget {
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
      String lastLocation, BuildContext context)
      : routerDelegates = [
          BeamerDelegate(
            initialPath: booksLocation,
            updateListenable: ProviderScope.containerOf(context)
                .read(bluetoothStateListenableProvider),
            guards: [
              BeamGuard(
                pathPatterns: ['/home/books/*'],
                check: (context, location) {
                  final isStreamingLoadData = ProviderScope.containerOf(context)
                      .read(bluetoothControllerProvider)
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
                check: (context, location) {
                  final streamingLoadData = ProviderScope.containerOf(context)
                      .read(bluetoothControllerProvider)
                      .toString()
                      .contains('Streaming');

                  log('BeamGuard | is streaming: $streamingLoadData');
                  return !streamingLoadData;
                },
                beamToNamed: (origin, target) {
                  final newLocation = ProviderScope.containerOf(context)
                      .read(navigationStateControllerProvider)
                      .booksLocation;
                  log('----> Bluetooth Guard Beaming to $newLocation');
                  return newLocation;
                },
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
            initialPath: articlesLocation,
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
        ];

  late int bottomNavBarIndex;

  final List<BeamerDelegate> routerDelegates;

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
    final state = ref.watch(authStateControllerProvider);
    final bleState = ref.watch(bluetoothControllerProvider);

    log('HERE WE GOOOO: $bleState');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo App'),
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
                    onPressed: () async => await ref
                        .read(bluetoothControllerProvider.notifier)
                        .disconnect(),
                  )
                : bleState.toString() == 'Disconnected'
                    ? IconButton(
                        icon: Icon(
                          Icons.bluetooth_disabled,
                          color: Colors.black,
                        ),
                        onPressed: () => ref
                            .read(bluetoothControllerProvider.notifier)
                            .connect(),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.bluetooth_connected,
                        ),
                        onPressed: () async => await ref
                            .read(bluetoothControllerProvider.notifier)
                            .disconnect(),
                      ),
        actions: [
          if (state == AuthState.authenticated())
            IconButton(
              onPressed: () async {
                final controller =
                    ref.read(authStateControllerProvider.notifier);
                await controller.signOut();
                if (mounted) {
                  Beamer.of(context).update();
                }
              },
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

void main() async {
  debugLog("main() | Main function started");

  WidgetsFlutterBinding.ensureInitialized();
  debugLog("main() | WidgetsFlutterBinding.ensureInitialized executed");

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
  AuthStateController authStateController =
      container.read(authStateControllerProvider.notifier);
  authStateController.addListener((state) {
    container.read(authStateListenableProvider).refresh();
  });

  final routerDelegate = BeamerDelegate(
    initialPath: lastInitialPath,
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
    updateListenable: container.read(authStateListenableProvider),
    routeListener: (routeInformation, delegate) {
      final location = routeInformation.location;

      Future(() {
        if (location != null) {
          debugLog("routerDelegate | routeListener() | "
              "about to save location: $location");

          if (location.startsWith('/home/books') ||
              location.startsWith('/home/articles')) {
            container
                .read(navigationStateControllerProvider.notifier)
                .setLastLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved last location: $location");
          }

          if (location.startsWith('/home/books')) {
            container
                .read(navigationStateControllerProvider.notifier)
                .setBooksLocation(location);
            debugLog("routerDelegate | routeListener() | "
                "just saved books location: $location");
          } else if (location.startsWith('/home/articles')) {
            container
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
          final authState = ProviderScope.containerOf(context)
              .read(authStateControllerProvider);

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
          final authState = ProviderScope.containerOf(context)
              .read(authStateControllerProvider);
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(
          delegate: routerDelegate,
        ),
      ),
    ),
  );
}

void debugLog(String value) {
  final now = DateTime.now();
  print("[$now] $value");
}

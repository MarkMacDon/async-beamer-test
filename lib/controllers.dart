import 'dart:async';
import 'dart:developer';

import 'package:bottom_navigation_riverpod/providers.dart';
import 'package:bottom_navigation_riverpod/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart';

class AuthStateController extends StateNotifier<AuthState> {
  final RefreshListenable refreshListenable;
  AuthStateController(Ref ref, this.refreshListenable)
      : repo = ref.read(authRepositoryProvider),
        bluetoothController =
            ref.read(bluetoothStateControllerProvider.notifier),
        super(AuthState.loading()) {
    checkUserAuth();
  }

  AuthRepository repo;
  BluetoothController bluetoothController;

  Future<void> checkUserAuth() async {
    state = AuthState.loading();
    final result = await repo.getIsSignedIn();
    result == true
        ? state = AuthState.authenticated()
        : state = AuthState.unauthenticated();
    refreshListenable.refresh();
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
    await bluetoothController.disconnect();
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
    await loadStreamSubscription?.cancel();
    await Future.delayed(Duration(seconds: 2));
    state = BluetoothState.disconnected();
  }
}

class BluetoothState {
  final int load;
  final int code;
  const BluetoothState._({this.load = -1, this.code = -1});

  // TODO  update these for checks (ex. state == BluetoothState.connected)

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
      return 'Connected... Fetching Data Stream';
    } else if (this.code == 4) {
      return 'Streaming: $load';
    } else {
      return 'Unknown';
    }
  }
}

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

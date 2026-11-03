
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/Core/DI/injection.dart';
import 'package:mind_care/Core/Network/connectivity_service.dart';
import 'package:mind_care/Core/Sync/Domain/Services/sync_manager.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_bloc.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_state.dart';

class SyncListener extends StatefulWidget {
  const SyncListener({required this.child, super.key});

  final Widget child;

  @override
  State<SyncListener> createState() => _SyncListenerState();
}

class _SyncListenerState extends State<SyncListener> {
  late final AuthBloc _authBloc;
  late final SyncManager _syncManager;
  late final ConnectivityService _connectivityService;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  bool _syncInProgress = false;
  bool _isConnected = false;

  String? _lastSyncedUserId;
  String? _requestedUserId;

  @override
  void initState() {
    super.initState();

    _authBloc = context.read<AuthBloc>();
    _syncManager = sl<SyncManager>();
    _connectivityService = sl<ConnectivityService>();

    _authSubscription = _authBloc.stream.listen(_handleAuthState);

    _connectivitySubscription = _connectivityService.isConnected.listen(
      _handleConnectivityChanged,
      onError: (Object error, StackTrace stackTrace) {
        _reportError(error, stackTrace);
      },
    );

    _handleAuthState(_authBloc.state);

    unawaited(_initializeConnectivity());
  }

  Future<void> _initializeConnectivity() async {
    try {
      final isConnected = await _connectivityService.checkConnection();
      _handleConnectivityChanged(isConnected);
    } catch (error, stackTrace) {
      _reportError(error, stackTrace);
    }
  }

  void _handleAuthState(AuthState state) {
    if (state is Authenticated) {
      unawaited(_syncForUser(state.session.userId));
    } else if (state is Unauthenticated) {
      _requestedUserId = null;
      _lastSyncedUserId = null;
    }
  }

  void _handleConnectivityChanged(bool isConnected) {
    _isConnected = isConnected;

    if (!isConnected) {
      _requestedUserId = null;
      _lastSyncedUserId = null;
      return;
    }

    final state = _authBloc.state;

    if (state is Authenticated) {
      unawaited(_syncForUser(state.session.userId));
    }
  }

  bool _isCurrentUser(String userId) {
    final state = _authBloc.state;

    return state is Authenticated && state.session.userId == userId;
  }

  Future<void> _syncForUser(String userId) async {
    _requestedUserId = userId;

    if (!_isConnected || _syncInProgress) {
      return;
    }

    _syncInProgress = true;

    try {
      while (_requestedUserId != null) {
        final requestedUserId = _requestedUserId!;
        _requestedUserId = null;

        if (!_isConnected) {
          continue;
        }

        if (_lastSyncedUserId == requestedUserId) {
          continue;
        }

        if (!_isCurrentUser(requestedUserId)) {
          continue;
        }

        _lastSyncedUserId = requestedUserId;

        try {
          await _syncManager.pushChanges();

          // Do not pull if the network or active account changed.
          if (!_isConnected || !_isCurrentUser(requestedUserId)) {
            continue;
          }

          await _syncManager.pullChanges();
        } catch (error, stackTrace) {
          _reportError(error, stackTrace);

          if (_isCurrentUser(requestedUserId)) {
            _lastSyncedUserId = null;
          }
        }
      }
    } finally {
      _syncInProgress = false;
    }
  }

  void _reportError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'MindCare Sync',
        context: ErrorDescription(
          'while synchronizing user data or checking connectivity',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

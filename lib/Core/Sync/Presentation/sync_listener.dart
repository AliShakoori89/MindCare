
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_care/Core/DI/injection.dart';
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

  StreamSubscription<AuthState>? _subscription;

  bool _syncInProgress = false;
  String? _lastSyncedUserId;
  String? _requestedUserId;

  @override
  void initState() {
    super.initState();

    _authBloc = context.read<AuthBloc>();
    _syncManager = sl<SyncManager>();

    _subscription = _authBloc.stream.listen(_handleAuthState);

    // Handle the authentication state that already exists.
    _handleAuthState(_authBloc.state);
  }

  void _handleAuthState(AuthState state) {
    if (state is Authenticated) {
      unawaited(_syncForUser(state.session.userId));
    } else if (state is Unauthenticated) {
      _requestedUserId = null;
      _lastSyncedUserId = null;
    }
  }

  bool _isCurrentUser(String userId) {
    final state = _authBloc.state;

    return state is Authenticated &&
        state.session.userId == userId;
  }

  Future<void> _syncForUser(String userId) async {
    _requestedUserId = userId;

    if (_syncInProgress) {
      return;
    }

    _syncInProgress = true;

    try {
      while (_requestedUserId != null) {
        final requestedUserId = _requestedUserId!;
        _requestedUserId = null;

        if (_lastSyncedUserId == requestedUserId) {
          continue;
        }

        if (!_isCurrentUser(requestedUserId)) {
          continue;
        }

        _lastSyncedUserId = requestedUserId;

        try {
          await _syncManager.pushChanges();

          // Do not start pulling if the active account changed.
          if (!_isCurrentUser(requestedUserId)) {
            continue;
          }

          await _syncManager.pullChanges();
        } catch (error, stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'MindCare Sync',
              context: ErrorDescription(
                'while synchronizing user data',
              ),
            ),
          );

          if (_isCurrentUser(requestedUserId)) {
            _lastSyncedUserId = null;
          }
        }
      }
    } finally {
      _syncInProgress = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_care/Features/Authentication/Presentation/Bloc/auth_bloc.dart';

import '../../Features/Authentication/Presentation/Bloc/auth_state.dart';

class AuthRouterNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthRouterNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

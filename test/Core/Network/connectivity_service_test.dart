
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mind_care/Core/Network/connectivity_service.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late ConnectivityService service;

  setUp(() {
    connectivity = MockConnectivity();
    service = ConnectivityService(connectivity: connectivity);
  });

  test('returns true when Wi-Fi is available', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.wifi],
    );

    expect(await service.checkConnection(), isTrue);
  });

  test('returns true when mobile network is available', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.mobile],
    );

    expect(await service.checkConnection(), isTrue);
  });

  test('returns false when no network is available', () async {
    when(() => connectivity.checkConnectivity()).thenAnswer(
          (_) async => [ConnectivityResult.none],
    );

    expect(await service.checkConnection(), isFalse);
  });

  test('emits connection status changes', () async {
    final controller =
    StreamController<List<ConnectivityResult>>.broadcast();

    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);

    final result = expectLater(
      service.isConnected,
      emitsInOrder([true, false, true]),
    );

    controller.add([ConnectivityResult.wifi]);
    controller.add([ConnectivityResult.none]);
    controller.add([
      ConnectivityResult.mobile,
      ConnectivityResult.wifi,
    ]);

    await result;
    await controller.close();
  });
}

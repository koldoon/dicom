import 'dart:async';
import 'dart:isolate';

import 'package:logecom/logecom.dart';

import 'app_config.dart';
import 'app_context.dart';
import 'app_controller.dart';

/// Simple console application design for simple DICom Dependency injection
/// library usage demonstration

void main() {
  final config = DevelopmentAppConfig();
  final logger = Logecom.createLogger('Global');

  Logecom.instance.pipeline = [
    HttpFormatter(),
    ConsoleTransport(
      config: ConsoleTransportConfig(
        printingMethod: PrintingMethod.stdOut,
      ),
    ),
  ];

  Isolate.current.addErrorListener(RawReceivePort((List<dynamic> pair) async {
    final error = pair.first;
    final StackTrace stack = pair.last;
    logger.error('Unhandled Isolate Error', [error, '\n$stack']);
  }).sendPort);

  void onUnhandledException(Object error, StackTrace stack) {
    logger.error('Unhandled Exception', [error, '\n$stack']);
  }

  /// All the application code must be inside this function
  /// to handle ALL errors properly
  void bootstrap() {
    AppContext.init(config);
    inject<AppController>().runApp();
  }

  runZonedGuarded(bootstrap, onUnhandledException);
}

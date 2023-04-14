import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:dicom/dicom.dart';
import 'package:logecom/logecom.dart';

/// Simple console application design for simple DICom Dependency injection
/// library usage demonstration

/// Application config dependency interface example
abstract class AppConfig {
  String get baseUrl;
}

class DevelopmentAppConfig implements AppConfig {
  @override
  String get baseUrl => 'https://dev-backend-domain.dev';
}

/// Main Application Context
/// Services instances and their dependencies
/// It is very handy to extend [DI] class itself in this case.
class AppContext extends DI {
  AppContext._(this.config) {
    // This allows generate individual loggers with category name based on target Class
    bind(to: (c) => Logecom.createLogger(c.plan[c.plan.length - 2]), dynamic: true);
    bind(to: (c) => AppController(appConfig: get(), logger: get()));
    bind<AppConfig>(to: (c) => config);
  }

  /// [AppConfig] instance is created outside the context because it may contain
  /// extra configuration params that might be used and applied before [AppContext.init].
  /// For example, logging must be configured before the context since
  /// context itself may have logic and errors to report during the initialization.
  static AppContext init(AppConfig appConfig) {
    instance = AppContext._(appConfig);
    return instance;
  }

  /// Singleton [AppContext] instance - all the application context "holder"
  /// Must be created with [AppContext.init] before usage
  static late final AppContext instance;

  final AppConfig config;
}

/// Syntactic sugar to use everywhere at desire.
T inject<T>() {
  return AppContext.instance.get<T>();
}

/// Example of typical dependencies consumer
class AppController {
  AppController({required this.appConfig, required this.logger});

  /// AppConfig dependency
  AppConfig appConfig;
  Logger logger;

  void runApp() {
    logger.info('Starting the application');
    // Your application code here
    exit(0);
  }
}

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

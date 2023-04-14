import 'package:dicom/dicom.dart';
import 'package:logecom/logecom.dart';

import 'app_config.dart';
import 'app_controller.dart';

/// Main Application Context
///
/// Services instances and their dependencies
/// Must be initialized with [AppContext.init] before the usage
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

  /// Singleton [AppContext] instance.
  /// Must be created with [AppContext.init] before usage
  static late final AppContext instance;

  final AppConfig config;
}

/// Syntactic sugar
T inject<T>() {
  return AppContext.instance.get<T>();
}

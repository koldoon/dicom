import 'dart:io';

import 'package:logecom/logecom.dart';

import 'app_config.dart';

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

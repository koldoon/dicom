Extremely simple, fast and clear Dependency Injection (DI) and Inversion of Control (IOC) container.

## Features

- Helping resolving dependencies initialisation order easily  
- Pure Dart library, no Flutter dependency
- Dependency Injection by explicit Type or by Interface
- "Lazy" instantiating
- Singletons and Multiple dependencies (see [getAll] for details)
- Resolution context with current dependency tree for automatic loggers definition and similar tasks
- Nested containers
- Easy debug: clear errors messages about missing dependencies with exact dependency tree description

## Getting started

Simply add as a dependency in `pubspec.yaml`

## Usage

Please follow to `/example` folder for simple console application template example. 

```dart
  final di = DI();
    di
      ..bind(to: (c) => createLogger(c.plan[c.plan.length - 2]), dynamic: true)
      ..bind(to: (c) => AppConfig)
      ..bind(to: (c) => AppController(appConfig: c.get(), logger: c.get()));
```

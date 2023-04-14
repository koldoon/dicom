library dicom;

/// Dependency Injection and Inversion of Control container with conventional API
/// supporting hierarchy and multi inject.
class DI {
  DI({this.parent});

  /// Upstream container where to look up for bindings and instances
  final DI? parent;
  final Map<Type, Binding> bindings = {};

  /// Injection plan. Describes current dependency tree at the point of
  /// dependency resolving.
  final List<Type> plan = [];

  /// Create interface [T] dependency resolver binding
  ///   * [to] Instance factory method
  ///   * [dynamic] Don't cache the instance, call the [to] factory every time new instance is requested
  DI bind<T>({required InstanceFactory<T> to, bool dynamic = false}) {
    if (T.toString() == 'dynamic') throw Exception('Exact type [T] for bind<T>() required');
    if (!bindings.containsKey(T)) bindings[T] = Binding<T>(dynamic);
    final binding = bindings[T] as Binding<T>;
    assert(
      binding.isDynamic == dynamic,
      'Binding for the same instance type $T is already declared with '
      'dynamic = ${binding.isDynamic}. Different [dynamic] options '
      'are not supported yet.',
    );
    binding.factories.add(to);
    return this;
  }

  /// Get cached instance of Type [T] or create new one if not exists depending
  /// on [dynamic] binding property value
  T get<T>() {
    final instances = getAll<T>();
    if (instances.length > 1) {
      throw Exception('[$T] is declared multiple times. [getAll] method must be used instead');
    }
    return instances[0];
  }

  String _getPlan() {
    return plan.map((e) => '[$e]').join(' → ');
  }

  /// Get all multiple cached instances of interface [T] or create new ones
  List<T> getAll<T>() {
    if (T.toString() == 'dynamic') {
      throw Exception('${_getPlan()} depends on dynamic value');
    }

    final bindings = _getBindings<T>();
    if (bindings.isEmpty) {
      throw Exception('${_getPlan()} → [$T]: binding is not declared');
    }

    final instances = <T>[];
    for (final binding in bindings) {
      try {
        instances.addAll(_getInstances(binding));
      } on Error catch (error) {
        if (plan.isEmpty) rethrow;
        final currentPlan = _getPlan();
        plan.clear();
        throw Exception('$currentPlan: instantiation error\n$error\n${error.stackTrace}');
      }
    }

    return instances;
  }

  List<T> _getInstances<T>(Binding<T> binding) {
    if (binding.isDynamic) {
      binding.instances.clear();
      final instances = <T>[];
      for (final factory in binding.factories) {
        plan.add(T);
        instances.add(
          factory(ResolutionContext(this)),
        );
        plan.removeLast();
      }
      return instances;
    }

    if (binding.instances.isEmpty) {
      for (final factory in binding.factories) {
        plan.add(T);
        binding.instances.add(
          factory(ResolutionContext(this)),
        );
        plan.removeLast();
      }
    }

    return binding.instances;
  }

  List<Binding<T>> _getBindings<T>() {
    final bindings = <Binding<T>>[];

    final localBinding = this.bindings[T];
    if (localBinding != null) {
      bindings.add(localBinding as Binding<T>);
    }

    if (parent != null) {
      // collect all bindings from parent containers
      final parentsBindings = parent!._getBindings<T>();
      bindings.addAll(parentsBindings);
    }

    return bindings;
  }
}

/// Syntactic sugar for container methods accessing
class ResolutionContext {
  ResolutionContext(this.container);

  /// DI Container on behalf of which the request is being executed
  /// Can be different in case of nested containers
  final DI container;

  T get<T>() => container.get<T>();
  List<Type> get plan => container.plan;
}

typedef InstanceFactory<T> = T Function(ResolutionContext c);

/// Binding declaration descriptor
class Binding<T> {
  Binding([this.isDynamic = false]);
  final bool isDynamic;
  final List<InstanceFactory<T>> factories = [];
  final List<T> instances = [];
}

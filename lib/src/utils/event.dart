abstract class EventBase<F extends Function> {
  final Set<F> _storage = {};

  /// This is a list of the subscribed functions in this event.
  Set<F> get storage => _storage;

  /// Adds [value] to the storage.<br/>
  /// Returns true if [value] (or an equal value) was not yet in the storage.
  /// Otherwise returns false and the storage is not changed.
  bool add(F value) {
    return _storage.add(value);
  }

  /// Removes [value] from the storage.<br/>
  /// Returns true if [value] was in the storage, and false if not.
  /// The method has no effect if [value] was not in the storage.
  bool remove(F value) {
    return _storage.remove(value);
  }

  /// Removes all the subscribed functions in the event.
  void clear() {
    _storage.clear();
  }

  /// When called, it will invoke (call) all subscribed callbacks in the event
  void invoke();

  /// Used to quickly add a function to event
  /// calls [add] function
  bool operator +(F value) {
    return add(value);
  }

  /// Used to quickly remove a function from event
  /// calls [remove] function
  bool operator -(F value) {
    return remove(value);
  }
}

typedef Fun<T> = Function(T);
typedef Fun2<S, T> = Function(S, T);
typedef Fun3<S, T, U> = Function(S, T, U);
typedef Fun4<S, T, U, V> = Function(S, T, U, V);
typedef Fun5<S, T, U, V, W> = Function(S, T, U, V, W);
typedef Fun6<S, T, U, V, W, X> = Function(S, T, U, V, W, X);
typedef Fun7<S, T, U, V, W, X, Y> = Function(S, T, U, V, W, X, Y);
typedef Fun8<S, T, U, V, W, X, Y, Z> = Function(S, T, U, V, W, X, Y, Z);

class Event<T, _ extends Fun<T>> extends EventBase<_> {
  @override
  void invoke([T? v]) {
    for (var f in _storage) {
      Function.apply(f, [v]);
    }
  }
}

class Event2<S, T, _ extends Fun2<S, T>> extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2]);
    }
  }
}

class Event3<S, T, U, _ extends Fun3<S, T, U>> extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3]);
    }
  }
}

class Event4<S, T, U, V, _ extends Fun4<S, T, U, V>> extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3, V? v4]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3, v4]);
    }
  }
}

class Event5<S, T, U, V, W, _ extends Fun5<S, T, U, V, W>>
    extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3, V? v4, W? v5]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3, v4, v5]);
    }
  }
}

class Event6<S, T, U, V, W, X, _ extends Fun6<S, T, U, V, W, X>>
    extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3, V? v4, W? v5, X? v6]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3, v4, v5, v6]);
    }
  }
}

class Event7<S, T, U, V, W, X, Y, _ extends Fun7<S, T, U, V, W, X, Y>>
    extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3, V? v4, W? v5, X? v6, Y? v7]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3, v4, v5, v6, v7]);
    }
  }
}

class Event8<S, T, U, V, W, X, Y, Z, _ extends Fun8<S, T, U, V, W, X, Y, Z>>
    extends EventBase<_> {
  @override
  void invoke([S? v1, T? v2, U? v3, V? v4, W? v5, X? v6, Y? v7, Z? v8]) {
    for (var f in _storage) {
      Function.apply(f, [v1, v2, v3, v4, v5, v6, v7, v8]);
    }
  }
}

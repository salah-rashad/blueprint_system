typedef Fun<S> = void Function(S? v);

class Event<T> {
  final Set<Fun<T>> _storage = {};

  Set<Fun<T>> get storage => _storage;

  /// Adds [value] to the storage.
  /// Returns true if [value] (or an equal value) was not yet in the set. Otherwise returns false and the set is not changed.
  bool add(Fun<T> value) {
    return _storage.add(value);
  }

  /// Removes [value] from the storage.
  /// Returns true if [value] was in the set, and false if not. The method has no effect if [value] was not in the set.
  bool remove(Fun<T> value) {
    return _storage.remove(value);
  }

  /// Removes all elements from the storage.
  void clear() {
    _storage.clear();
  }

  void invoke([T? arg]) {
    for (var f in _storage) {
      f.call(arg);
    }
  }

  bool operator +(Fun<T> value) {
    return add(value);
  }

  bool operator -(Fun<T> value) {
    return remove(value);
  }
}

extension MapExtension<K, V> on Map<K, V> {
  /// Iterates over the map in reverse order while [executeWhile] returns true.
  void forEachInvertedWhile(
    void Function(K key, V value) f, {
    required bool Function(K key, V? value) executeWhile,
  }) {
    final keys = this.keys.toList();
    for (int i = keys.length - 1; i >= 0; i--) {
      if (!executeWhile(keys[i], this[keys[i]]!)) {
        break;
      }
      final key = keys[i];
      final value = this[key];
      f(key, value!);
    }
  }

  List<V> getByKeys(Iterable<K> keys) {
    final result = <V>[];
    for (final key in keys) {
      final value = this[key];
      if (value != null) {
        result.add(value);
      }
    }
    return result;
  }
}

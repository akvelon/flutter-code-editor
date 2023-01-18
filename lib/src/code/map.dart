extension MapExtension<K, V> on Map<K, V> {
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

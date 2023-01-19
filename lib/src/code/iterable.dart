extension IterableExtension<T> on Iterable<T> {
  Iterable<T> get reversed => toList(growable: false).reversed;
}

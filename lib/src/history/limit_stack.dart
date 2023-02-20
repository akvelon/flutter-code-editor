class LimitStack<T> extends Iterable<T> {
  final int maxLength;
  final _items = <T>[];

  LimitStack({
    required this.maxLength,
  });

  @override
  int get length => _items.length;

  void push(T value) {
    _items.add(value);

    if (_items.length > maxLength) {
      _items.removeRange(0, _items.length - maxLength);
    }
  }

  void removeStartingAt(int n) {
    _items.removeRange(n, _items.length);
  }

  void removeAt(int index) {
    _items.removeAt(index);
  }

  void clear() {
    _items.clear();
  }

  T operator [](int n) {
    return _items[n];
  }

  @override
  Iterator<T> get iterator => _items.iterator;
}

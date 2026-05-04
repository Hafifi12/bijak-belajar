import 'dart:math';

class RandomHelper {
  RandomHelper([Random? random]) : _random = random ?? Random();

  final Random _random;

  T item<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must not be empty');
    }

    return items[_random.nextInt(items.length)];
  }

  List<T> shuffled<T>(List<T> items) {
    final copy = [...items];
    copy.shuffle(_random);
    return copy;
  }
}

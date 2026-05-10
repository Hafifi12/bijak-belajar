import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../models/memory_item.dart';

const animalMemoryItems = <MemoryItem>[
  MemoryItem(id: 'animal_cat', label: 'Cat', symbol: '🐱'),
  MemoryItem(id: 'animal_dog', label: 'Dog', symbol: '🐶'),
  MemoryItem(id: 'animal_cow', label: 'Cow', symbol: '🐮'),
  MemoryItem(id: 'animal_bird', label: 'Bird', symbol: '🐦'),
  MemoryItem(id: 'animal_fish', label: 'Fish', symbol: '🐟'),
  MemoryItem(id: 'animal_bug', label: 'Bug', symbol: '🐞'),
];

const shapeMemoryItems = <MemoryItem>[
  MemoryItem(id: 'shape_circle', label: 'Circle', shapeKind: ShapeKind.circle),
  MemoryItem(id: 'shape_square', label: 'Square', shapeKind: ShapeKind.square),
  MemoryItem(
    id: 'shape_triangle',
    label: 'Triangle',
    shapeKind: ShapeKind.triangle,
  ),
  MemoryItem(id: 'shape_star', label: 'Star', shapeKind: ShapeKind.star),
  MemoryItem(id: 'shape_heart', label: 'Heart', shapeKind: ShapeKind.heart),
  MemoryItem(
    id: 'shape_diamond',
    label: 'Diamond',
    shapeKind: ShapeKind.diamond,
  ),
];

const colorMemoryItems = <MemoryItem>[
  MemoryItem(id: 'color_red', label: 'Red', displayColor: Color(0xFFE53935)),
  MemoryItem(id: 'color_blue', label: 'Blue', displayColor: Color(0xFF1E88E5)),
  MemoryItem(
    id: 'color_yellow',
    label: 'Yellow',
    displayColor: Color(0xFFFDD835),
  ),
  MemoryItem(
    id: 'color_green',
    label: 'Green',
    displayColor: Color(0xFF43A047),
  ),
  MemoryItem(
    id: 'color_orange',
    label: 'Orange',
    displayColor: Color(0xFFFF8F00),
  ),
  MemoryItem(
    id: 'color_purple',
    label: 'Purple',
    displayColor: Color(0xFF8E44AD),
  ),
];

List<MemoryItem> memoryItemsFor(MemoryCategory category, {int pairCount = 6}) {
  final baseItems = switch (category) {
    MemoryCategory.animals => animalMemoryItems,
    MemoryCategory.shapes => shapeMemoryItems,
    MemoryCategory.colors => colorMemoryItems,
  };

  if (pairCount <= baseItems.length) {
    return baseItems.take(pairCount).toList();
  }

  final generated = <MemoryItem>[...baseItems];
  for (var index = generated.length; index < pairCount; index++) {
    generated.add(_generatedMemoryItem(category, index));
  }
  return generated;
}

MemoryItem _generatedMemoryItem(MemoryCategory category, int index) {
  switch (category) {
    case MemoryCategory.animals:
      const animals = [
        ('lion', 'Lion', '🦁'),
        ('tiger', 'Tiger', '🐯'),
        ('bear', 'Bear', '🐻'),
        ('panda', 'Panda', '🐼'),
        ('fox', 'Fox', '🦊'),
        ('frog', 'Frog', '🐸'),
        ('monkey', 'Monkey', '🐵'),
        ('chicken', 'Chicken', '🐔'),
        ('penguin', 'Penguin', '🐧'),
        ('koala', 'Koala', '🐨'),
        ('pig', 'Pig', '🐷'),
        ('mouse', 'Mouse', '🐭'),
        ('rabbit', 'Rabbit', '🐰'),
        ('horse', 'Horse', '🐴'),
        ('unicorn', 'Unicorn', '🦄'),
        ('bee', 'Bee', '🐝'),
        ('snail', 'Snail', '🐌'),
        ('butterfly', 'Butterfly', '🦋'),
        ('turtle', 'Turtle', '🐢'),
        ('snake', 'Snake', '🐍'),
        ('octopus', 'Octopus', '🐙'),
        ('dolphin', 'Dolphin', '🐬'),
        ('whale', 'Whale', '🐳'),
        ('crocodile', 'Crocodile', '🐊'),
        ('leopard', 'Leopard', '🐆'),
        ('zebra', 'Zebra', '🦓'),
        ('gorilla', 'Gorilla', '🦍'),
        ('orangutan', 'Orangutan', '🦧'),
        ('elephant', 'Elephant', '🐘'),
        ('hippo', 'Hippo', '🦛'),
        ('rhino', 'Rhino', '🦏'),
        ('camel', 'Camel', '🐪'),
        ('giraffe', 'Giraffe', '🦒'),
        ('kangaroo', 'Kangaroo', '🦘'),
        ('peacock', 'Peacock', '🦚'),
        ('parrot', 'Parrot', '🦜'),
        ('swan', 'Swan', '🦢'),
        ('flamingo', 'Flamingo', '🦩'),
        ('seal', 'Seal', '🦭'),
        ('shark', 'Shark', '🦈'),
        ('owl', 'Owl', '🦉'),
        ('duck', 'Duck', '🦆'),
        ('eagle', 'Eagle', '🦅'),
        ('crab', 'Crab', '🦀'),
      ];
      final item = animals[(index - animalMemoryItems.length) % animals.length];
      return MemoryItem(
        id: 'animal_${item.$1}_$index',
        label: item.$2,
        symbol: item.$3,
      );
    case MemoryCategory.shapes:
      const shapeSymbols = [
        ('oval', 'Oval', '⬭'),
        ('rectangle', 'Rectangle', '▭'),
        ('moon', 'Crescent', '☾'),
        ('cross', 'Cross', '✚'),
        ('flower', 'Flower', '✿'),
        ('sun', 'Sun', '☀'),
        ('cloud', 'Cloud', '☁'),
        ('sparkle', 'Sparkle', '✦'),
        ('hexagon', 'Hexagon', '⬡'),
        ('pentagon', 'Pentagon', '⬟'),
      ];
      final item =
          shapeSymbols[(index - shapeMemoryItems.length) % shapeSymbols.length];
      final round =
          ((index - shapeMemoryItems.length) ~/ shapeSymbols.length) + 1;
      return MemoryItem(
        id: 'shape_${item.$1}_$index',
        label: round == 1 ? item.$2 : '${item.$2} $round',
        symbol: item.$3,
      );
    case MemoryCategory.colors:
      final hue = (index * 37) % 360;
      final color = HSLColor.fromAHSL(1, hue.toDouble(), 0.72, 0.56).toColor();
      return MemoryItem(
        id: 'color_generated_$index',
        label: 'Color ${index + 1}',
        displayColor: color,
      );
  }
}

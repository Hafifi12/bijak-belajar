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

List<MemoryItem> memoryItemsFor(MemoryCategory category) {
  switch (category) {
    case MemoryCategory.animals:
      return animalMemoryItems;
    case MemoryCategory.shapes:
      return shapeMemoryItems;
    case MemoryCategory.colors:
      return colorMemoryItems;
  }
}

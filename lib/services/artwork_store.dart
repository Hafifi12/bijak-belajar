import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Local store for the child's saved coloring artwork.
///
/// Files are PNGs named `art_<millis>.png` inside `<app documents>/artwork`,
/// so sorting by name descending equals newest-first. No accounts, no cloud —
/// the gallery is purely on-device (COPPA/PDPA-friendly).
class ArtworkStore {
  const ArtworkStore._();

  static Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}artwork');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Persists [pngBytes] as a new artwork file and returns it.
  static Future<File> save(List<int> pngBytes) async {
    final dir = await _dir();
    final file = File(
      '${dir.path}${Platform.pathSeparator}art_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return file.writeAsBytes(pngBytes, flush: true);
  }

  /// All saved artwork, newest first.
  static Future<List<File>> list() async {
    final dir = await _dir();
    final files = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.png')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  static Future<void> delete(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../services/artwork_store.dart';
import '../theme/app_theme.dart';
import '../widgets/bijak_scene.dart';
import '../widgets/pressable.dart';

/// Gallery of the child's saved coloring artwork.
///
/// The pride loop: drawings used to vanish after saving. Now the child can
/// reopen them, and the fullscreen view exists so they can show a grown-up —
/// which is also the app's cheapest organic-growth moment.
class ColoringGalleryScreen extends ConsumerStatefulWidget {
  const ColoringGalleryScreen({super.key});

  @override
  ConsumerState<ColoringGalleryScreen> createState() =>
      _ColoringGalleryScreenState();
}

class _ColoringGalleryScreenState extends ConsumerState<ColoringGalleryScreen> {
  late Future<List<File>> _artworks;

  @override
  void initState() {
    super.initState();
    _artworks = ArtworkStore.list();
  }

  void _reload() {
    setState(() => _artworks = ArtworkStore.list());
  }

  Future<void> _openFullscreen(File file, bool isMalay) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ArtworkFullscreen(file: file, isMalay: isMalay),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final isMalay =
        ref.watch(progressServiceProvider).language == AppLanguage.malay;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleColoring),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        title: Text(
          isMalay ? 'Galeri Seni Saya 🖼️' : 'My Art Gallery 🖼️',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<List<File>>(
        future: _artworks,
        builder: (context, snapshot) {
          // An error (e.g. storage plugin not linked after a hot restart)
          // must never strand the child on an endless spinner.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('😅', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      isMalay
                          ? 'Galeri tidak dapat dibuka.\nTutup apl sepenuhnya dan buka semula.'
                          : 'Could not open the gallery.\nFully close and reopen the app.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onNightMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: Text(isMalay ? 'Cuba Lagi' : 'Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data ?? const <File>[];
          if (files.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      isMalay
                          ? 'Belum ada lukisan lagi.\nJom mewarna dan simpan hasil seni kamu!'
                          : 'No artwork yet.\nGo colour something and save it!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onNightMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
            ),
            itemCount: files.length,
            itemBuilder: (context, i) {
              final file = files[i];
              return Pressable(
                onTap: () => _openFullscreen(file, isMalay),
                semanticLabel: isMalay
                    ? 'Lukisan ${files.length - i}'
                    : 'Artwork ${files.length - i}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.ink.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArtworkFullscreen extends StatelessWidget {
  const _ArtworkFullscreen({required this.file, required this.isMalay});
  final File file;
  final bool isMalay;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(isMalay ? 'Padam lukisan ini?' : 'Delete this artwork?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isMalay ? 'Batal' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isMalay ? 'Padam' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ArtworkStore.delete(file);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: NightBar(Colors.transparent),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: isMalay
                      ? 'Lihat lukisan saya dari Bijak Belajar! 🎨'
                      : 'Look at my drawing from Bijak Belajar! 🎨',
                );
              } catch (e) {
                // Plugin not linked yet (needs full rebuild) — never crash.
                debugPrint('[Gallery] share failed: $e');
              }
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: isMalay ? 'Kongsi' : 'Share',
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: isMalay ? 'Padam' : 'Delete',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: InteractiveViewer(
                    child: Image.file(file, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                isMalay
                    ? '🎉 Tunjukkan pada keluarga kamu!'
                    : '🎉 Show your family!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.sunnyYellow,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

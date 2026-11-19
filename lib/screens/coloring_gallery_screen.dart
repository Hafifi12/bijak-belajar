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
import 'parent_gate_screen.dart';

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

  Future<void> _openFullscreen(File file, AppLanguage language) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ArtworkFullscreen(file: file, language: language),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(progressServiceProvider).language;

    return Scaffold(
      backgroundColor: AppTheme.nightMid,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleColoring),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        title: Text(
          language.copy(ms: 'Galeri Seni Saya 🖼️', en: 'My Art Gallery 🖼️', zh: '我的画廊 🖼️', ta: 'என் ஓவியக் காட்சியகம் 🖼️'),
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
                      language.copy(ms: 'Galeri tidak dapat dibuka.\nTutup apl sepenuhnya dan buka semula.', en: 'Could not open the gallery.\nFully close and reopen the app.', zh: '无法打开画廊。\n请完全关闭应用后重新打开。', ta: 'கேலரியைத் திறக்க முடியவில்லை.\nசெயலியை முழுமையாக மூடிவிட்டு மீண்டும் திறக்கவும்.'),
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
                      child: Text(language.copy(ms: 'Cuba Lagi', en: 'Try Again', zh: '再试一次', ta: 'மீண்டும் முயற்சி')),
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
                      language.copy(ms: 'Belum ada lukisan lagi.\nJom mewarna dan simpan hasil seni kamu!', en: 'No artwork yet.\nGo colour something and save it!', zh: '还没有作品。\n去涂色并保存吧！', ta: 'இன்னும் ஓவியம் இல்லை.\nசென்று வண்ணம் தீட்டி சேமியுங்கள்!'),
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
                onTap: () => _openFullscreen(file, language),
                semanticLabel: language.copy(ms: 'Lukisan ${files.length - i}', en: 'Artwork ${files.length - i}', zh: '作品 ${files.length - i}', ta: 'ஓவியம் ${files.length - i}'),
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
  const _ArtworkFullscreen({required this.file, required this.language});
  final File file;
  final AppLanguage language;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(language.copy(ms: 'Padam lukisan ini?', en: 'Delete this artwork?', zh: '删除这幅作品？', ta: 'இந்த ஓவியத்தை நீக்கவா?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(language.copy(ms: 'Batal', en: 'Cancel', zh: '取消', ta: 'ரத்து செய்')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(language.copy(ms: 'Padam', en: 'Delete', zh: '删除', ta: 'நீக்கு')),
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
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // Sharing leaves the app, so a grown-up confirms it first
              // (Google Play Families policy).
              final allowed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const ParentGateScreen(forSharing: true),
                ),
              );
              if (allowed != true) return;
              try {
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: language.copy(ms: 'Lihat lukisan saya dari Bijak Belajar! 🎨', en: 'Look at my drawing from Bijak Belajar! 🎨', zh: '快来看看我在 Bijak Belajar 画的画！🎨', ta: 'Bijak Belajar-இல் நான் வரைந்த ஓவியத்தைப் பாருங்கள்! 🎨'),
                );
              } catch (e) {
                // Plugin not linked yet (needs full rebuild) — never crash.
                debugPrint('[Gallery] share failed: $e');
              }
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: language.copy(ms: 'Kongsi', en: 'Share', zh: '分享', ta: 'பகிர்'),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: language.copy(ms: 'Padam', en: 'Delete', zh: '删除', ta: 'நீக்கு'),
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
                language.copy(ms: '🎉 Tunjukkan pada keluarga kamu!', en: '🎉 Show your family!', zh: '🎉 展示给家人看！', ta: '🎉 குடும்பத்தினருக்குக் காட்டுங்கள்!'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_language.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/bijak_scene.dart';

/// In-app privacy policy. Google Play's User Data policy (and the Families
/// policy) require the privacy policy to be reachable from within the app —
/// not only in the Play Console — for apps that access sensitive permissions
/// such as the microphone. The full text is shown here so it works offline.
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  static const routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final isMalay = progress.language == AppLanguage.malay;
    final sections = isMalay ? _sectionsMs : _sectionsEn;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleGames),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: isMalay ? 'Kembali' : 'Back',
        ),
        title: Text(isMalay ? 'Dasar Privasi' : 'Privacy Policy'),
      ),
      body: BijakScene(
        topColor: AppTheme.nightTop,
        bottomColor: AppTheme.nightBottom,
        showHills: false,
        child: SafeArea(
          child: ListView(
            padding: AppConstants.pagePadding,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bijak Belajar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMalay
                            ? 'Berkuat kuasa 10 Ogos 2026 · ANF Studio'
                            : 'Effective 10 August 2026 · ANF Studio',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9090A8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final (heading, body) in sections) ...[
                        Text(
                          heading,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

const List<(String, String)> _sectionsEn = [
  (
    'What we collect',
    'Nothing. Bijak Belajar does not collect, store, upload, or share any '
        'personal data — no names, emails, location, contacts, photos, or '
        'advertising identifiers. There is no account and no login.',
  ),
  (
    'Microphone & voice',
    'Some activities let your child say a letter, number, or word aloud so the '
        'app can give friendly pronunciation feedback. This uses the microphone '
        'and your device\'s built-in speech recognition. Your child\'s voice is '
        'never recorded, saved, or sent anywhere — it is turned into text on '
        'your device only. You can decline the microphone permission and still '
        'use the rest of the app.',
  ),
  (
    'Where data is stored',
    'Learning settings and progress (language, sound, stars, level) are saved '
        'only on this device using local storage, and are removed when the app '
        'is uninstalled.',
  ),
  (
    'No ads, no tracking',
    'The app shows no advertisements, uses no analytics or tracking, and '
        'includes no third-party data-collection tools.',
  ),
  (
    'Internet',
    'The app makes no network requests and does not include the Android '
        'Internet permission — all content is bundled and works offline.',
  ),
  (
    'Sharing a picture',
    'In the colouring activity, a child (with a parent\'s help) can choose to '
        'share a picture they coloured through the device\'s own share menu. '
        'The app does not upload or keep a copy.',
  ),
  (
    'Children\'s privacy',
    'Bijak Belajar is designed for children and intended for use with a parent '
        'or guardian. Because we collect no personal data, none is collected '
        'from children. The app is designed to comply with COPPA, Malaysia\'s '
        'PDPA 2010, and the Google Play Families Policy.',
  ),
  (
    'Permissions we request',
    'Microphone (RECORD_AUDIO) — only for the optional pronunciation-practice '
        'activities above. We do not request camera, contacts, location, or '
        'file access.',
  ),
  (
    'Contact',
    'Questions about this policy? Email anfstudio.dev@gmail.com',
  ),
];

const List<(String, String)> _sectionsMs = [
  (
    'Apa yang kami kumpul',
    'Tiada. Bijak Belajar tidak mengumpul, menyimpan, memuat naik, atau '
        'berkongsi sebarang data peribadi — tiada nama, e-mel, lokasi, kenalan, '
        'gambar, atau pengecam pengiklanan. Tiada akaun dan tiada log masuk.',
  ),
  (
    'Mikrofon & suara',
    'Sesetengah aktiviti membenarkan anak anda menyebut huruf, nombor, atau '
        'perkataan supaya aplikasi boleh memberi maklum balas sebutan. Ini '
        'menggunakan mikrofon dan pengecaman pertuturan terbina dalam peranti '
        'anda. Suara anak anda tidak pernah dirakam, disimpan, atau dihantar ke '
        'mana-mana — ia ditukar menjadi teks pada peranti anda sahaja. Anda '
        'boleh menolak kebenaran mikrofon dan masih menggunakan aplikasi ini.',
  ),
  (
    'Di mana data disimpan',
    'Tetapan dan kemajuan pembelajaran (bahasa, bunyi, bintang, tahap) '
        'disimpan hanya pada peranti ini menggunakan storan setempat, dan '
        'dipadam apabila aplikasi dinyahpasang.',
  ),
  (
    'Tiada iklan, tiada penjejakan',
    'Aplikasi tidak memaparkan iklan, tidak menggunakan analitik atau '
        'penjejakan, dan tidak menyertakan alat pengumpulan data pihak ketiga.',
  ),
  (
    'Internet',
    'Aplikasi tidak membuat permintaan rangkaian dan tidak menyertakan '
        'kebenaran Internet Android — semua kandungan disertakan dan berfungsi '
        'di luar talian.',
  ),
  (
    'Berkongsi gambar',
    'Dalam aktiviti mewarna, kanak-kanak (dengan bantuan ibu bapa) boleh '
        'memilih untuk berkongsi gambar yang diwarnakan melalui menu kongsi '
        'peranti. Aplikasi tidak memuat naik atau menyimpan salinan.',
  ),
  (
    'Privasi kanak-kanak',
    'Bijak Belajar direka untuk kanak-kanak dan bertujuan digunakan bersama '
        'ibu bapa atau penjaga. Kerana kami tidak mengumpul data peribadi, '
        'tiada data dikumpul daripada kanak-kanak. Aplikasi direka untuk '
        'mematuhi COPPA, PDPA Malaysia 2010, dan Dasar Google Play Families.',
  ),
  (
    'Kebenaran yang kami minta',
    'Mikrofon (RECORD_AUDIO) — hanya untuk aktiviti latihan sebutan pilihan di '
        'atas. Kami tidak meminta kamera, kenalan, lokasi, atau akses fail.',
  ),
  (
    'Hubungi kami',
    'Ada soalan tentang dasar ini? E-mel anfstudio.dev@gmail.com',
  ),
];

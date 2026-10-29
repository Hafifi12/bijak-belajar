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
                            ? 'Berkuat kuasa 29 Oktober 2026 · ANF Studio'
                            : 'Effective 29 October 2026 · ANF Studio',
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
    'When your child taps the speak button, the app uses the microphone so it '
        'can give friendly pronunciation feedback. A grown-up sees a short '
        'explanation before the first request. Your device\'s built-in speech '
        'service (such as Google or Apple) turns the speech into text — on the '
        'device or online, depending on your device and its settings, under '
        'that provider\'s privacy terms. Bijak Belajar itself never records, '
        'keeps, or receives the audio. You can decline the microphone '
        'permission and still use the rest of the app.',
  ),
  (
    'Where data is stored & how to delete it',
    'Learning settings and progress (language, sound, stars, level) and any '
        'colouring pictures your child saves stay only in the app\'s private '
        'storage on this device. Delete progress with Parent Settings → Reset '
        'Progress, delete a picture from the colouring gallery, or uninstall '
        'the app to remove everything. We never receive this data, so we hold '
        'no copy.',
  ),
  (
    'Keeping data safe',
    'The app never sends this data anywhere, so it stays protected by your '
        'device\'s app sandboxing and screen lock. On Android the app opts out '
        'of cloud backup.',
  ),
  (
    'No ads, no tracking',
    'The app shows no advertisements, uses no analytics or tracking, and '
        'includes no third-party data-collection tools.',
  ),
  (
    'Internet',
    'The app makes no network requests and does not include the Android '
        'Internet permission — all content is bundled and works offline. Your '
        'device\'s speech and text-to-speech services are separate and may use '
        'the internet according to your device\'s settings.',
  ),
  (
    'Sharing a picture',
    'A child can ask to share a picture they coloured. A grown-up answers a '
        'simple maths question first, then the device\'s own share menu opens. '
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
    'Apabila anak anda menekan butang sebut, aplikasi menggunakan mikrofon '
        'untuk memberi maklum balas sebutan. Orang dewasa melihat penerangan '
        'ringkas sebelum permintaan pertama. Perkhidmatan pertuturan terbina '
        'dalam peranti anda (seperti Google atau Apple) menukar sebutan kepada '
        'teks — pada peranti atau dalam talian, bergantung pada peranti dan '
        'tetapannya, tertakluk kepada terma privasi penyedia tersebut. Bijak '
        'Belajar sendiri tidak pernah merakam, menyimpan, atau menerima audio. '
        'Anda boleh menolak kebenaran mikrofon dan masih menggunakan aplikasi ini.',
  ),
  (
    'Di mana data disimpan & cara memadamnya',
    'Tetapan dan kemajuan pembelajaran (bahasa, bunyi, bintang, tahap) serta '
        'gambar mewarna yang disimpan oleh anak anda kekal hanya dalam storan '
        'peribadi aplikasi pada peranti ini. Padam kemajuan melalui Tetapan Ibu '
        'Bapa → Set Semula Kemajuan, padam gambar daripada galeri mewarna, atau '
        'nyahpasang aplikasi untuk memadam semuanya. Kami tidak pernah menerima '
        'data ini, jadi kami tidak menyimpan sebarang salinan.',
  ),
  (
    'Keselamatan data',
    'Aplikasi tidak pernah menghantar data ini ke mana-mana, jadi ia kekal '
        'dilindungi oleh pengasingan aplikasi dan kunci skrin peranti anda. '
        'Pada Android, aplikasi tidak menyertai sandaran awan.',
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
        'di luar talian. Perkhidmatan pertuturan dan teks-ke-pertuturan peranti '
        'anda adalah berasingan dan mungkin menggunakan internet mengikut '
        'tetapan peranti anda.',
  ),
  (
    'Berkongsi gambar',
    'Kanak-kanak boleh meminta untuk berkongsi gambar yang diwarnakan. Orang '
        'dewasa menjawab soalan matematik mudah terlebih dahulu, kemudian menu '
        'kongsi peranti dibuka. Aplikasi tidak memuat naik atau menyimpan salinan.',
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

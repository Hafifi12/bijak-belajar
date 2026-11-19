import 'package:flutter/material.dart';
import '../models/app_language.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/bijak_scene.dart';

/// In-app privacy policy. Google Play's User Data policy (and the Families
/// policy) require the privacy policy to be reachable from within the app —
/// not only in the Play Console — for apps that access sensitive permissions
/// such as the microphone. The full text is shown here so it works offline.
/// Keep the wording in step with privacy_policy.html and privacy_policy_ms.html.
class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  static const routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final language = progress.language;
    final sections = switch (language) {
      AppLanguage.malay || AppLanguage.indonesian => _sectionsMs,
      AppLanguage.english => _sectionsEn,
      AppLanguage.mandarin => _sectionsZh,
      AppLanguage.tamil => _sectionsTa,
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const NightBar(AppTheme.moduleGames),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: language.copy(ms: 'Kembali', en: 'Back', zh: '返回', ta: 'பின்செல்'),
        ),
        title: Text(language.copy(ms: 'Dasar Privasi', en: 'Privacy Policy', zh: '隐私政策', ta: 'தனியுரிமைக் கொள்கை')),
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
                        language.copy(ms: 'Berkuat kuasa 19 November 2026 · ANF Studio', en: 'Effective 19 November 2026 · ANF Studio', zh: '生效日期：2026 年 11 月 19 日 · ANF Studio', ta: 'நடைமுறைக்கு வரும் நாள்: 19 நவம்பர் 2026 · ANF Studio'),
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
        'explanation before the first request. Speech is turned into text on '
        'your phone only, by its offline voice pack. The app never uses an online '
        'speech service, and never records, keeps, or sends any audio. If the '
        'offline voice pack for the language is not installed, speaking practice '
        'is turned off. You can decline the microphone permission and still use '
        'the rest of the app.',
  ),
  (
    'Where data is stored & how to delete it',
    'Learning settings and progress (language, sound, stars, level) and any '
        'colouring pictures your child saves stay only in the app\'s private '
        'storage on this device. Delete progress with Parent Settings → Reset '
        'Progress, delete a picture from the colouring gallery, or uninstall the '
        'app to remove everything. We never receive this data, so we hold no copy.',
  ),
  (
    'Keeping data safe',
    'The app never sends this data anywhere, so it stays protected by your '
        'device\'s app sandboxing and screen lock. On Android the app opts out of '
        'cloud backup. On iPhone and iPad, a backup of the whole device (for '
        'example to iCloud) may include the app\'s data, protected by your account.',
  ),
  (
    'No ads, no tracking',
    'The app shows no advertisements, uses no analytics or tracking, and includes '
        'no third-party data-collection tools.',
  ),
  (
    'Internet',
    'The app makes no network requests and does not include the Android Internet '
        'permission. All content is bundled and works offline. Speech recognition '
        'runs on your phone only. Reading words aloud uses your phone\'s built-in '
        'voice, which may use the internet for some voices, depending on your '
        'phone\'s settings.',
  ),
  (
    'Sharing a picture',
    'A child can ask to share a picture they coloured. A grown-up answers a '
        'simple maths question first, then the device\'s own share menu opens. '
        'The app does not upload, receive, or keep a copy, and does not choose '
        'the recipient.',
  ),
  (
    'Children\'s privacy',
    'Bijak Belajar is designed for children and intended for use with a parent or '
        'guardian. Because we collect no personal data, none is collected from '
        'children. The app is designed to comply with COPPA, Malaysia\'s PDPA 2010, '
        'and the Google Play Families Policy.',
  ),
  (
    'Permissions we request',
    'Microphone (RECORD_AUDIO) — only for the optional pronunciation-practice '
        'activities above. We do not request camera, contacts, location, or file '
        'access.',
  ),
  (
    'Your rights',
    'We do not collect or hold personal data about you or your child, so there is '
        'nothing on our side to access, correct, or delete. You can delete all the '
        'app\'s data at any time, as described above.',
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
    'Apabila anak anda menekan butang sebut, aplikasi menggunakan mikrofon untuk '
        'memberi maklum balas sebutan. Orang dewasa melihat penerangan ringkas '
        'sebelum permintaan pertama. Sebutan ditukar kepada teks pada telefon anda '
        'sahaja, menggunakan pek suara luar talian. Aplikasi tidak pernah '
        'menggunakan perkhidmatan pertuturan dalam talian, dan tidak pernah '
        'merakam, menyimpan, atau menghantar audio. Jika pek suara luar talian '
        'untuk bahasa itu tidak dipasang, latihan bercakap dimatikan. Anda boleh '
        'menolak kebenaran mikrofon dan masih menggunakan aplikasi ini.',
  ),
  (
    'Di mana data disimpan & cara memadamnya',
    'Tetapan dan kemajuan pembelajaran (bahasa, bunyi, bintang, tahap) serta '
        'gambar mewarna yang disimpan oleh anak anda kekal hanya dalam storan '
        'peribadi aplikasi pada telefon ini. Padam kemajuan melalui Tetapan Ibu '
        'Bapa → Set Semula Kemajuan, padam gambar daripada galeri mewarna, atau '
        'nyahpasang aplikasi untuk memadam semuanya. Kami tidak pernah menerima '
        'data ini, jadi kami tidak menyimpan sebarang salinan.',
  ),
  (
    'Keselamatan data',
    'Aplikasi tidak pernah menghantar data ini ke mana-mana, jadi ia kekal '
        'dilindungi oleh pengasingan aplikasi dan kunci skrin telefon anda. Pada '
        'Android, aplikasi tidak menyertai sandaran awan. Pada iPhone dan iPad, '
        'sandaran keseluruhan peranti (contohnya ke iCloud) mungkin termasuk data '
        'aplikasi, dilindungi oleh akaun anda.',
  ),
  (
    'Tiada iklan, tiada penjejakan',
    'Aplikasi tidak memaparkan iklan, tidak menggunakan analitik atau penjejakan, '
        'dan tidak menyertakan alat pengumpulan data pihak ketiga.',
  ),
  (
    'Internet',
    'Aplikasi tidak membuat sebarang permintaan rangkaian dan tidak menyertakan '
        'kebenaran Internet Android. Semua kandungan disertakan dan berfungsi di '
        'luar talian. Pengecaman pertuturan berjalan pada telefon anda sahaja. '
        'Membaca perkataan dengan kuat menggunakan suara terbina dalam telefon, yang '
        'mungkin menggunakan internet bagi sesetengah suara, bergantung pada '
        'tetapan telefon anda.',
  ),
  (
    'Berkongsi gambar',
    'Kanak-kanak boleh meminta untuk berkongsi gambar yang diwarnakan. Orang dewasa '
        'menjawab soalan matematik mudah terlebih dahulu, kemudian menu kongsi '
        'peranti dibuka. Aplikasi tidak memuat naik, menyimpan salinan, atau memilih '
        'penerima.',
  ),
  (
    'Privasi kanak-kanak',
    'Bijak Belajar direka untuk kanak-kanak dan bertujuan digunakan bersama ibu '
        'bapa atau penjaga. Kerana kami tidak mengumpul data peribadi, tiada data '
        'dikumpul daripada kanak-kanak. Aplikasi direka untuk mematuhi COPPA, PDPA '
        'Malaysia 2010, dan Dasar Google Play Families.',
  ),
  (
    'Kebenaran yang kami minta',
    'Mikrofon (RECORD_AUDIO) — hanya untuk aktiviti latihan sebutan pilihan di '
        'atas. Kami tidak meminta kamera, kenalan, lokasi, atau akses fail.',
  ),
  (
    'Hak anda',
    'Kami tidak mengumpul atau menyimpan data peribadi tentang anda atau anak anda, '
        'jadi tiada apa di pihak kami untuk diakses, dibetulkan, atau dipadam. Anda '
        'boleh memadam semua data aplikasi pada bila-bila masa, seperti yang '
        'diterangkan di atas.',
  ),
  (
    'Hubungi kami',
    'Ada soalan tentang dasar ini? E-mel anfstudio.dev@gmail.com',
  ),
];

const List<(String, String)> _sectionsZh = [
  (
    '我们收集什么',
    '什么都不收集。Bijak Belajar 不收集、不存储、不上传或分享任何个人数据，包括姓名、电子邮件、位置、联系人、照片或广告标识符。没有账户，也无需登录。',
  ),
  (
    '麦克风与语音',
    '当孩子点击说话按钮时，应用才会使用麦克风，以提供友好的发音反馈。第一次请求前，家长会看到简短说明。语音只会通过手机上的离线语音包转换为文字。应用从不使用在线语音服务，也从不录制、保存或发送任何音频。如果手机未安装该语言的离线语音包，说话练习将关闭。您可以拒绝麦克风权限，仍可使用应用的其他功能。',
  ),
  (
    '数据存储位置及如何删除',
    '学习设置和进度（语言、声音、星星、等级），以及孩子保存的涂色作品，仅保存在本设备上应用的私有存储中。删除进度：家长设置 → 重置进度；从涂色画廊删除作品；或卸载应用以删除全部内容。我们从未接收这些数据，因此不保留任何副本。',
  ),
  (
    '数据安全',
    '应用从不将这些数据发送到任何地方，因此数据受到手机应用沙盒和屏幕锁的保护。在 Android 上，应用不参与云备份；在 iPhone 和 iPad 上，整机备份（例如 iCloud）可能包含应用数据，并受您账户的保护。',
  ),
  (
    '无广告，无追踪',
    '应用不显示广告，不使用分析或追踪工具，也不包含第三方数据收集工具。',
  ),
  (
    '互联网',
    '应用本身不发起任何网络请求，也未包含 Android 互联网权限。所有内容都已内置，可离线使用。语音识别只在手机上运行。朗读单词时使用手机内置的语音，部分语音可能会根据手机设置使用互联网。',
  ),
  (
    '分享图画',
    '孩子可以请求分享自己涂色的图画。家长需先回答一道简单的数学题，然后才会打开手机自带的分享菜单。应用不会上传、接收或保留副本，也不会选择接收者。',
  ),
  (
    '儿童隐私',
    'Bijak Belajar 专为儿童设计，应在家长或监护人陪同下使用。由于我们不收集任何个人数据，因此不会从儿童收集任何数据。本应用的设计符合 COPPA、马来西亚 2010 年个人数据保护法（PDPA）以及 Google Play 家庭政策。',
  ),
  (
    '我们请求的权限',
    '麦克风（RECORD_AUDIO）——仅用于上述可选的发音练习。我们不请求相机、联系人、位置或文件访问权限。',
  ),
  (
    '您的权利',
    '我们不收集或持有您或孩子的个人数据，因此我们这边没有可供访问、更正或删除的内容。您可以随时按照第 3 项删除应用的全部数据。',
  ),
  (
    '联系我们',
    '对本政策有任何疑问？请发送电子邮件至 anfstudio.dev@gmail.com',
  ),
];

const List<(String, String)> _sectionsTa = [
  (
    'நாங்கள் என்ன சேகரிக்கிறோம்',
    'எதுவுமில்லை. Bijak Belajar பெயர்கள், மின்னஞ்சல்கள், இருப்பிடம், தொடர்புகள், புகைப்படங்கள் அல்லது விளம்பர அடையாளங்கள் உள்ளிட்ட எந்தத் தனிப்பட்ட தரவையும் சேகரிப்பதில்லை, சேமிப்பதில்லை, பதிவேற்றுவதில்லை அல்லது பகிர்வதில்லை. கணக்கு இல்லை, உள்நுழைவும் தேவையில்லை.',
  ),
  (
    'மைக்ரோஃபோன் & குரல்',
    'குழந்தை பேசு பொத்தானைத் தட்டும்போது மட்டுமே, உச்சரிப்புக்கு நட்பான கருத்து வழங்க செயலி மைக்ரோஃபோனைப் பயன்படுத்துகிறது. முதல் கோரிக்கைக்கு முன், பெரியவருக்கு ஒரு சிறிய விளக்கம் காட்டப்படும். பேச்சு உங்கள் தொலைபேசியிலேயே, அதன் ஆஃப்லைன் குரல் தொகுப்பு மூலம் மட்டுமே உரையாக மாற்றப்படுகிறது. இந்தச் செயலி ஒருபோதும் இணைய பேச்சுச் சேவையைப் பயன்படுத்துவதில்லை; எந்த ஒலியையும் பதிவு செய்வதில்லை, சேமிப்பதில்லை அல்லது அனுப்புவதில்லை. அந்த மொழிக்கான ஆஃப்லைன் குரல் தொகுப்பு நிறுவப்படாவிட்டால், பேசும் பயிற்சி நிறுத்தப்படும். மைக்ரோஃபோன் அனுமதியை மறுத்து, செயலியின் மற்ற பகுதிகளைத் தொடர்ந்து பயன்படுத்தலாம்.',
  ),
  (
    'தரவு எங்கே சேமிக்கப்படுகிறது & அதை எப்படி நீக்குவது',
    'கற்றல் அமைப்புகளும் முன்னேற்றமும் (மொழி, ஒலி, நட்சத்திரங்கள், நிலை), குழந்தை சேமிக்கும் வண்ணப் படங்களும் இந்தச் சாதனத்தில் உள்ள செயலியின் தனிப்பட்ட சேமிப்பகத்தில் மட்டுமே இருக்கும். முன்னேற்றத்தை நீக்க: பெற்றோர் அமைப்புகள் → முன்னேற்றத்தை மீட்டமை. வண்ணக் காட்சியகத்திலிருந்து ஒரு படத்தை நீக்கலாம். அனைத்தையும் நீக்க செயலியை நிறுவல் நீக்கவும். இந்தத் தரவை நாங்கள் ஒருபோதும் பெறுவதில்லை, எனவே எந்த நகலையும் வைத்திருப்பதில்லை.',
  ),
  (
    'தரவுப் பாதுகாப்பு',
    'இந்தத் தரவை செயலி ஒருபோதும் எங்கும் அனுப்புவதில்லை; அதனால் தொலைபேசியின் செயலி தனிமைப்படுத்தலும் திரைப் பூட்டும் இதைப் பாதுகாக்கும். Android-இல் செயலி மேகக் காப்புப்பிரதியில் சேர்க்கப்படாது. iPhone மற்றும் iPad-இல், முழு சாதனத்தின் காப்புப்பிரதியில் (எடுத்துக்காட்டாக iCloud) செயலித் தரவு இருக்கலாம்; அது உங்கள் கணக்கால் பாதுகாக்கப்படும்.',
  ),
  (
    'விளம்பரங்கள் இல்லை, கண்காணிப்பு இல்லை',
    'செயலியில் விளம்பரங்கள் இல்லை, பகுப்பாய்வு அல்லது கண்காணிப்பு இல்லை, மூன்றாம் தரப்பு தரவு சேகரிப்புக் கருவிகளும் இல்லை.',
  ),
  (
    'இணையம்',
    'செயலி எந்த நெட்வொர்க் கோரிக்கையையும் தானாக அனுப்புவதில்லை; Android இணைய அனுமதியும் இல்லை. எல்லா உள்ளடக்கமும் செயலியில் உள்ளது; இணையம் இல்லாமலும் வேலை செய்யும். பேச்சு அடையாளம் காணுதல் உங்கள் தொலைபேசியில் மட்டுமே நடக்கும். வார்த்தைகளை உரக்கப் படிக்கும் குரல் தொலைபேசியின் உள்ளமைந்த குரல்; சில குரல்கள் தொலைபேசி அமைப்புகளைப் பொறுத்து இணையத்தைப் பயன்படுத்தலாம்.',
  ),
  (
    'படத்தைப் பகிர்தல்',
    'குழந்தை தான் வண்ணம் தீட்டிய படத்தைப் பகிர விரும்பலாம். முதலில் பெரியவர் ஒரு எளிய கணிதக் கேள்விக்கு விடையளிக்க வேண்டும்; அதன் பிறகுதான் தொலைபேசியின் பகிர்வு மெனு திறக்கும். செயலி எதையும் பதிவேற்றுவதில்லை, நகல் வைத்துக்கொள்வதில்லை, பெறுநரைத் தேர்வு செய்வதுமில்லை.',
  ),
  (
    'குழந்தைகளின் தனியுரிமை',
    'Bijak Belajar குழந்தைகளுக்காக வடிவமைக்கப்பட்டது; பெற்றோர் அல்லது பாதுகாவலருடன் பயன்படுத்த நோக்கம். நாங்கள் தனிப்பட்ட தரவை சேகரிக்காததால், குழந்தைகளிடமிருந்து எந்தத் தரவும் சேகரிக்கப்படுவதில்லை. இந்தச் செயலி COPPA, மலேசியத் தனிப்பட்ட தரவுப் பாதுகாப்புச் சட்டம் 2010 (PDPA) மற்றும் Google Play Families கொள்கை ஆகியவற்றுக்கு இணங்க வடிவமைக்கப்பட்டுள்ளது.',
  ),
  (
    'நாங்கள் கோரும் அனுமதிகள்',
    'மைக்ரோஃபோன் (RECORD_AUDIO) — மேலே விவரிக்கப்பட்ட விருப்பமான பேச்சுப் பயிற்சிக்கு மட்டும். கேமரா, தொடர்புகள், இருப்பிடம் அல்லது கோப்புகளுக்கான அணுகலை நாங்கள் கோருவதில்லை.',
  ),
  (
    'உங்கள் உரிமைகள்',
    'உங்களைப் பற்றியோ குழந்தையைப் பற்றியோ தனிப்பட்ட தரவை நாங்கள் சேகரிப்பதோ வைத்திருப்பதோ இல்லை; எனவே எங்கள் பக்கத்தில் அணுக, திருத்த அல்லது நீக்க எதுவும் இல்லை. மேலே விவரிக்கப்பட்டபடி, செயலியின் அனைத்துத் தரவையும் எந்த நேரத்திலும் நீங்கள் நீக்கலாம்.',
  ),
  (
    'தொடர்பு',
    'இந்தக் கொள்கை குறித்து ஏதேனும் கேள்விகள்? anfstudio.dev@gmail.com என்ற முகவரிக்கு மின்னஞ்சல் அனுப்புங்கள்.',
  ),
];

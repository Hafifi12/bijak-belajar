package com.anfstudio.bijakbelajar

import io.flutter.embedding.android.FlutterActivity

// Plain Flutter template activity.
//
// The previous version hosted a "tiny_finder/tts" MethodChannel with its own
// TextToSpeech engine and ToneGenerator effects. The Dart side migrated to
// the flutter_tts plugin long ago, so none of that code was reachable — and
// it was the source of every unresolved-reference error when the IDE's
// project model went stale. Mirrors the same cleanup done in iOS AppDelegate.
class MainActivity : FlutterActivity()

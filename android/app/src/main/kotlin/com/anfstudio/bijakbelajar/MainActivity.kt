package com.anfstudio.bijakbelajar

import android.os.Build
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Speaking practice must never send a child's voice to a server. The
        // speech plugin falls back to the online recogniser when the offline
        // one is missing, so Dart asks here first whether the offline one exists.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "onDeviceAvailable") {
                    result.success(
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                            SpeechRecognizer.isOnDeviceRecognitionAvailable(this),
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    private companion object {
        const val SPEECH_CHANNEL = "bijak_belajar/speech"
    }
}

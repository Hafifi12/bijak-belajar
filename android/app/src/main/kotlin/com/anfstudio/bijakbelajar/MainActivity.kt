package com.anfstudio.bijakbelajar

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity(), TextToSpeech.OnInitListener {
    private var textToSpeech: TextToSpeech? = null
    private var ttsReady = false
    private var pendingSpeech: Pair<String, String>? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        textToSpeech = TextToSpeech(this, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tiny_finder/tts")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "speak" -> {
                        val text = call.argument<String>("text").orEmpty()
                        val locale = call.argument<String>("locale") ?: "en-US"
                        speak(text, locale)
                        result.success(null)
                    }
                    "playEffect" -> {
                        val name = call.argument<String>("name") ?: "correct"
                        playEffect(name)
                        result.success(null)
                    }
                    "stop" -> {
                        textToSpeech?.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun playEffect(name: String) {
        if (name == "correct") {
            playTone(ToneGenerator.TONE_PROP_ACK, 120)
            handler.postDelayed({ playTone(ToneGenerator.TONE_PROP_ACK, 120) }, 180)
            handler.postDelayed({ playTone(ToneGenerator.TONE_PROP_ACK, 180) }, 360)
        } else {
            playTone(ToneGenerator.TONE_PROP_NACK, 200)
        }
    }

    private fun playTone(tone: Int, durationMs: Int) {
        try {
            val tg = ToneGenerator(AudioManager.STREAM_MUSIC, 85)
            tg.startTone(tone, durationMs)
            handler.postDelayed({ tg.release() }, (durationMs + 50).toLong())
        } catch (_: Exception) {}
    }

    override fun onInit(status: Int) {
        ttsReady = status == TextToSpeech.SUCCESS
        textToSpeech?.setSpeechRate(0.75f)
        textToSpeech?.setPitch(1.3f)
        pendingSpeech?.let { (text, locale) ->
            pendingSpeech = null
            speak(text, locale)
        }
    }

    private fun speak(text: String, localeTag: String) {
        if (text.isBlank()) return
        if (!ttsReady) {
            pendingSpeech = text to localeTag
            return
        }
        textToSpeech?.language = Locale.forLanguageTag(localeTag)
        textToSpeech?.setSpeechRate(0.75f)
        textToSpeech?.setPitch(1.3f)
        textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tiny_finder_tts")
    }

    override fun onDestroy() {
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        super.onDestroy()
    }
}

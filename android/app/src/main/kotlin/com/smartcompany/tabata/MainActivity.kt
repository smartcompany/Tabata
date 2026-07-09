package com.smartcompany.tabata

import android.media.AudioAttributes
import android.speech.tts.TextToSpeech
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Field

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WORKOUT_AUDIO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "configureTtsMediaPlayback" -> {
                    result.success(configureTtsMediaPlayback(flutterEngine))
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun configureTtsMediaPlayback(flutterEngine: FlutterEngine): Boolean {
        val tts = resolveFlutterTts(flutterEngine) ?: return false
        return try {
            tts.setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            true
        } catch (error: Exception) {
            Log.w(TAG, "configureTtsMediaPlayback failed", error)
            false
        }
    }

    private fun resolveFlutterTts(flutterEngine: FlutterEngine): TextToSpeech? {
        return try {
            val pluginClass =
                Class.forName("com.eyedeadevelopment.fluttertts.FlutterTtsPlugin")
            val registry = flutterEngine.plugins
            val getPlugin = registry.javaClass.methods.firstOrNull { method ->
                method.name == "get" && method.parameterTypes.size == 1
            } ?: return null
            val plugin = getPlugin.invoke(registry, pluginClass) ?: return null
            val ttsField: Field = pluginClass.getDeclaredField("tts")
            ttsField.isAccessible = true
            ttsField.get(plugin) as? TextToSpeech
        } catch (error: Exception) {
            Log.w(TAG, "resolveFlutterTts failed", error)
            null
        }
    }

    companion object {
        private const val TAG = "WorkoutAudio"
        private const val WORKOUT_AUDIO_CHANNEL = "com.smartcompany.tabata/workout_audio"
    }
}

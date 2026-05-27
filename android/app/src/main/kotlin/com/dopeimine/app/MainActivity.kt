package com.dopeimine.app

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dope_i_mine/cached_audio"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playFile" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("missing_path", "Audio file path is required.", null)
                        return@setMethodCallHandler
                    }
                    try {
                        mediaPlayer?.release()
                        mediaPlayer = MediaPlayer().apply {
                            setDataSource(path)
                            setOnCompletionListener {
                                it.release()
                                if (mediaPlayer == it) mediaPlayer = null
                            }
                            prepare()
                            start()
                        }
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("playback_failed", error.message, null)
                    }
                }
                "stop" -> {
                    mediaPlayer?.release()
                    mediaPlayer = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}

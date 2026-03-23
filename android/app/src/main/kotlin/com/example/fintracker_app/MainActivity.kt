package com.example.fintracker_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "fintracker/storage"
        private const val PREFS_NAME = "fintracker_native_prefs"
        private const val KEY_DATA = "app_data"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)

                when (call.method) {
                    "loadData" -> result.success(prefs.getString(KEY_DATA, ""))
                    "saveData" -> {
                        val json = call.argument<String>("json").orEmpty()
                        val saved = prefs.edit().putString(KEY_DATA, json).commit()
                        result.success(saved)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

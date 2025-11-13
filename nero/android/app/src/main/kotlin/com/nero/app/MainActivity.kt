package com.nero.app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.nero.app/installer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstallerPackageName") {
                try {
                    val installer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        packageManager.getInstallSourceInfo(packageName).installingPackageName
                    } else {
                        @Suppress("DEPRECATION")
                        packageManager.getInstallerPackageName(packageName)
                    }
                    result.success(installer)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

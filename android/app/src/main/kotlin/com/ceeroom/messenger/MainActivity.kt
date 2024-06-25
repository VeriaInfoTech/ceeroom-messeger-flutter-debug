package com.ceeroom.messenger

import android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "wakelock_channel").setMethodCallHandler { call, result ->
            if (call.method == "toggle") {
                val enable = call.arguments as Boolean
                if (enable) {
                    window.addFlags(FLAG_KEEP_SCREEN_ON)
                } else {
                    window.clearFlags(FLAG_KEEP_SCREEN_ON)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
//package com.ceeroom.messenger
//
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
////import android.content.Intent
//
//class MainActivity: FlutterActivity() {
////    private val CHANNEL = "miui_permissions"
////
////    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
////        super.configureFlutterEngine(flutterEngine)
////        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
////            call, result ->
////            if (call.method == "openPermissionsEditor") {
////                openPermissionsEditor()
////            } else {
////                result.notImplemented()
////            }
////        }
////    }
////
////    private fun openPermissionsEditor() {
////        val intent = Intent("miui.intent.action.APP_PERM_EDITOR")
////        intent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
////        intent.putExtra("extra_pkgname", packageName)
////        startActivity(intent)
////    }
//}

package eu.heili.wormhole

import android.content.Intent
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "io.wormhole.app/transfer_activity"
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "start" -> {
                        TransferForegroundService.start(
                            applicationContext,
                            call.argument<String>("title"),
                            call.argument<String>("channel"),
                            call.argument<String>("status")
                        )
                        result.success(null)
                    }
                    "update" -> {
                        TransferForegroundService.update(
                            applicationContext,
                            call.argument<String>("title"),
                            call.argument<String>("channel"),
                            call.argument<String>("status"),
                            call.argument<Int>("progress")
                        )
                        result.success(null)
                    }
                    "stop" -> {
                        TransferForegroundService.stop(applicationContext)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("transfer_activity", error.message, null)
            }
        }
        java.lang.Thread.sleep(1000);
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
        super.onCreate(savedInstanceState)
    }
}

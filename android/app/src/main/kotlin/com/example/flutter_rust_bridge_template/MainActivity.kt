package eu.heili.wormhole

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.webkit.MimeTypeMap
import androidx.annotation.NonNull;
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import java.io.File

class MainActivity: FlutterActivity() {
    companion object {
        private const val SAF_CHANNEL = "eu.heili.wormhole/saf"
        private const val PICK_DIRECTORY_REQUEST = 0xA1F0
    }

    /// Pending result for the directory picker, completed in onActivityResult.
    private var pendingPickerResult: MethodChannel.Result? = null

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAF_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDirectory" -> pickDirectory(result)
                "saveToTree" -> {
                    val treeUri = call.argument<String>("treeUri")
                    val sourcePath = call.argument<String>("sourcePath")
                    val fileName = call.argument<String>("fileName")
                    if (treeUri == null || sourcePath == null || fileName == null) {
                        result.error("saf", "Missing argument for saveToTree", null)
                    } else {
                        saveToTree(treeUri, sourcePath, fileName, result)
                    }
                }
                else -> result.notImplemented()
            }
        }

        java.lang.Thread.sleep(1000);
    }

    /// Launch the system folder picker (ACTION_OPEN_DOCUMENT_TREE) and persist
    /// read/write access to the selected tree so we can write files into it.
    private fun pickDirectory(result: MethodChannel.Result) {
        if (pendingPickerResult != null) {
            result.error("saf", "A directory picker is already in progress", null)
            return
        }
        pendingPickerResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
        }
        try {
            startActivityForResult(intent, PICK_DIRECTORY_REQUEST)
        } catch (error: Exception) {
            pendingPickerResult = null
            result.error("saf", error.message, null)
        }
    }

    /// Copy an already-received file from [sourcePath] into the SAF tree at
    /// [treeUri], creating a document named [fileName] (collision-safe). Runs the
    /// copy off the main thread and returns the resulting document URI string.
    private fun saveToTree(
        treeUri: String,
        sourcePath: String,
        fileName: String,
        result: MethodChannel.Result
    ) {
        Thread {
            try {
                val tree = DocumentFile.fromTreeUri(applicationContext, Uri.parse(treeUri))
                    ?: throw IllegalStateException("Cannot open selected folder")
                if (!tree.canWrite()) {
                    throw IllegalStateException("No write permission for selected folder")
                }

                val targetName = freeFileName(tree, fileName)
                val mime = mimeTypeFor(targetName)
                val document = tree.createFile(mime, targetName)
                    ?: throw IllegalStateException("Could not create file in selected folder")

                contentResolver.openOutputStream(document.uri).use { output ->
                    if (output == null) {
                        throw IllegalStateException("Could not open output stream")
                    }
                    File(sourcePath).inputStream().use { input ->
                        input.copyTo(output)
                    }
                    output.flush()
                }

                val uri = document.uri.toString()
                runOnUiThread { result.success(uri) }
            } catch (error: Exception) {
                runOnUiThread { result.error("saf", error.message, null) }
            }
        }.start()
    }

    /// Mirror the Rust receiver's "(copy)" naming so a duplicate name does not
    /// overwrite an existing file in the destination folder.
    private fun freeFileName(tree: DocumentFile, fileName: String): String {
        if (tree.findFile(fileName) == null) return fileName

        val dot = fileName.lastIndexOf('.')
        val stem = if (dot > 0) fileName.substring(0, dot) else fileName
        val ext = if (dot > 0) fileName.substring(dot) else ""

        var candidate = "$stem(copy)$ext"
        while (tree.findFile(candidate) != null) {
            candidate = candidate.substring(0, candidate.length - ext.length) + "(copy)" + ext
        }
        return candidate
    }

    private fun mimeTypeFor(fileName: String): String {
        val ext = fileName.substringAfterLast('.', "").lowercase()
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext)
            ?: "application/octet-stream"
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_DIRECTORY_REQUEST) return

        val result = pendingPickerResult ?: return
        pendingPickerResult = null

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }

        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            result.success(uri.toString())
        } catch (error: Exception) {
            result.error("saf", error.message, null)
        }
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

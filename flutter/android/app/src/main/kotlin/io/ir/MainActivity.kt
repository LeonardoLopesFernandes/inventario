package io.ir

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {
    private val mediaChannel = "com.ir/media"
    private val beepChannel = "com.ir/beep"
    private var beepGen: android.media.ToneGenerator? = null

    override fun onDestroy() {
        try {
            beepGen?.release()
        } catch (_: Throwable) {
        }
        beepGen = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads", "saveToDownloadsAndOpen" -> {
                        try {
                            val fileName = call.argument<String>("fileName") ?: "arquivo"
                            val mime = call.argument<String>("mime")
                                ?: call.argument<String>("mimeType")
                                ?: "application/octet-stream"
                            val bytes = call.argument<ByteArray>("bytes")
                            if (bytes == null) {
                                result.error("NO_BYTES", "bytes nulo", null)
                                return@setMethodCallHandler
                            }
                            val uri = saveToDownloads(fileName, mime, bytes)
                            if (call.method == "saveToDownloadsAndOpen") {
                                uri?.let { openFile(it, mime) }
                            }
                            result.success(uri?.toString())
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, beepChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "success", "error" -> {
                        try {
                            if (beepGen == null) {
                                beepGen = android.media.ToneGenerator(
                                    android.media.AudioManager.STREAM_MUSIC, 100
                                )
                            }
                            val tone = if (call.method == "success") {
                                android.media.ToneGenerator.TONE_PROP_BEEP
                            } else {
                                android.media.ToneGenerator.TONE_PROP_NACK
                            }
                            beepGen?.startTone(tone, 160)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("BEEP_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openFile(uri: Uri, mime: String) {
        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mime)
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_ACTIVITY_NEW_TASK
                )
            }
            startActivity(intent)
        } catch (_: Exception) {
        }
    }

    private fun saveToDownloads(fileName: String, mimeType: String, bytes: ByteArray): Uri? {
        val resolver = contentResolver
        val collection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Downloads.EXTERNAL_CONTENT_URI
        } else {
            MediaStore.Files.getContentUri("external")
        }
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Downloads.IS_PENDING, 1)
                put(MediaStore.Downloads.RELATIVE_PATH, "Download")
            } else {
                val dir = android.os.Environment
                    .getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_DOWNLOADS)
                val file = java.io.File(dir, fileName)
                put(MediaStore.Files.FileColumns.DATA, file.absolutePath)
            }
        }
        val uri = resolver.insert(collection, values) ?: return null
        resolver.openOutputStream(uri)?.use { os: OutputStream ->
            os.write(bytes)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }
        return uri
    }
}

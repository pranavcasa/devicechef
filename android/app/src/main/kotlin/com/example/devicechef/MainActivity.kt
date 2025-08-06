package com.example.devicechef

import android.app.Activity
import android.content.*
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.database.Cursor
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val DEVICE_CHANNEL = "device_info_channel"
    private val IMAGE_CHANNEL = "image_picker_channel"
    private val BATTERY_CHANNEL = "battery_channel"
    private val BATTERY_STREAM = "battery_stream"
    private var imageResult: MethodChannel.Result? = null
    private val IMAGE_PICKER_REQUEST = 101

    private var batteryReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Device Info Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceInfo") {
                val deviceInfo: Map<String, String> = mapOf(
                    "brand" to Build.BRAND,
                    "model" to Build.MODEL,
                    "manufacturer" to Build.MANUFACTURER,
                    "version" to Build.VERSION.RELEASE
                )
                result.success(deviceInfo)
            } else {
                result.notImplemented()
            }
        }

        // Image Picker Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickImage") {
                imageResult = result
                val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
                startActivityForResult(intent, IMAGE_PICKER_REQUEST)
            } else {
                result.notImplemented()
            }
        }

        // Real-time Battery EventChannel
       EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_STREAM).setStreamHandler(
    object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            batteryReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                    val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
                    val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1

                    val batteryPct = if (level >= 0 && scale > 0) {
                        (level * 100 / scale.toFloat()).toInt()
                    } else {
                        0
                    }

                    val statusString = when (status) {
                        BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
                        BatteryManager.BATTERY_STATUS_FULL -> "Full"
                        BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
                        BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not Charging"
                        else -> "Unknown"
                    }

                    // Send map to Flutter
                    val result: Map<String, Any> = mapOf(
                        "percentage" to batteryPct,
                        "status" to statusString
                    )
                    events?.success(result)
                }
            }
            val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            registerReceiver(batteryReceiver, filter)
        }

        override fun onCancel(arguments: Any?) {
            if (batteryReceiver != null) {
                unregisterReceiver(batteryReceiver)
                batteryReceiver = null
            }
        }
    }
)

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IMAGE_PICKER_REQUEST && resultCode == Activity.RESULT_OK) {
            val uri: Uri? = data?.data
            val path = uri?.let { getRealPathFromURI(it) }
            imageResult?.success(path)
        } else {
            imageResult?.success(null)
        }
    }

    private fun getRealPathFromURI(contentUri: Uri): String? {
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = contentResolver.query(contentUri, proj, null, null, null)
            val columnIndex = cursor?.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            cursor?.moveToFirst()
            columnIndex?.let { cursor?.getString(it) }
        } finally {
            cursor?.close()
        }
    }
}

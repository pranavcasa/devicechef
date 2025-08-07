// MainActivity.kt (Android Side)
package com.example.devicechef

import android.app.Activity
import android.app.ActivityManager
import android.content.*
import android.net.Uri
import android.os.*
import android.database.Cursor
import android.provider.MediaStore
import android.util.DisplayMetrics
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import java.io.File
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private val DEVICE_CHANNEL = "device_info_channel"
    private val IMAGE_CHANNEL = "image_picker_channel"
    private val BATTERY_STREAM = "battery_stream"
    private val IMAGE_PICKER_REQUEST = 101
    private var imageResult: MethodChannel.Result? = null
    private var batteryReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Device Info Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getDeviceInfo") {
                    val info: MutableMap<String, String> = mutableMapOf(
                        "brand" to Build.BRAND,
                        "model" to Build.MODEL,
                        "manufacturer" to Build.MANUFACTURER,
                        "version" to Build.VERSION.RELEASE,
                        "processor" to Build.HARDWARE,
                    )

                    val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
                    val memoryInfo = ActivityManager.MemoryInfo()
                    activityManager.getMemoryInfo(memoryInfo)
                    val ramGB = memoryInfo.totalMem / (1024 * 1024 * 1024)
                    info["ram"] = "${ramGB} GB"

                    val path = Environment.getDataDirectory()
                    val stat = StatFs(path.path)
                    val bytesAvailable = stat.blockSizeLong * stat.blockCountLong
                    val storageGB = bytesAvailable / (1024 * 1024 * 1024)
                    info["storage"] = "${storageGB} GB"

                    val displayMetrics: DisplayMetrics = resources.displayMetrics
                    val widthPx = displayMetrics.widthPixels
                    val heightPx = displayMetrics.heightPixels
                    val widthInches = widthPx / displayMetrics.xdpi.toDouble()
                    val heightInches = heightPx / displayMetrics.ydpi.toDouble()
                    val diagonalInches = sqrt(widthInches * widthInches + heightInches * heightInches)
                    info["screenSize"] = String.format("%.1f inches", diagonalInches)

                    val batteryCapacityMah = getBatteryCapacity()
                    info["batteryCapacity"] = "${batteryCapacityMah} mAh"

                    result.success(info)
                } else {
                    result.notImplemented()
                }
            }

        // Image Picker for all image types
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, IMAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickImage") {
                    imageResult = result
                    val intent = Intent(Intent.ACTION_GET_CONTENT)
                    intent.type = "image/*"
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    startActivityForResult(Intent.createChooser(intent, "Select Image"), IMAGE_PICKER_REQUEST)
                } else {
                    result.notImplemented()
                }
            }

        // Battery Streaming
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_STREAM)
            .setStreamHandler(object : EventChannel.StreamHandler {
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

                            val batteryInfo: Map<String, Any> = mapOf(
                                "percentage" to batteryPct,
                                "status" to statusString
                            )
                            events?.success(batteryInfo)
                        }
                    }
                    val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                    registerReceiver(batteryReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    batteryReceiver?.let { unregisterReceiver(it) }
                    batteryReceiver = null
                }
            })
    }

    private fun getBatteryCapacity(): Int {
        return try {
            val powerProfileClass = Class.forName("com.android.internal.os.PowerProfile")
            val constructor = powerProfileClass.getConstructor(Context::class.java)
            val powerProfile = constructor.newInstance(this)
            val capacityMethod = powerProfileClass.getMethod("getBatteryCapacity")
            (capacityMethod.invoke(powerProfile) as Double).toInt()
        } catch (e: Exception) {
            0
        }
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
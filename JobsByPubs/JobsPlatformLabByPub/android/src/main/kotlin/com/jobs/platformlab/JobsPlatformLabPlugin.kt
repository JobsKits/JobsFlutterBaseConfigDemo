package com.jobs.platformlab

import android.Manifest
import android.app.Activity
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.*
import android.content.pm.PackageManager
import android.hardware.*
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.net.Uri
import android.os.*
import android.provider.MediaStore
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.File
import java.util.UUID

/** Native adapters own permission and lifecycle work; no mock device readings. */
class JobsPlatformLabPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener,
    PluginRegistry.ActivityResultListener, SensorEventListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var sink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())
    private var permissionCompletion: (() -> Unit)? = null
    private var permissionResult: MethodChannel.Result? = null
    private var audioGeneration = 0
    private var rtmpGeneration = 0
    private var recorder: MediaRecorder? = null
    private var recorderFile: File? = null
    private var player: MediaPlayer? = null
    private var videoResult: MethodChannel.Result? = null
    private var sensorKind = ""
    private var lastShakeTime = 0L
    // 首页入口与传感器 Demo 分开注册，彼此停止时不抢占监听。
    private val shakeListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent) {
            val strength = kotlin.math.sqrt(event.values.take(3).sumOf { it.toDouble() * it.toDouble() }) / SensorManager.GRAVITY_EARTH
            val now = SystemClock.elapsedRealtime()
            if (strength > 2.2 && now - lastShakeTime > 1000) {
                lastShakeTime = now
                emit("shake", mapOf("event" to "shake"))
            }
        }
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }
    private val devices = mutableMapOf<String, BluetoothDevice>()
    private val rssis = mutableMapOf<String, Int>()
    private val connections = mutableMapOf<String, BluetoothGatt>()
    private val connectResults = mutableMapOf<String, MethodChannel.Result>()
    private val pending = mutableMapOf<String, MethodChannel.Result>()
    private val expiryTokens=mutableMapOf<String,UUID>()
    private val mtus=mutableMapOf<String,Int>()
    private val reconnect = mutableSetOf<String>()
    private var scanName = ""
    private var scanDuplicates = false
    private var scanGeneration = 0
    private val scanSeen = mutableSetOf<String>()
    private var pdf: android.graphics.pdf.PdfRenderer? = null
    private var pdfDescriptor: android.os.ParcelFileDescriptor? = null
    private val rtmp by lazy { JobsRTMPAdapter(context, ::emit) }
    private var scanner: BluetoothLeScanner? = null
    private var captureCallback: Activity.ScreenCaptureCallback? = null
    private val players = mutableMapOf<Int, JobsPlayerView>()
    private val sensors get() = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val bluetooth get() = (context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    private val directory get() = File(context.filesDir, "JobsPlatformLabRecordings").apply { mkdirs() }
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, value: ScanResult) {
            try {
                val device = value.device
                if (scanName.isNotEmpty() && !(device.name ?: "").lowercase().contains(scanName)) return
                if (!scanDuplicates && !scanSeen.add(device.address)) return
                devices[device.address] = device
                rssis[device.address] = value.rssi
                emit("ble", mapOf("event" to "discovered", "device" to deviceInfo(device)))
            } catch (error: SecurityException) { emit("ble", mapOf("error" to error.toString())) }
        }
        override fun onScanFailed(errorCode: Int) { emit("ble", mapOf("error" to "scan:$errorCode")) }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "jobs_platform_lab/methods")
        channel.setMethodCallHandler(this)
        EventChannel(binding.binaryMessenger, "jobs_platform_lab/events").setStreamHandler(this)
        binding.platformViewRegistry.registerViewFactory("jobs_platform_lab/player", object: PlatformViewFactory(StandardMessageCodec.INSTANCE) {
            override fun create(viewContext: Context, viewId: Int, args: Any?): PlatformView {
                return JobsPlayerView(viewContext, viewId, { activity }, ::emit) { players.remove(viewId) }.also { players[viewId] = it }
            }
        })
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        stopResources()
    }
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) { sink = events }
    override fun onCancel(arguments: Any?) { sink = null }
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
        binding.addActivityResultListener(this)
        if (Build.VERSION.SDK_INT >= 34) {
            captureCallback = Activity.ScreenCaptureCallback { emit("screen", mapOf("event" to "screenshot")) }
            activity?.registerScreenCaptureCallback(context.mainExecutor, captureCallback!!)
        }
    }
    override fun onDetachedFromActivityForConfigChanges() = detachActivity()
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)
    override fun onDetachedFromActivity() = detachActivity()
    private fun detachActivity() {
        if (Build.VERSION.SDK_INT >= 34) captureCallback?.let { activity?.unregisterScreenCaptureCallback(it) }
        activity = null
    }
    private fun emit(topic: String, data: Map<String, Any?>) {
        main.post { sink?.success(mapOf("topic" to topic, "time" to System.currentTimeMillis()/1000.0, "data" to data)) }
    }
    private fun error(result: MethodChannel.Result, e: Throwable) = result.error("platform_lab", e.message, null)
    private fun permission(names: Array<String>, result: MethodChannel.Result, block: () -> Unit) {
        val missing = names.filter { context.checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED }
        if (missing.isEmpty()) { block(); return }
        check(permissionCompletion == null) { "Permission request already active" }
        val host = activity ?: throw IllegalStateException("No active Activity")
        permissionCompletion = block
        permissionResult = result
        host.requestPermissions(missing.toTypedArray(), 8193)
    }
    override fun onRequestPermissionsResult(code: Int, names: Array<out String>, granted: IntArray): Boolean {
        if (code != 8193) return false
        val completion = permissionCompletion
        val result = permissionResult
        permissionCompletion = null
        permissionResult = null
        if (granted.isNotEmpty() && granted.all { it == PackageManager.PERMISSION_GRANTED }) {
            try { completion?.invoke() } catch (e: Exception) { result?.let { error(it,e) } }
        } else result?.error("permission", "Permission denied", null)
        return true
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        try {
            when {
                call.method == "player.command" -> {
                    val id = (args["viewId"] as? Number)?.toInt() ?: -1
                    val player = players[id] ?: throw IllegalStateException("Player view is not attached")
                    player.command(args, result)
                }
                call.method == "runtime.inspect" -> {
                    val type = Class.forName(args["name"] as? String ?: "android.app.Activity")
                    result.success(mapOf(
                        "name" to type.name,
                        "superclass" to type.superclass?.name,
                        "runtime" to "Java",
                        "methods" to type.declaredMethods.map { method -> mapOf(
                            "name" to method.name,
                            "returns" to method.returnType.name,
                            "parameters" to method.parameterTypes.map { it.name }
                        ) }.sortedBy { it["name"].toString() },
                        "properties" to type.declaredFields.map { mapOf("name" to it.name, "type" to it.type.name) }
                    ))
                }
                call.method == "runtime.define" -> result.error("unsupported", "Objective-C dynamic class registration requires iOS", null)
                call.method == "rtmp.start" -> {
                    val token = ++rtmpGeneration
                    permission(arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO),result) {
                        if (token == rtmpGeneration) rtmp.start(args["url"] as? String ?: "",result)
                        else result.error("cancelled", "RTMP request cancelled", null)
                    }
                }
                call.method == "rtmp.stop" -> {rtmpGeneration++;rtmp.stop();result.success(true)}
                call.method.startsWith("pdf.") -> pdf(call.method,args,result)
                call.method.startsWith("unity.") -> unity(call.method,args,result)
                call.method.startsWith("ble.") -> {
                    val permissions = if (Build.VERSION.SDK_INT >= 31) arrayOf(Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT) else arrayOf(Manifest.permission.ACCESS_FINE_LOCATION)
                    permission(permissions,result) { ble(call.method.removePrefix("ble."),args,result) }
                }
                call.method.startsWith("audio.") -> {
                    if (call.method == "audio.start" || call.method == "audio.permission") {
                        val token = ++audioGeneration
                        permission(arrayOf(Manifest.permission.RECORD_AUDIO),result) {
                            if (token == audioGeneration) audio(call.method,args,result)
                            else result.error("cancelled", "Recording request cancelled", null)
                        }
                    } else {
                        if (call.method == "audio.cancel" || call.method == "audio.stop") audioGeneration++
                        audio(call.method,args,result)
                    }
                }
                call.method == "video.record" -> permission(arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO),result) {video(call.method,args,result)}
                call.method == "video.saveToPhotos" && Build.VERSION.SDK_INT < 29 -> permission(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),result) {video(call.method,args,result)}
                call.method.startsWith("video.") -> video(call.method,args,result)
                else -> system(call.method,args,result)
            }
        } catch (e: Exception) { error(result,e) }
    }
    private fun system(method: String, args: Map<*, *>, result: MethodChannel.Result) {
        when (method) {
            "capabilities" -> result.success(mapOf("platform" to "android", "arkit" to false, "ble" to (bluetooth != null), "motion" to (sensors.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null), "recording" to true, "multipleScenes" to (Build.VERSION.SDK_INT >= 24)))
            "motion.start" -> {
                sensors.unregisterListener(this)
                sensorKind = args["kind"] as? String ?: "device"
                val type = when(sensorKind) { "accelerometer" -> Sensor.TYPE_ACCELEROMETER; "gyroscope" -> Sensor.TYPE_GYROSCOPE; "magnetometer" -> Sensor.TYPE_MAGNETIC_FIELD; else -> Sensor.TYPE_ROTATION_VECTOR }
                val sensor = sensors.getDefaultSensor(type) ?: throw IllegalStateException("Sensor unavailable")
                sensors.registerListener(this,sensor,100_000)
                result.success(true)
            }
            "motion.stop" -> { sensors.unregisterListener(this); result.success(true) }
            "shake.start" -> {
                sensors.unregisterListener(shakeListener)
                val sensor = sensors.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
                    ?: throw IllegalStateException("Accelerometer unavailable")
                check(sensors.registerListener(shakeListener, sensor, 50_000)) { "Accelerometer registration failed" }
                result.success(true)
            }
            "shake.stop" -> {
                sensors.unregisterListener(shakeListener)
                result.success(true)
            }
            "clipboard.write" -> { (context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).setPrimaryClip(ClipData.newPlainText("Jobs",args["text"] as? String ?: ""));result.success(true) }
            "clipboard.read" -> result.success((context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager).primaryClip?.getItemAt(0)?.coerceToText(context)?.toString() ?: "")
            "system.share" -> {
                val host = activity ?: throw IllegalStateException("No active Activity")
                val text = (args["text"] as? String).orEmpty()
                val url = (args["url"] as? String).orEmpty()
                if (url.isNotEmpty()) {
                    val uri = Uri.parse(url)
                    require(uri.scheme in listOf("http", "https") && !uri.host.isNullOrEmpty()) { "Sharing requires a valid HTTP(S) URL" }
                }
                val content = listOf(text, url).filter { it.isNotEmpty() }.joinToString("\n")
                require(content.isNotEmpty()) { "Share text or URL is required" }
                val send = Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, content)
                host.startActivity(Intent.createChooser(send, args["title"] as? String))
                result.success(mapOf("presented" to true))
            }
            "screen.protect" -> {
                val host = activity ?: throw IllegalStateException("No active Activity")
                if (args["enabled"] == true) host.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE) else host.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                result.success(mapOf("screenshotBlocking" to true,"recording" to false))
            }
            "screen.status" -> result.success(mapOf("screenshotBlocking" to true,"enabled" to (((activity?.window?.attributes?.flags ?: 0) and WindowManager.LayoutParams.FLAG_SECURE) != 0)))
            "url.open" -> {
                val uri=Uri.parse(args["url"] as? String ?: "")
                require(uri.scheme in listOf("http","https","mailto","tel","sms")) { "URL scheme is not allowed" }
                context.startActivity(Intent(Intent.ACTION_VIEW,uri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                result.success(true)
            }
            "device.risk" -> { val found=listOf("/system/bin/su","/system/xbin/su","/sbin/su").filter { File(it).exists() };result.success(mapOf("indicators" to found,"riskDetected" to found.isNotEmpty(),"buildTags" to Build.TAGS)) }
            "scenes.list" -> result.success(listOf(mapOf("id" to (activity?.taskId ?: -1), "state" to (activity?.isInMultiWindowMode ?: false))))
            "scenes.open" -> {
                val host = activity ?: throw IllegalStateException("No active Activity")
                val launch=Intent(host,host.javaClass).addFlags(Intent.FLAG_ACTIVITY_NEW_DOCUMENT or Intent.FLAG_ACTIVITY_MULTIPLE_TASK)
                launch.putExtra("jobs.scene.id",UUID.randomUUID().toString())
                host.startActivity(launch)
                result.success(true)
            }
            "icon.status" -> {
                val info=context.packageManager.getPackageInfo(context.packageName,PackageManager.GET_ACTIVITIES or PackageManager.GET_DISABLED_COMPONENTS)
                result.success(mapOf("names" to (info.activities ?: emptyArray()).filter { it.targetActivity != null }.map { it.name },"current" to ""))
            }
            "icon.set" -> {
                val info=context.packageManager.getPackageInfo(context.packageName,PackageManager.GET_ACTIVITIES or PackageManager.GET_DISABLED_COMPONENTS)
                val aliases=(info.activities ?: emptyArray()).filter { it.targetActivity != null }
                check(aliases.isNotEmpty()) { "No launcher aliases configured" }
                val name=(args["name"] as? String).orEmpty().ifEmpty { aliases.first().name }
                require(aliases.any { it.name==name }) { "Unknown configured icon alias" }
                aliases.forEach { context.packageManager.setComponentEnabledSetting(ComponentName(context,it.name),if(it.name==name) PackageManager.COMPONENT_ENABLED_STATE_ENABLED else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,PackageManager.DONT_KILL_APP) }
                result.success(true)
            }
            "widget.write" -> {context.getSharedPreferences("jobs_widget",Context.MODE_PRIVATE).edit().putString("text",args["text"] as? String ?: "Jobs Flutter").apply();context.sendBroadcast(Intent("com.jobs.platformlab.WIDGET_UPDATE").setPackage(context.packageName));result.success(true)}
            "widget.pin" -> {
                check(Build.VERSION.SDK_INT>=26){"Pin widgets requires Android 8 or newer"}
                val manager=android.appwidget.AppWidgetManager.getInstance(context)
                check(manager.isRequestPinAppWidgetSupported){"Launcher does not support pinning"}
                result.success(manager.requestPinAppWidget(ComponentName(context,JobsLabWidget::class.java),null,null))
            }
            "widget.read" -> result.success(mapOf("text" to context.getSharedPreferences("jobs_widget",Context.MODE_PRIVATE).getString("text","")))
            else -> result.notImplemented()
        }
    }
    override fun onSensorChanged(event: SensorEvent) {
        if(sensorKind=="device") {
            val matrix=FloatArray(9);SensorManager.getRotationMatrixFromVector(matrix,event.values)
            val pose=FloatArray(3);SensorManager.getOrientation(matrix,pose)
            emit("motion",mapOf("kind" to sensorKind,"yaw" to pose[0].toDouble(),"pitch" to pose[1].toDouble(),"roll" to pose[2].toDouble()))
        } else emit("motion",mapOf("kind" to sensorKind,"x" to event.values[0].toDouble(),"y" to event.values[1].toDouble(),"z" to event.values[2].toDouble()))
    }
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    private fun audio(method: String,args: Map<*, *>,result: MethodChannel.Result) {
        when(method) {
            "audio.status" -> result.success(mapOf("recording" to (recorder!=null),"name" to recorderFile?.name))
            "audio.permission" -> result.success(true)
            "audio.start" -> {
                check(recorder==null) { "Recording already active" }
                val file=File(directory,"${UUID.randomUUID()}.m4a")
                val value=if(Build.VERSION.SDK_INT>=31) MediaRecorder(context) else MediaRecorder()
                value.setAudioSource(MediaRecorder.AudioSource.MIC);value.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                value.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);value.setAudioSamplingRate(44100);value.setOutputFile(file.path)
                val seconds=(args["maxSeconds"] as? Number)?.toInt() ?: 0
                if(seconds>0)value.setMaxDuration(seconds.coerceAtMost(3600)*1000)
                value.setOnInfoListener { _,what,_ -> if(what==MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED) stopAudio(false) }
                value.prepare();value.start();recorder=value;recorderFile=file;meter()
                JobsAudioServiceOwner.stop={stopAudio(false)}
                val service=Intent(context,JobsAudioService::class.java).putExtra("title",args["notificationTitle"] as? String ?: "Jobs Flutter").putExtra("message",args["notificationMessage"] as? String ?: "Audio recording")
                if(Build.VERSION.SDK_INT>=26)context.startForegroundService(service) else context.startService(service)
                result.success(mapOf("name" to file.name))
            }
            "audio.stop" -> {val name=recorderFile?.name;stopAudio(false);result.success(mapOf("name" to name))}
            "audio.cancel" -> {stopAudio(true);result.success(true)}
            "audio.pause" -> {recorder?.pause();result.success(true)}
            "audio.resume" -> {recorder?.resume();result.success(true)}
            "audio.list" -> result.success(listFiles("m4a"))
            "audio.play" -> {player?.release();player=MediaPlayer().apply { setDataSource(file(args).path);prepare();start() };result.success(true)}
            "audio.stopPlayback" -> {player?.release();player=null;result.success(true)}
            "audio.delete" -> {val value=file(args);check(value!=recorderFile){"Recording active"};check(value.delete());result.success(true)}
            else -> result.notImplemented()
        }
    }
    private fun meter() {
        val value=recorder ?: return
        try {emit("audio",mapOf("event" to "meter","power" to value.maxAmplitude,"recording" to true))}catch(_:Exception){}
        main.postDelayed({if(recorder!=null)meter()},200)
    }
    private fun stopAudio(cancel:Boolean) {
        JobsAudioServiceOwner.stop=null
        context.stopService(Intent(context,JobsAudioService::class.java))
        try {recorder?.stop()}catch(_:Exception){}
        recorder?.release();recorder=null
        val value=recorderFile;recorderFile=null
        if(cancel)value?.delete()
        emit("audio",mapOf("event" to "finished","name" to value?.name,"saved" to !cancel))
    }
    private fun file(args:Map<*, *>):File {
        val name=args["name"] as? String ?: throw IllegalArgumentException("No recording name")
        require(File(name).name==name && !name.contains("..")){"Invalid recording name"}
        return File(directory,name).also {require(it.isFile){"Recording does not exist"}}
    }
    private fun listFiles(extension:String)=directory.listFiles()?.filter {it.extension==extension}?.map {mapOf("name" to it.name,"bytes" to it.length(),"created" to it.lastModified()/1000.0)} ?: emptyList()
    private fun video(method:String,args:Map<*, *>,result:MethodChannel.Result) {
        when(method) {
            "video.discard" -> {
                val path = args["path"] as? String ?: throw IllegalArgumentException("Camera temporary file path is required")
                val temporary = File(path).canonicalFile
                val roots = listOfNotNull(context.cacheDir, context.externalCacheDir)
                require(temporary.isFile && temporary.extension.lowercase() in listOf("mp4", "mov") &&
                    roots.any { temporary.path.startsWith(it.canonicalPath + File.separator) }) {
                    "Only camera video files in this app cache directories can be discarded"
                }
                check(temporary.delete()) { "Temporary camera file could not be deleted" }
                result.success(true)
            }
            "video.import" -> importVideo(args,result)
            "video.record" -> {
                val host=activity ?: throw IllegalStateException("No active Activity")
                check(videoResult==null){"Camera already open"}
                videoResult=result
                try {host.startActivityForResult(Intent(MediaStore.ACTION_VIDEO_CAPTURE).putExtra(MediaStore.EXTRA_DURATION_LIMIT,60),8194)}catch(e:Exception){videoResult=null;throw e}
            }
            "video.list" -> result.success(listFiles("mp4") + listFiles("mov"))
            "video.delete" -> {check(file(args).delete());result.success(true)}
            "video.saveToPhotos" -> {
                val source=file(args)
                val values=ContentValues().apply{put(MediaStore.Video.Media.DISPLAY_NAME,source.name);put(MediaStore.Video.Media.MIME_TYPE,if(source.extension=="mov")"video/quicktime" else "video/mp4");if(Build.VERSION.SDK_INT>=29)put(MediaStore.Video.Media.RELATIVE_PATH,"Movies/JobsFlutter")}
                val uri=context.contentResolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,values) ?: throw IllegalStateException("MediaStore rejected video")
                context.contentResolver.openOutputStream(uri).use {out->requireNotNull(out);source.inputStream().use {it.copyTo(out)}}
                result.success(true)
            }
            "video.streamStart","video.streamStop" -> result.error("unsupported","JPEG streaming adapter currently requires iOS; Android video capture is available",null)
            else -> result.notImplemented()
        }
    }

    private fun importVideo(args: Map<*, *>, result: MethodChannel.Result) {
        val filter = args["filter"] as? String ?: "normal"
        if (filter != "normal") {
            result.error("unsupported_filter", "Core Image video filters require iOS; Android records the original video", null)
            return
        }
        Thread({
            var destination: File? = null
            try {
                val path = (args["path"] as? String).orEmpty()
                val source = if (path.isEmpty()) null else File(path).canonicalFile.also { candidate ->
                    val roots = listOfNotNull(context.filesDir, context.cacheDir, context.externalCacheDir, context.getExternalFilesDir(null))
                    require(candidate.isFile && roots.any { root -> candidate.path.startsWith(root.canonicalPath + File.separator) }) {
                        "Import source must be a camera file inside this app sandbox"
                    }
                }
                val extension = (args["extension"] as? String ?: source?.extension ?: "mp4").lowercase()
                require(extension in listOf("mp4", "mov")) { "Import requires an MP4 or MOV video" }
                val output = File(directory, "${UUID.randomUUID()}.$extension")
                destination = output
                if (source != null) source.copyTo(output, overwrite = false)
                else {
                    val bytes = args["bytes"] as? ByteArray
                    require(bytes != null && bytes.isNotEmpty()) { "Video bytes or a camera file path are required" }
                    output.writeBytes(bytes)
                }
                val metadata = android.media.MediaMetadataRetriever()
                val duration: Long
                try {
                    metadata.setDataSource(output.path)
                    val width = metadata.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
                    duration = metadata.extractMetadata(android.media.MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
                    check(width > 0 && duration > 0) { "Imported file has no valid video track" }
                } finally {
                    metadata.release()
                }
                val response = mapOf("name" to output.name, "path" to output.path, "duration" to duration / 1000.0, "bytes" to output.length(), "filter" to "normal")
                main.post { result.success(response) }
            } catch (failure: Exception) {
                destination?.delete()
                main.post { result.error("video_import", failure.message, null) }
            }
        }, "JobsVideoImport").start()
    }
    override fun onActivityResult(request:Int,resultCode:Int,data:Intent?):Boolean {
        if(request!=8194)return false
        val callback=videoResult;videoResult=null
        if(resultCode!=Activity.RESULT_OK){callback?.success(null);return true}
        try {
            val uri=data?.data ?: throw IllegalStateException("No captured video")
            val destination=File(directory,"${UUID.randomUUID()}.mp4")
            context.contentResolver.openInputStream(uri).use {input->requireNotNull(input);destination.outputStream().use {input.copyTo(it)}}
            callback?.success(mapOf("name" to destination.name))
        }catch(e:Exception){callback?.let {error(it,e)}}
        return true
    }
    private fun deviceInfo(value:BluetoothDevice):Map<String,Any?> = mapOf("id" to value.address,"name" to value.name,"rssi" to (rssis[value.address] ?: 0),"state" to if(connections.containsKey(value.address))2 else 0)
    private fun ble(method:String,args:Map<*, *>,result:MethodChannel.Result) {
        val adapter=bluetooth ?: throw IllegalStateException("Bluetooth hardware unavailable")
        val id=args["id"] as? String ?: ""
        when(method) {
            "state" -> result.success(mapOf("state" to adapter.state,"scanning" to (scanner!=null)))
            "scan" -> {
                check(adapter.isEnabled){"Bluetooth is disabled"}
                scanName=(args["name"] as? String ?: "").lowercase()
                scanDuplicates=args["duplicates"]==true
                scanSeen.clear()
                val token=++scanGeneration
                scanner?.stopScan(scanCallback);scanner=adapter.bluetoothLeScanner
                val services=(args["services"] as? List<*>)?.map {ScanFilter.Builder().setServiceUuid(ParcelUuid(UUID.fromString(it.toString()))).build()} ?: emptyList()
                scanner?.startScan(services,ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build(),scanCallback)
                val duration=(((args["seconds"] as? Number)?.toDouble() ?: 10.0).coerceIn(1.0,120.0)*1000).toLong()
                main.postDelayed({if(token==scanGeneration){scanner?.stopScan(scanCallback);scanner=null;emit("ble",mapOf("event" to "scanStopped"))}},duration)
                result.success(true)
            }
            "stopScan" -> {scanGeneration++;scanner?.stopScan(scanCallback);scanner=null;result.success(true)}
            "devices" -> result.success(devices.values.map(::deviceInfo))
            "connect" -> {
                val device=devices[id] ?: adapter.getRemoteDevice(id)
                if(connections[id]?.services?.isNotEmpty()==true){result.success(deviceInfo(device));return}
                check(!connectResults.containsKey(id)){"Connection already pending"}
                connectResults[id]=result
                if(args["autoReconnect"]==true)reconnect.add(id) else reconnect.remove(id)
                connections[id]=device.connectGatt(context,false,gattCallback,BluetoothDevice.TRANSPORT_LE)
                main.postDelayed({if(connectResults[id] === result){connectResults.remove(id);reconnect.remove(id);connections.remove(id)?.let{it.disconnect();it.close()};result.error("timeout","Connection timed out",null)}},12_000)
            }
            "disconnect" -> {reconnect.remove(id);connectResults.remove(id)?.error("cancelled","Disconnected by user",null);connections.remove(id)?.let {it.disconnect();it.close()};result.success(true)}
            else -> {
                val gatt=connections[id] ?: throw IllegalStateException("Peripheral disconnected")
                when(method) {
                    "discover" -> {check(!pending.containsKey("$id/discover"));pending["$id/discover"]=result;if(!gatt.discoverServices()){pending.remove("$id/discover");throw IllegalStateException("GATT discovery busy")};expire("$id/discover")}
                    "rssi" -> {result.success(gatt.readRemoteRssi())}
                    "mtu" -> result.success(mapOf("withResponse" to ((mtus[id] ?: 23)-3),"withoutResponse" to ((mtus[id] ?: 23)-3)))
                    "requestMtu" -> {check(!pending.containsKey("$id/mtu"));pending["$id/mtu"]=result;if(!gatt.requestMtu(((args["mtu"] as? Number)?.toInt() ?: 185).coerceIn(23,517))){pending.remove("$id/mtu");throw IllegalStateException("MTU request rejected")};expire("$id/mtu")}
                    else -> {
                        val service=args["service"]?.toString() ?: ""
                        val characteristic=args["characteristic"]?.toString() ?: ""
                        val value=gatt.getService(UUID.fromString(service))?.getCharacteristic(UUID.fromString(characteristic)) ?: throw IllegalArgumentException("Characteristic not discovered")
                        val key="$id/$service/$characteristic"
                        when(method) {
                            "read" -> {check(!pending.containsKey(key));pending[key]=result;if(!gatt.readCharacteristic(value)){pending.remove(key);throw IllegalStateException("GATT read busy")};expire(key)}
                            "write" -> {
                                val bytes=(args["bytes"] as? List<*>)?.map {(it as Number).toByte()}?.toByteArray() ?: byteArrayOf()
                                require(bytes.isNotEmpty()&&bytes.size<=(mtus[id] ?: 23)-3){"Split writes to negotiated ATT payload size"}
                                val response=args["response"]!=false
                                value.writeType=if(response)BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT else BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
                                value.value=bytes
                                if(response){check(!pending.containsKey(key));pending[key]=result;expire(key)}
                                if(!gatt.writeCharacteristic(value)){pending.remove(key);throw IllegalStateException("GATT write busy")}
                                if(!response)result.success(mapOf("written" to bytes.size))
                            }
                            "notify" -> {
                                val enabled=args["enabled"]!=false;gatt.setCharacteristicNotification(value,enabled)
                                val descriptor=value.getDescriptor(UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")) ?: throw IllegalStateException("Notify descriptor missing")
                                descriptor.value=if(enabled)BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE else BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE
                                result.success(gatt.writeDescriptor(descriptor))
                            }
                            "descriptorRead" -> {value.descriptors.firstOrNull()?.let {gatt.readDescriptor(it)};result.success(true)}
                            else -> result.notImplemented()
                        }
                    }
                }
            }
        }
    }
    private fun expire(key:String){val token=UUID.randomUUID();expiryTokens[key]=token;main.postDelayed({if(expiryTokens[key]==token){expiryTokens.remove(key);pending.remove(key)?.error("timeout","BLE operation timed out",null)}},8_000)}
    private val gattCallback=object:BluetoothGattCallback(){
        override fun onConnectionStateChange(gatt:BluetoothGatt,status:Int,newState:Int){main.post{
            val id=gatt.device.address
            if ((connections[id]!=null && connections[id]!==gatt) || (connections[id]==null && !reconnect.contains(id) && !connectResults.containsKey(id))) {
                gatt.close()
                return@post
            }
            if(newState==BluetoothProfile.STATE_CONNECTED){connections[id]=gatt;connectResults.remove(id)?.success(deviceInfo(gatt.device));emit("ble",mapOf("event" to "connected","device" to deviceInfo(gatt.device)))}
            else if(newState==BluetoothProfile.STATE_DISCONNECTED){connectResults.remove(id)?.error("connect","Disconnected: $status",null);connections.remove(id);emit("ble",mapOf("event" to "disconnected","id" to id));if(reconnect.contains(id))main.postDelayed({gatt.connect()},1000) else gatt.close()}
        }}
        override fun onMtuChanged(gatt:BluetoothGatt,mtu:Int,status:Int){main.post{if(status==0)mtus[gatt.device.address]=mtu;pending.remove(gatt.device.address+"/mtu")?.let{if(status==0)it.success(mapOf("mtu" to mtu,"payload" to mtu-3)) else it.error("mtu","GATT status $status",null)}}}
        override fun onServicesDiscovered(gatt:BluetoothGatt,status:Int){main.post{
            val values=gatt.services.map {s->mapOf("uuid" to s.uuid.toString(),"characteristics" to s.characteristics.map{c->mapOf("uuid" to c.uuid.toString(),"properties" to c.properties)})}
            pending.remove(gatt.device.address+"/discover")?.let {if(status==0)it.success(values) else it.error("discover","GATT status $status",null)}
        }}
        override fun onCharacteristicRead(gatt:BluetoothGatt,c:BluetoothGattCharacteristic,status:Int){value(gatt,c,status)}
        override fun onCharacteristicChanged(gatt:BluetoothGatt,c:BluetoothGattCharacteristic){value(gatt,c,0)}
        private fun value(gatt:BluetoothGatt,c:BluetoothGattCharacteristic,status:Int){main.post{
            val event=mapOf("event" to "value","id" to gatt.device.address,"service" to c.service.uuid.toString(),"characteristic" to c.uuid.toString(),"bytes" to (c.value ?: byteArrayOf()).map{it.toInt() and 255},"status" to status)
            pending.remove("${gatt.device.address}/${c.service.uuid}/${c.uuid}")?.let {if(status==0)it.success(event) else it.error("read","GATT status $status",null)}
            emit("ble",event)
        }}
        override fun onCharacteristicWrite(gatt:BluetoothGatt,c:BluetoothGattCharacteristic,status:Int){main.post{pending.remove("${gatt.device.address}/${c.service.uuid}/${c.uuid}")?.let{if(status==0)it.success(true) else it.error("write","GATT status $status",null)}}}
        override fun onReadRemoteRssi(gatt:BluetoothGatt,rssi:Int,status:Int){rssis[gatt.device.address]=rssi;emit("ble",mapOf("event" to "rssi","device" to deviceInfo(gatt.device)))}
        override fun onDescriptorRead(gatt:BluetoothGatt,d:BluetoothGattDescriptor,status:Int){emit("ble",mapOf("event" to "descriptor","uuid" to d.uuid.toString(),"bytes" to (d.value ?: byteArrayOf()).map{it.toInt() and 255},"status" to status))}
    }

    private fun pdf(method:String,args:Map<*, *>,result:MethodChannel.Result) {
        when(method) {
            "pdf.open" -> {
                val bytes=args["bytes"] as? ByteArray ?: throw IllegalArgumentException("PDF bytes required")
                pdf?.close();pdfDescriptor?.close()
                val file=File(context.cacheDir,"jobs-lab-document.pdf")
                file.writeBytes(bytes)
                val descriptor=ParcelFileDescriptor.open(file,ParcelFileDescriptor.MODE_READ_ONLY)
                pdfDescriptor=descriptor
                pdf=android.graphics.pdf.PdfRenderer(descriptor)
                result.success(mapOf("pages" to pdf!!.pageCount))
            }
            "pdf.page" -> {
                val renderer=pdf ?: throw IllegalStateException("No PDF open")
                val index=(args["index"] as? Number)?.toInt() ?: 0
                renderer.openPage(index).use {page->
                    val width=((args["width"] as? Number)?.toInt() ?: 1200).coerceIn(300,2400)
                    val bitmap=android.graphics.Bitmap.createBitmap(width,width*page.height/page.width,android.graphics.Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(android.graphics.Color.WHITE)
                    page.render(bitmap,null,null,android.graphics.pdf.PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    val output=java.io.ByteArrayOutputStream()
                    bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG,100,output)
                    bitmap.recycle()
                    result.success(output.toByteArray())
                }
            }
            "pdf.close" -> {pdf?.close();pdf=null;pdfDescriptor?.close();pdfDescriptor=null;result.success(true)}
            else -> result.notImplemented()
        }
    }
    private fun unity(method:String,args:Map<*, *>,result:MethodChannel.Result) {
        val type=try {Class.forName("com.unity3d.player.UnityPlayer")} catch(_:ClassNotFoundException){null}
        when(method) {
            "unity.status" -> result.success(mapOf("bundled" to (type!=null)))
            "unity.open" -> {
                check(type!=null){"Embed the generated Unity Android library first"}
                val host=activity ?: throw IllegalStateException("No active Activity")
                val unityActivity=Class.forName("com.unity3d.player.UnityPlayerActivity")
                host.startActivity(Intent(host,unityActivity))
                result.success(true)
            }
            "unity.message" -> {
                check(type!=null){"Unity runtime not bundled"}
                type.getMethod("UnitySendMessage",String::class.java,String::class.java,String::class.java)
                    .invoke(null,args["object"] as? String ?: "",args["method"] as? String ?: "",args["message"] as? String ?: "")
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
    private fun stopResources(){rtmp.stop();pdf?.close();pdfDescriptor?.close();sensors.unregisterListener(this);sensors.unregisterListener(shakeListener);stopAudio(false);player?.release();connections.values.forEach{try{it.disconnect();it.close()}catch(_:Exception){}};connections.clear();scanner?.let{try{it.stopScan(scanCallback)}catch(_:Exception){}}}
}

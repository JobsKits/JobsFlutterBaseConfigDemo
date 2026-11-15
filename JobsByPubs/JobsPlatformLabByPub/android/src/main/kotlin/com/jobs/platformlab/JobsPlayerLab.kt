package com.jobs.platformlab

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.TrafficStats
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Rational
import android.view.View
import android.view.WindowManager
import android.widget.MediaController
import android.widget.VideoView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File
import java.util.UUID

internal object JobsPlayerWindows {
    data class Session(
        val event: (Map<String, Any?>) -> Unit,
        val finish: (Int, Boolean) -> Unit
    )
    val sessions = mutableMapOf<String, Session>()
}

internal class JobsPlayerView(
    context: Context,
    private val identifier: Int,
    private val host: () -> Activity?,
    private val emit: (String, Map<String, Any?>) -> Unit,
    private val remove: () -> Unit
) : PlatformView {
    private val video = VideoView(context)
    private val main = Handler(Looper.getMainLooper())
    private var localFile: File? = null
    private var uri: Uri? = null
    private var autoplay = true
    private var disposed = false
    private var bufferPercent = 0
    private val receivedAtStart = TrafficStats.getUidRxBytes(context.applicationInfo.uid)
    private var windowToken: String? = null

    init {
        val controls = MediaController(context)
        controls.setAnchorView(video)
        video.setMediaController(controls)
        video.setOnPreparedListener { player ->
            player.setOnBufferingUpdateListener { _, percent -> bufferPercent = percent }
            if (autoplay) video.start()
            event(mapOf("event" to "ready"))
        }
        video.setOnErrorListener { _, what, extra ->
            event(mapOf("event" to "error", "error" to "MediaPlayer error $what/$extra"))
            true
        }
        video.setOnCompletionListener { event(mapOf("event" to "ended")) }
        progress()
    }

    override fun getView(): View = video

    fun command(args: Map<*, *>, result: MethodChannel.Result) {
        when (args["action"]) {
            "load" -> {
                val bytes = args["bytes"] as? ByteArray
                val source: Uri
                if (bytes != null && bytes.isNotEmpty()) {
                    val directory = File(video.context.cacheDir, "JobsPlayerLab").apply { mkdirs() }
                    val file = File(directory, "${UUID.randomUUID()}.mp4")
                    file.writeBytes(bytes)
                    localFile?.delete()
                    localFile = file
                    source = Uri.fromFile(file)
                } else if (args["path"] is String) {
                    val candidate = File(args["path"] as String).canonicalFile
                    val context = video.context
                    val roots = listOfNotNull(context.filesDir, context.cacheDir, context.externalCacheDir, context.getExternalFilesDir(null))
                    require(candidate.isFile && candidate.extension.lowercase() in listOf("mp4", "mov") &&
                        roots.any { candidate.path.startsWith(it.canonicalPath + File.separator) }) {
                        "Local player paths must point to a video inside this app sandbox"
                    }
                    source = Uri.fromFile(candidate)
                    localFile?.delete()
                    localFile = null
                } else {
                    source = Uri.parse(args["url"] as? String ?: "")
                    require(source.scheme in listOf("http", "https") && !source.host.isNullOrEmpty()) {
                        "Provide video bytes or a valid HTTP(S) URL"
                    }
                    localFile?.delete()
                    localFile = null
                }
                autoplay = args["autoplay"] != false
                uri = source
                video.setVideoURI(source)
                result.success(mapOf("loading" to true, "pipSupported" to supportsPip()))
            }
            "play" -> {
                check(uri != null) { "Load a video first" }
                video.start()
                result.success(true)
            }
            "pause" -> { video.pause(); result.success(true) }
            "seek" -> {
                val seconds = (args["seconds"] as? Number)?.toDouble() ?: -1.0
                require(seconds.isFinite() && seconds >= 0) { "Seek seconds must be finite and non-negative" }
                video.seekTo((seconds * 1000).toInt())
                result.success(true)
            }
            "fullScreen", "pip" -> {
                val host = host() ?: throw IllegalStateException("No active Activity")
                val source = uri ?: throw IllegalStateException("Load a video first")
                val pip = args["action"] == "pip"
                if (pip) check(supportsPip()) { "Picture-in-picture requires a supported Android 8+ device" }
                check(windowToken == null) { "Native player window is already open" }
                val token = UUID.randomUUID().toString()
                windowToken = token
                val wasPlaying = video.isPlaying
                JobsPlayerWindows.sessions[token] = JobsPlayerWindows.Session(::event) { position, playing ->
                    windowToken = null
                    if (!disposed) {
                        video.seekTo(position)
                        if (playing) video.start()
                    }
                }
                val launch = Intent(host, JobsPlayerActivity::class.java)
                    .putExtra("url", source.toString()).putExtra("position", video.currentPosition)
                    .putExtra("playing", wasPlaying).putExtra("pip", pip).putExtra("token", token)
                video.pause()
                try {
                    host.startActivity(launch)
                } catch (error: Exception) {
                    windowToken = null
                    JobsPlayerWindows.sessions.remove(token)
                    if (wasPlaying) video.start()
                    throw error
                }
                result.success(true)
            }
            "traffic" -> {
                val received = TrafficStats.getUidRxBytes(video.context.applicationInfo.uid)
                result.success(mapOf(
                    "appReceivedBytes" to if (received < 0 || receivedAtStart < 0) -1 else (received - receivedAtStart).coerceAtLeast(0),
                    "scope" to "app", "bufferPercent" to bufferPercent
                ))
            }
            else -> result.notImplemented()
        }
    }

    private fun supportsPip() = Build.VERSION.SDK_INT >= 26 &&
        video.context.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun event(data: Map<String, Any?>) {
        if (disposed) return
        emit("player", mapOf(
            "viewId" to identifier, "position" to video.currentPosition / 1000.0,
            "duration" to video.duration.coerceAtLeast(0) / 1000.0, "isPlaying" to video.isPlaying
        ) + data)
    }

    private fun progress() {
        if (disposed) return
        if (uri != null) event(mapOf("event" to "progress"))
        main.postDelayed(::progress, 1000)
    }

    override fun dispose() {
        disposed = true
        main.removeCallbacksAndMessages(null)
        windowToken?.let { JobsPlayerWindows.sessions.remove(it) }
        video.stopPlayback()
        localFile?.delete()
        remove()
    }
}

/** This Activity owns the real system full-screen/PiP window and decoder. */
class JobsPlayerActivity : Activity() {
    private lateinit var video: VideoView
    private var token = ""
    private var prepared = false

    override fun onCreate(state: Bundle?) {
        super.onCreate(state)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        token = intent.getStringExtra("token").orEmpty()
        video = VideoView(this)
        setContentView(video)
        val controls = MediaController(this)
        controls.setAnchorView(video)
        video.setMediaController(controls)
        video.setOnErrorListener { _, what, extra ->
            JobsPlayerWindows.sessions[token]?.event?.invoke(mapOf("event" to "error", "error" to "MediaPlayer error $what/$extra"))
            finish()
            true
        }
        video.setOnPreparedListener {
            prepared = true
            video.seekTo(intent.getIntExtra("position", 0))
            if (intent.getBooleanExtra("playing", true) || intent.getBooleanExtra("pip", false)) video.start()
            if (intent.getBooleanExtra("pip", false)) video.postDelayed({ enterPip() }, 150)
        }
        video.setVideoURI(Uri.parse(intent.getStringExtra("url")))
    }

    private fun enterPip() {
        if (Build.VERSION.SDK_INT >= 26 && !isFinishing && prepared) {
            try {
                check(enterPictureInPictureMode(PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9)).build())) {
                    "The system refused picture-in-picture"
                }
            } catch (error: Exception) {
                JobsPlayerWindows.sessions[token]?.event?.invoke(mapOf("event" to "error", "error" to error.message))
            }
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (video.isPlaying) enterPip()
    }

    override fun onPictureInPictureModeChanged(active: Boolean, configuration: Configuration) {
        super.onPictureInPictureModeChanged(active, configuration)
        JobsPlayerWindows.sessions[token]?.event?.invoke(mapOf("event" to if (active) "pipStarted" else "pipStopped"))
    }

    override fun onDestroy() {
        val position = if (prepared) video.currentPosition else intent.getIntExtra("position", 0)
        val playing = video.isPlaying
        video.stopPlayback()
        JobsPlayerWindows.sessions.remove(token)?.finish?.invoke(position, playing)
        super.onDestroy()
    }
}

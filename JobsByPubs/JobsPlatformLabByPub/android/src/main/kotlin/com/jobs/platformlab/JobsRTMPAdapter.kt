package com.jobs.platformlab

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.pedro.common.ConnectChecker
import com.pedro.library.rtmp.RtmpCamera2
import io.flutter.plugin.common.MethodChannel
import java.net.URI

internal class JobsRTMPAdapter(
    private val context: Context,
    private val emit: (String, Map<String, Any?>) -> Unit
) {
    private var camera: RtmpCamera2? = null
    private var pending: MethodChannel.Result? = null
    private var generation = 0
    private val main = Handler(Looper.getMainLooper())

    fun start(url: String, result: MethodChannel.Result) {
        val endpoint = URI(url)
        require(endpoint.scheme in listOf("rtmp", "rtmps") &&
            !endpoint.host.isNullOrEmpty() && endpoint.path.split('/').count { it.isNotEmpty() } >= 2) {
            "Enter a full rtmp(s)://host/app/stream-key URL"
        }
        check(camera == null) { "Stream is already running" }
        val token = ++generation
        val value = RtmpCamera2(context, Events(token))
        check(value.prepareAudio() && value.prepareVideo()) {
            "Camera or microphone encoder preparation failed"
        }
        camera = value
        pending = result
        try {
            value.startStream(url)
        } catch (error: Exception) {
            pending = null
            stop()
            throw error
        }
        main.postDelayed({
            if (token == generation && pending != null) {
                fail(token, "timeout", "RTMP connection timed out")
            }
        }, 20_000)
    }

    fun stop() {
        generation++
        val completion = pending
        pending = null
        val value = camera
        camera = null
        if (value?.isStreaming == true) value.stopStream()
        completion?.error("cancelled", "RTMP publishing cancelled", null)
    }

    private fun fail(token: Int, code: String, message: String) {
        if (token != generation) return
        val completion = pending
        pending = null
        // SDK error text can include the publishing URL, which contains the stream key.
        val description = message.replace(Regex("rtmps?://\\S+"), "[RTMP endpoint]")
        completion?.error(code, description, null)
        emit("video", mapOf("event" to "rtmpError", "error" to description))
        stop()
    }

    private inner class Events(private val token: Int) : ConnectChecker {
        private fun deliver(action: () -> Unit) {
            main.post { if (token == generation) action() }
        }

        override fun onConnectionStarted(url: String) = deliver {
            emit("video", mapOf("event" to "rtmpConnecting"))
        }

        override fun onConnectionSuccess() = deliver {
            pending?.success(true)
            pending = null
            emit("video", mapOf("event" to "rtmpPublishing", "audio" to true))
        }

        override fun onConnectionFailed(reason: String) = deliver {
            fail(token, "rtmp", reason)
        }

        override fun onDisconnect() = deliver {
            if (pending != null) {
                fail(token, "rtmp", "RTMP disconnected before publishing")
            } else {
                emit("video", mapOf("event" to "rtmpStopped"))
                stop()
            }
        }

        override fun onAuthError() = deliver {
            fail(token, "auth", "RTMP authentication failed")
        }

        override fun onAuthSuccess() = deliver {
            emit("video", mapOf("event" to "rtmpAuthenticated"))
        }

        override fun onNewBitrate(bitrate: Long) = deliver {
            emit("video", mapOf("event" to "bitrate", "bitsPerSecond" to bitrate))
        }
    }
}

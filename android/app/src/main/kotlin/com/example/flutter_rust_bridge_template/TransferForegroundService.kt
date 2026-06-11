package eu.heili.wormhole

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

class TransferForegroundService : Service() {
    private var foreground = false
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val appLabel = applicationInfo.loadLabel(packageManager).toString()
        val title = intent?.getStringExtra(EXTRA_TITLE) ?: appLabel
        val channel = intent?.getStringExtra(EXTRA_CHANNEL) ?: appLabel
        val status = intent?.getStringExtra(EXTRA_STATUS) ?: appLabel
        val progress = intent
            ?.takeIf { it.hasExtra(EXTRA_PROGRESS) }
            ?.getIntExtra(EXTRA_PROGRESS, 0)
        showNotification(title, channel, status, progress)
        acquireWakeLock()
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopTransfer()
        super.onTaskRemoved(rootIntent)
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        stopTransfer()
    }

    override fun onDestroy() {
        releaseWakeLock()
        removeNotification()
        super.onDestroy()
    }

    private fun showNotification(title: String, channel: String, status: String, progress: Int?) {
        createNotificationChannel(channel)
        val notification = buildNotification(title, status, progress)
        if (!foreground) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            foreground = true
        } else {
            getSystemService(NotificationManager::class.java)
                .notify(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(title: String, status: String, progress: Int?): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }
        val boundedProgress = progress?.coerceIn(0, PROGRESS_MAX)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }
            .setSmallIcon(android.R.drawable.stat_sys_upload)
            .setContentTitle(title)
            .setContentText(status)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setContentIntent(pendingIntent)

        if (boundedProgress == null) {
            builder.setProgress(0, 0, true)
        } else {
            builder.setProgress(PROGRESS_MAX, boundedProgress, false)
        }
        return builder.build()
    }

    private fun createNotificationChannel(name: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                name,
                NotificationManager.IMPORTANCE_LOW
            )
        )
    }

    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        wakeLock = (getSystemService(POWER_SERVICE) as PowerManager)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "$packageName:transfer")
            .apply {
                setReferenceCounted(false)
                acquire()
            }
    }

    private fun stopTransfer() {
        releaseWakeLock()
        removeNotification()
        stopSelf()
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
    }

    private fun removeNotification() {
        if (!foreground) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        foreground = false
    }

    companion object {
        private const val CHANNEL_ID = "wormhole_transfer"
        private const val NOTIFICATION_ID = 174
        private const val PROGRESS_MAX = 1000
        private const val EXTRA_TITLE = "title"
        private const val EXTRA_CHANNEL = "channel"
        private const val EXTRA_STATUS = "status"
        private const val EXTRA_PROGRESS = "progress"

        fun start(context: Context, title: String?, channel: String?, status: String?) {
            val intent = intent(context, title, channel, status, null)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun update(
            context: Context,
            title: String?,
            channel: String?,
            status: String?,
            progress: Int?
        ) {
            context.startService(intent(context, title, channel, status, progress))
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, TransferForegroundService::class.java))
        }

        private fun intent(
            context: Context,
            title: String?,
            channel: String?,
            status: String?,
            progress: Int?
        ): Intent {
            return Intent(context, TransferForegroundService::class.java).apply {
                title?.let { putExtra(EXTRA_TITLE, it) }
                channel?.let { putExtra(EXTRA_CHANNEL, it) }
                status?.let { putExtra(EXTRA_STATUS, it) }
                progress?.let { putExtra(EXTRA_PROGRESS, it) }
            }
        }
    }
}

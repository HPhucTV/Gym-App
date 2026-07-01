package com.example.myapplication.notification

import android.content.*
import com.example.myapplication.data.DataStoreSettingsRepository
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.first

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED) return
        val pending = goAsync(); val app = context.applicationContext
        CoroutineScope(SupervisorJob() + Dispatchers.IO).launch {
            try {
                val value = DataStoreSettingsRepository(app).settings.first()
                if (value.reminderEnabled) AlarmReminderScheduler(app).schedule(value.reminderHour, value.reminderMinute)
            } finally { pending.finish() }
        }
    }
}

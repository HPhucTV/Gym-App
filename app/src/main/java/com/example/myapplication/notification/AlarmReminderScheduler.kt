package com.example.myapplication.notification

import android.app.*
import android.content.*
import java.time.*

class AlarmReminderScheduler(context: Context) : ReminderScheduler {
    private val app = context.applicationContext
    private val alarm = app.getSystemService(AlarmManager::class.java)
    override fun schedule(hour: Int, minute: Int) {
        require(hour in 0..23 && minute in 0..59)
        val now = ZonedDateTime.now()
        var next = now.toLocalDate().atTime(hour, minute).atZone(now.zone)
        if (!next.isAfter(now)) next = next.plusDays(1)
        alarm.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next.toInstant().toEpochMilli(), intent())
    }
    override fun cancel() = alarm.cancel(intent())
    private fun intent() = PendingIntent.getBroadcast(app, 0, Intent(app, WorkoutReminderReceiver::class.java),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
}

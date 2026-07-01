package com.example.myapplication.notification

interface ReminderScheduler {
    fun schedule(hour: Int, minute: Int)
    fun cancel()
}

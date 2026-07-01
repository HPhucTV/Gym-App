package com.example.myapplication.data

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.example.myapplication.core.model.RestDayMode
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

val Context.dataStore by preferencesDataStore(name = "gym_settings")

data class Settings(
    val reminderEnabled: Boolean = false,
    val reminderHour: Int = 20,
    val reminderMinute: Int = 0,
    val restDayMode: RestDayMode? = null,
)

interface SettingsRepository {
    val settings: Flow<Settings>
    suspend fun setReminderEnabled(enabled: Boolean)
    suspend fun setReminderTime(hour: Int, minute: Int)
    suspend fun setRestDayMode(mode: RestDayMode?)
}

class DataStoreSettingsRepository(context: Context) : SettingsRepository {
    private val store = context.applicationContext.dataStore
    override val settings: Flow<Settings> = store.data.map { preferences ->
        Settings(
            reminderEnabled = preferences[ENABLED] ?: false,
            reminderHour = (preferences[HOUR] ?: 20).takeIf { it in 0..23 } ?: 20,
            reminderMinute = (preferences[MINUTE] ?: 0).takeIf { it in 0..59 } ?: 0,
            restDayMode = preferences[REST]?.let { stored -> RestDayMode.entries.firstOrNull { it.name == stored } },
        )
    }
    override suspend fun setReminderEnabled(enabled: Boolean) { store.edit { it[ENABLED] = enabled } }
    override suspend fun setReminderTime(hour: Int, minute: Int) {
        require(hour in 0..23 && minute in 0..59)
        store.edit { it[HOUR] = hour; it[MINUTE] = minute }
    }
    override suspend fun setRestDayMode(mode: RestDayMode?) {
        store.edit { if (mode == null) it.remove(REST) else it[REST] = mode.name }
    }
    private companion object {
        val ENABLED = booleanPreferencesKey("reminder_enabled")
        val HOUR = intPreferencesKey("reminder_hour")
        val MINUTE = intPreferencesKey("reminder_minute")
        val REST = stringPreferencesKey("rest_day_mode")
    }
}

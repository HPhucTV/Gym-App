package com.example.myapplication.feature.settings

import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class SettingsRouteTest {
    @Test fun `events invoke permission and replacement navigation exactly once`() = runTest {
        var permissionCalls = 0
        val replacements = mutableListOf<Boolean>()

        consumeSettingsEvents(
            events = flowOf(
                SettingsEvent.RequestNotificationPermission,
                SettingsEvent.GoToOnboarding(true),
            ),
            onRequestNotificationPermission = { permissionCalls++ },
            onNavigateToOnboarding = { replacements += it },
        )

        assertEquals(1, permissionCalls)
        assertEquals(listOf(true), replacements)
    }
}
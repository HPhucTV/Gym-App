package com.example.myapplication.feature.progress

import androidx.compose.ui.graphics.Color
import org.junit.Assert.assertTrue
import org.junit.Test

class CompletedDayContrastTest {
    @Test fun `completed day foreground meets WCAG AA contrast`() {
        val ratio = contrastRatio(CompletedDayContentColor, CompletedDayBackgroundColor)
        assertTrue("Expected contrast >= 4.5, was $ratio", ratio >= 4.5)
    }

    private fun contrastRatio(foreground: Color, background: Color): Double {
        val lighter = maxOf(luminance(foreground), luminance(background))
        val darker = minOf(luminance(foreground), luminance(background))
        return (lighter + 0.05) / (darker + 0.05)
    }

    private fun luminance(color: Color): Double =
        0.2126 * linear(color.red.toDouble()) +
            0.7152 * linear(color.green.toDouble()) +
            0.0722 * linear(color.blue.toDouble())

    private fun linear(channel: Double): Double =
        if (channel <= 0.04045) channel / 12.92 else Math.pow((channel + 0.055) / 1.055, 2.4)
}

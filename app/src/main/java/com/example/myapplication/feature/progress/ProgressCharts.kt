package com.example.myapplication.feature.progress

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.core.model.MuscleGroup
import com.example.myapplication.ui.theme.BorderGray
import com.example.myapplication.ui.theme.EnergyOrange
import com.example.myapplication.ui.theme.SuccessGreen
import com.example.myapplication.ui.theme.customColors
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.material3.TextButton
import androidx.compose.material3.ButtonDefaults
import androidx.compose.foundation.clickable
import com.example.myapplication.data.local.WeightMeasurementEntity

@Composable
fun ProgressChartsSection(
    weeklyStats: List<WeeklyCompletedStats>,
    targetPerWeek: Int,
    muscleStats: List<MuscleCompletedStats>,
) {
    Column(
        verticalArrangement = Arrangement.spacedBy(18.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        if (weeklyStats.isNotEmpty()) {
            WeeklyCompletionChartCard(weeklyStats, targetPerWeek)
        }
        if (muscleStats.isNotEmpty()) {
            MuscleFocusStatsCard(muscleStats)
        }
    }
}

@Composable
private fun WeeklyCompletionChartCard(
    weeklyStats: List<WeeklyCompletedStats>,
    targetPerWeek: Int,
) {
    val colors = MaterialTheme.colorScheme
    val customColors = colors.customColors

    Surface(
        color = colors.surfaceVariant,
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(
                "Tần suất tập luyện hàng tuần",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = customColors.primaryText
            )
            Spacer(Modifier.height(16.dp))

            // Canvas Bar Chart
            val maxCount = maxOf(4, weeklyStats.maxOfOrNull { it.count } ?: 0, targetPerWeek)
            val gridColor = colors.outline

            Canvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(160.dp)
            ) {
                val width = size.width
                val height = size.height

                // Draw Grid Lines (horizontal lines at 0, target, max)
                val targetY = height - (targetPerWeek.toFloat() / maxCount) * height
                val pathEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 10f), 0f)

                // Target Line
                drawLine(
                    color = EnergyOrange,
                    start = Offset(0f, targetY),
                    end = Offset(width, targetY),
                    strokeWidth = 2.dp.toPx(),
                    pathEffect = pathEffect
                )

                // Draw bars
                val barCount = weeklyStats.size
                val spaceBetween = width / (barCount * 2 + 1)
                val barWidth = spaceBetween

                weeklyStats.forEachIndexed { index, stat ->
                    val barHeight = (stat.count.toFloat() / maxCount) * height
                    val left = spaceBetween + index * (barWidth + spaceBetween)
                    val top = height - barHeight

                    // Determine bar color (SuccessGreen if weekly target met)
                    val barColor = if (stat.count >= targetPerWeek) SuccessGreen else EnergyOrange.copy(alpha = 0.8f)

                    drawRoundRect(
                        color = barColor,
                        topLeft = Offset(left, top),
                        size = Size(barWidth, barHeight),
                        cornerRadius = CornerRadius(8.dp.toPx(), 8.dp.toPx())
                    )
                }
            }

            Spacer(Modifier.height(8.dp))

            // Labels Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                weeklyStats.forEach { stat ->
                    Text(
                        stat.weekLabel,
                        fontSize = 11.sp,
                        color = customColors.mutedText,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.weight(1f),
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }

            Spacer(Modifier.height(12.dp))
            // Target legend indicator
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .size(16.dp, 3.dp)
                        .background(EnergyOrange)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    "Mục tiêu hàng tuần ($targetPerWeek buổi)",
                    style = MaterialTheme.typography.bodySmall,
                    color = customColors.mutedText
                )
            }
        }
    }
}

@Composable
private fun MuscleFocusStatsCard(
    muscleStats: List<MuscleCompletedStats>,
) {
    val colors = MaterialTheme.colorScheme
    val customColors = colors.customColors

    Surface(
        color = colors.surfaceVariant,
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(
                "Nhóm cơ tác động nhiều nhất",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = customColors.primaryText
            )
            Spacer(Modifier.height(14.dp))

            val maxCount = muscleStats.maxOfOrNull { it.count } ?: 1
            // Take top 5 muscle groups to avoid cluttering screen
            val topMuscles = muscleStats.take(5)

            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                topMuscles.forEach { stat ->
                    val muscleName = muscleLabelVi(stat.muscleGroup)
                    val progressFraction = stat.count.toFloat() / maxCount

                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            horizontalArrangement = Arrangement.SpaceBetween,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                "${muscleEmoji(stat.muscleGroup)} $muscleName",
                                color = customColors.primaryText,
                                fontWeight = FontWeight.SemiBold,
                                style = MaterialTheme.typography.bodyMedium
                            )
                            Text(
                                "${stat.count} hiệp",
                                color = customColors.mutedText,
                                style = MaterialTheme.typography.bodySmall
                            )
                        }
                        Spacer(Modifier.height(4.dp))
                        LinearProgressIndicator(
                            progress = { progressFraction },
                            color = EnergyOrange,
                            trackColor = colors.outline,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(8.dp)
                                .clip(RoundedCornerShape(4.dp))
                        )
                    }
                }
            }
        }
    }
}

private fun muscleLabelVi(muscle: MuscleGroup): String = when (muscle) {
    MuscleGroup.CHEST -> "Ngực"
    MuscleGroup.BACK -> "Lưng"
    MuscleGroup.SHOULDERS -> "Vai"
    MuscleGroup.BICEPS -> "Tay trước"
    MuscleGroup.TRICEPS -> "Tay sau"
    MuscleGroup.CORE -> "Cơ bụng"
    MuscleGroup.QUADS -> "Đùi trước"
    MuscleGroup.HAMSTRINGS -> "Đùi sau"
    MuscleGroup.GLUTES -> "Cơ mông"
    MuscleGroup.CALVES -> "Bắp chân"
    MuscleGroup.FULL_BODY -> "Toàn thân"
    MuscleGroup.CARDIO -> "Tim mạch"
    MuscleGroup.MOBILITY -> "Di động"
}

private fun muscleEmoji(muscle: MuscleGroup): String = when (muscle) {
    MuscleGroup.CHEST -> "🫁"
    MuscleGroup.BACK -> "🔙"
    MuscleGroup.SHOULDERS -> "💪"
    MuscleGroup.BICEPS -> "💪"
    MuscleGroup.TRICEPS -> "💪"
    MuscleGroup.CORE -> "🎯"
    MuscleGroup.QUADS -> "🦵"
    MuscleGroup.HAMSTRINGS -> "🦵"
    MuscleGroup.GLUTES -> "🍑"
    MuscleGroup.CALVES -> "🦶"
    MuscleGroup.FULL_BODY -> "🏋️"
    MuscleGroup.CARDIO -> "❤️"
    MuscleGroup.MOBILITY -> "🧘"
}

@Composable
fun WeightHistoryChartCard(
    weightHistory: List<WeightMeasurementEntity>,
    currentFilter: WeightFilter,
    onFilterSelected: (WeightFilter) -> Unit,
) {
    val colors = MaterialTheme.colorScheme
    val customColors = colors.customColors

    Surface(
        color = colors.surfaceVariant,
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    "Xu hướng cân nặng ⚖️",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = customColors.primaryText
                )

                // Weight Filter Selector (7, 30, 90 days)
                Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    WeightFilter.values().forEach { filter ->
                        val active = filter == currentFilter
                        Text(
                            text = when (filter) {
                                WeightFilter.LAST_7_DAYS -> "7N"
                                WeightFilter.LAST_30_DAYS -> "30N"
                                WeightFilter.LAST_90_DAYS -> "90N"
                            },
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (active) Color.White else customColors.mutedText,
                            modifier = Modifier
                                .background(
                                    color = if (active) EnergyOrange else Color.Transparent,
                                    shape = RoundedCornerShape(8.dp)
                                )
                                .clickable { onFilterSelected(filter) }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        )
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            val sortedWeights = weightHistory.sortedBy { it.epochDay }

            if (sortedWeights.size < 2) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (sortedWeights.isEmpty()) {
                            "Hãy ghi nhận cân nặng trong phần Hồ sơ\nhoặc Check-in hàng tuần."
                        } else {
                            "Đã ghi nhận ${sortedWeights.first().weightKg} kg.\nCần ít nhất 2 ngày đo khác nhau để vẽ biểu đồ."
                        },
                        style = MaterialTheme.typography.bodyMedium,
                        color = customColors.mutedText,
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            } else {
                val minWeight = sortedWeights.minOf { it.weightKg }
                val maxWeight = sortedWeights.maxOf { it.weightKg }
                val weightRange = maxWeight - minWeight
                val yMin = minWeight - maxOf(1.0, weightRange * 0.1)
                val yMax = maxWeight + maxOf(1.0, weightRange * 0.1)
                val yRange = (yMax - yMin).coerceAtLeast(0.1)

                val minDay = sortedWeights.first().epochDay
                val maxDay = sortedWeights.last().epochDay
                val dayRange = (maxDay - minDay).coerceAtLeast(1)

                Canvas(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                ) {
                    val width = size.width
                    val height = size.height
                    val paddingX = 40.dp.toPx()
                    val paddingY = 20.dp.toPx()
                    val chartWidth = width - paddingX * 2
                    val chartHeight = height - paddingY * 2

                    val points = sortedWeights.map { measurement ->
                        val xFraction = if (dayRange == 0L) 0.5f else (measurement.epochDay - minDay).toFloat() / dayRange
                        val yFraction = (measurement.weightKg - yMin).toFloat() / yRange
                        val x = paddingX + xFraction * chartWidth
                        val y = paddingY + (1f - yFraction.toFloat()) * chartHeight
                        Offset(x, y)
                    }

                    // 1. Draw Grid Lines (yMin, average, yMax)
                    val gridColor = colors.outline.copy(alpha = 0.3f)
                    val dashPathEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 10f), 0f)

                    // Average line
                    val avgWeight = sortedWeights.map { it.weightKg }.average()
                    val avgYFraction = (avgWeight - yMin).toFloat() / yRange
                    val avgY = paddingY + (1f - avgYFraction.toFloat()) * chartHeight
                    drawLine(
                        color = gridColor,
                        start = Offset(paddingX, avgY),
                        end = Offset(width - paddingX, avgY),
                        strokeWidth = 1.dp.toPx(),
                        pathEffect = dashPathEffect
                    )

                    // Draw the connection lines
                    for (i in 0 until points.size - 1) {
                        drawLine(
                            color = EnergyOrange,
                            start = points[i],
                            end = points[i + 1],
                            strokeWidth = 3.dp.toPx()
                        )
                    }

                    // Draw dots and text labels
                    val textColor = customColors.primaryText.toArgb()
                    val dateColor = customColors.mutedText.toArgb()

                    val labelPaint = android.graphics.Paint().apply {
                        color = textColor
                        textSize = 9.sp.toPx()
                        textAlign = android.graphics.Paint.Align.CENTER
                        typeface = android.graphics.Typeface.DEFAULT_BOLD
                    }

                    val datePaint = android.graphics.Paint().apply {
                        color = dateColor
                        textSize = 8.sp.toPx()
                        textAlign = android.graphics.Paint.Align.CENTER
                    }

                    val dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd/MM")

                    points.forEachIndexed { index, offset ->
                        val measurement = sortedWeights[index]

                        // Draw Circle dot
                        drawCircle(
                            color = EnergyOrange,
                            radius = 5.dp.toPx(),
                            center = offset
                        )
                        drawCircle(
                            color = Color.White,
                            radius = 2.dp.toPx(),
                            center = offset
                        )

                        // Draw Weight Text (above dot)
                        drawContext.canvas.nativeCanvas.drawText(
                            "%.1f".format(measurement.weightKg),
                            offset.x,
                            offset.y - 8.dp.toPx(),
                            labelPaint
                        )

                        // Draw Date Text (below dot)
                        val dateStr = java.time.LocalDate.ofEpochDay(measurement.epochDay).format(dateFormatter)
                        drawContext.canvas.nativeCanvas.drawText(
                            dateStr,
                            offset.x,
                            offset.y + 18.dp.toPx(),
                            datePaint
                        )
                    }
                }
            }
        }
    }
}

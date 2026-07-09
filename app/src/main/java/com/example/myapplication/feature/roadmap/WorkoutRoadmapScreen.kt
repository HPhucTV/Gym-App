package com.example.myapplication.feature.roadmap

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.myapplication.ui.theme.EnergyOrange
import com.example.myapplication.ui.theme.SuccessGreen
import com.example.myapplication.ui.theme.customColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WorkoutRoadmapScreen(
    state: RoadmapUiState,
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val colors = MaterialTheme.colorScheme
    val customColors = colors.customColors

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Lộ trình bài tập", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack, modifier = Modifier.testTag("roadmap-back-button")) {
                        Text("←", fontSize = 24.sp, color = customColors.primaryText, fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = colors.background,
                    titleContentColor = customColors.primaryText,
                    navigationIconContentColor = customColors.primaryText,
                )
            )
        },
        modifier = modifier.fillMaxSize()
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(colors.background)
                .padding(paddingValues)
        ) {
            when (state) {
                RoadmapUiState.Loading -> Box(
                    modifier = Modifier.fillMaxSize().testTag("roadmap-loading"),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = EnergyOrange)
                }
                is RoadmapUiState.Error -> Box(
                    modifier = Modifier.fillMaxSize().padding(24.dp).testTag("roadmap-error"),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        state.message,
                        color = colors.error,
                        style = MaterialTheme.typography.bodyLarge,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                is RoadmapUiState.Success -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 20.dp)
                    ) {
                        // Program name header card
                        Surface(
                            color = colors.surfaceVariant,
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 12.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Text(
                                    "Chương trình tập luyện",
                                    style = MaterialTheme.typography.labelMedium,
                                    color = EnergyOrange,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    state.programName,
                                    style = MaterialTheme.typography.titleMedium,
                                    color = customColors.primaryText,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }

                        // Sessions Timeline list
                        LazyColumn(
                            modifier = Modifier
                                .fillMaxWidth()
                                .weight(1f)
                                .testTag("roadmap-list"),
                            verticalArrangement = Arrangement.spacedBy(0.dp),
                            contentPadding = PaddingValues(bottom = 24.dp)
                        ) {
                            itemsIndexed(state.sessions) { index, session ->
                                val isLast = index == state.sessions.lastIndex
                                RoadmapItem(session = session, isLast = isLast, customColors = customColors, colors = colors)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun RoadmapItem(
    session: RoadmapSessionUi,
    isLast: Boolean,
    customColors: com.example.myapplication.ui.theme.GymCustomColors,
    colors: ColorScheme,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min) // Để đường dọc nối liền
    ) {
        // Cột hiển thị Timeline node
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.width(48.dp)
        ) {
            // Node circle
            Box(
                modifier = Modifier
                    .size(28.dp)
                    .clip(CircleShape)
                    .background(
                        when (session.status) {
                            RoadmapSessionStatus.COMPLETED -> SuccessGreen
                            RoadmapSessionStatus.ACTIVE -> colors.background
                            RoadmapSessionStatus.LOCKED -> colors.surfaceVariant
                        }
                    )
                    .border(
                        width = when (session.status) {
                            RoadmapSessionStatus.ACTIVE -> 3.dp
                            else -> 0.dp
                        },
                        color = when (session.status) {
                            RoadmapSessionStatus.ACTIVE -> EnergyOrange
                            else -> Color.Transparent
                        },
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                when (session.status) {
                    RoadmapSessionStatus.COMPLETED -> {
                        Text("✓", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                    }
                    RoadmapSessionStatus.ACTIVE -> {
                        Box(
                            modifier = Modifier
                                .size(10.dp)
                                .clip(CircleShape)
                                .background(EnergyOrange)
                        )
                    }
                    RoadmapSessionStatus.LOCKED -> {
                        Text("🔒", fontSize = 10.sp)
                    }
                }
            }

            // Line linking nodes
            if (!isLast) {
                Box(
                    modifier = Modifier
                        .fillMaxHeight()
                        .width(2.dp)
                        .background(
                            if (session.status == RoadmapSessionStatus.COMPLETED) SuccessGreen.copy(alpha = 0.5f)
                            else colors.surfaceVariant
                        )
                )
            }
        }

        Spacer(modifier = Modifier.width(12.dp))

        // Chi tiết buổi tập card
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(bottom = 20.dp)
        ) {
            Surface(
                color = when (session.status) {
                    RoadmapSessionStatus.ACTIVE -> colors.surfaceVariant
                    else -> colors.surface
                },
                shape = RoundedCornerShape(12.dp),
                border = if (session.status == RoadmapSessionStatus.ACTIVE) {
                    BorderStroke(1.dp, EnergyOrange.copy(alpha = 0.5f))
                } else null,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(14.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            "Tuần ${session.week} - Buổi ${session.sessionInWeek}",
                            style = MaterialTheme.typography.labelSmall,
                            color = if (session.status == RoadmapSessionStatus.LOCKED) customColors.mutedText else EnergyOrange,
                            fontWeight = FontWeight.Bold
                        )
                        if (session.status == RoadmapSessionStatus.ACTIVE) {
                            Surface(
                                color = EnergyOrange.copy(alpha = 0.15f),
                                shape = RoundedCornerShape(4.dp)
                            ) {
                                Text(
                                    "Đang tập",
                                    color = EnergyOrange,
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                )
                            }
                        }
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        session.titleVi,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = if (session.status == RoadmapSessionStatus.LOCKED) customColors.mutedText else customColors.primaryText,
                        textDecoration = if (session.status == RoadmapSessionStatus.COMPLETED) TextDecoration.LineThrough else TextDecoration.None
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        "Trọng tâm: ${session.focusVi}",
                        style = MaterialTheme.typography.bodySmall,
                        color = customColors.mutedText
                    )
                    Text(
                        "Thời lượng: ~${session.estimatedMinutes} phút",
                        style = MaterialTheme.typography.bodySmall,
                        color = customColors.mutedText
                    )
                }
            }
        }
    }
}

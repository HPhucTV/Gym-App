package com.example.myapplication.core.ui

import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.webkit.WebViewAssetLoader
import com.example.myapplication.ui.theme.EnergyOrange

@Composable
fun Exercise3DDialog(
    exerciseId: String,
    exerciseName: String,
    instructions: List<String>,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val colors = MaterialTheme.colorScheme
    val isDark = !colors.isLight() // check if dark theme is active to apply correct styling or text color
    val textColor = if (isDark) Color(0xFFF3F4F6) else Color(0xFF14213D)
    val backgroundColor = if (isDark) Color(0xFF1E293B) else Color(0xFFFFFFFF)
    val cardColor = if (isDark) Color(0xFF334155) else Color(0xFFF3F4F6)

    // Ánh xạ thủ công chính xác 100% toàn bộ 65 ID bài tập sang tệp mô hình .glb tương ứng
    val modelName = remember(exerciseId) { get3DModelName(exerciseId) }

    // Kiểm tra xem tệp mô hình 3D thực tế có tồn tại trong thư mục assets/3d hay không
    val assetExists = remember(exerciseId, modelName) {
        if (modelName != null) {
            runCatching {
                context.assets.open("3d/$modelName").use { }
                true
            }.getOrDefault(false)
        } else {
            false
        }
    }

    val assetLoader = remember(context) {
        WebViewAssetLoader.Builder()
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(context))
            .build()
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(usePlatformDefaultWidth = false)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .fillMaxHeight(0.85f)
                .clip(RoundedCornerShape(24.dp))
                .testTag("exercise-3d-dialog"),
            color = backgroundColor
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(20.dp)
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = exerciseName,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = textColor
                        )
                        Text(
                            text = "Mô hình 3D trực quan 🔄",
                            fontSize = 12.sp,
                            color = EnergyOrange,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    IconButton(
                        onClick = onDismiss,
                        modifier = Modifier.testTag("exercise-3d-close")
                    ) {
                        Text("✕", fontSize = 18.sp, color = textColor.copy(alpha = 0.6f))
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // 3D Viewer Area
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .clip(RoundedCornerShape(16.dp))
                        .background(cardColor),
                    contentAlignment = Alignment.Center
                ) {
                    if (modelName != null && assetExists) {
                        AndroidView(
                            factory = { ctx ->
                                WebView(ctx).apply {
                                    settings.javaScriptEnabled = true
                                    settings.domStorageEnabled = true
                                    settings.allowFileAccess = true
                                    settings.allowContentAccess = true
                                    
                                    // Bật nền trong suốt và chế độ dựng hình phần cứng (Hardware Acceleration) cho WebGL
                                    setBackgroundColor(android.graphics.Color.TRANSPARENT)
                                    setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null)
                                    
                                    // Bật gỡ lỗi WebView qua Chrome DevTools trên máy tính
                                    WebView.setWebContentsDebuggingEnabled(true)
                                    
                                    webViewClient = object : android.webkit.WebViewClient() {
                                        override fun shouldInterceptRequest(
                                            view: WebView,
                                            request: android.webkit.WebResourceRequest
                                        ): android.webkit.WebResourceResponse? {
                                            val response = assetLoader.shouldInterceptRequest(request.url)
                                            if (response != null) {
                                                val path = request.url.path
                                                if (path != null) {
                                                    if (path.endsWith(".glb")) {
                                                        response.mimeType = "model/gltf-binary"
                                                    } else if (path.endsWith(".js")) {
                                                        response.mimeType = "application/javascript"
                                                    } else if (path.endsWith(".html")) {
                                                        response.mimeType = "text/html"
                                                    }
                                                }
                                                
                                                // Thêm các CORS header để chắc chắn Fetch API trong WebView không bị chặn
                                                val headers = response.responseHeaders?.toMutableMap() ?: mutableMapOf()
                                                headers["Access-Control-Allow-Origin"] = "*"
                                                headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
                                                headers["Access-Control-Allow-Headers"] = "*"
                                                response.responseHeaders = headers
                                                
                                                android.util.Log.d("GymApp3D", "Intercepted asset: ${request.url} as ${response.mimeType}")
                                            } else {
                                                android.util.Log.d("GymApp3D", "Failed to intercept request: ${request.url}")
                                            }
                                            return response
                                        }
                                    }
                                    
                                    // Chuyển tiếp các log của Javascript (console.log, console.error) vào Android Logcat
                                    webChromeClient = object : android.webkit.WebChromeClient() {
                                        override fun onConsoleMessage(consoleMessage: android.webkit.ConsoleMessage?): Boolean {
                                            if (consoleMessage != null) {
                                                android.util.Log.d(
                                                    "GymApp3DConsole",
                                                    "${consoleMessage.message()} -- dòng ${consoleMessage.lineNumber()} của ${consoleMessage.sourceId()}"
                                                )
                                            }
                                            return true
                                        }
                                    }
                                    
                                    // Tải thông qua domain ảo để thỏa mãn chính sách Same-Origin cho Fetch API của model-viewer
                                    loadUrl("https://appassets.androidplatform.net/assets/3d/model_viewer.html?model=$modelName")
                                }
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    } else {
                        // Trình hiển thị giao diện fallback thân thiện khi chưa có mô hình 3D cho động tác này
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center,
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(24.dp)
                        ) {
                            Text(
                                text = "🏃‍♂️",
                                fontSize = 48.sp,
                                modifier = Modifier.padding(bottom = 12.dp)
                            )
                            Text(
                                text = "Mô hình 3D đang được cập nhật",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = textColor,
                                textAlign = TextAlign.Center
                            )
                            Text(
                                text = "Chúng tôi đang xây dựng mô hình chuyển động chuẩn cho bài tập này. Vui lòng tham khảo hướng dẫn chi tiết bên dưới.",
                                fontSize = 12.sp,
                                color = textColor.copy(alpha = 0.6f),
                                textAlign = TextAlign.Center,
                                modifier = Modifier.padding(top = 6.dp)
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Instructions Area
                Text(
                    text = "Hướng dẫn thực hiện:",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = textColor,
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(120.dp)
                        .verticalScroll(rememberScrollState())
                        .background(cardColor, RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    instructions.forEachIndexed { index, step ->
                        Row {
                            Text(
                                text = "${index + 1}.",
                                color = EnergyOrange,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.width(20.dp)
                            )
                            Text(
                                text = step,
                                color = textColor,
                                fontSize = 13.sp
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Close button
                Button(
                    onClick = onDismiss,
                    colors = ButtonDefaults.buttonColors(containerColor = EnergyOrange),
                    shape = RoundedCornerShape(14.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                ) {
                    Text(
                        text = "Đã hiểu",
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        fontSize = 15.sp
                    )
                }
            }
        }
    }
}

// Hàm kiểm tra chế độ Light/Dark của MaterialTheme colorScheme
private fun ColorScheme.isLight(): Boolean {
    // Độ sáng tương đối của màu nền (background)
    val red = this.background.red
    val green = this.background.green
    val blue = this.background.blue
    val luminance = 0.2126f * red + 0.7152f * green + 0.0722f * blue
    return luminance > 0.5f
}

// Ánh xạ thủ công chính xác 100% tất cả 65 ID bài tập sang tệp mô hình 3D tương ứng.
// Chỉ trả về tên tệp nếu ta đã có mô hình chuyển động thực tế khớp 100% với bài tập.
// Nếu chưa có, trả về null để hiển thị màn hình fallback "Đang cập nhật" sang trọng,
// tránh hiển thị sai động tác gây bối rối cho người dùng (ví dụ: hiển thị người chạy bộ cho Squat/Pushup).
private fun get3DModelName(exerciseId: String): String? = when (exerciseId) {
    // TIM MẠCH / CARDIO (Khớp 100% với tệp hoạt cảnh đi bộ/chạy bộ thực tế)
    "brisk_walk", "treadmill_walk" -> "walk_3d.glb"
    "treadmill_run", "high_knees" -> "run_3d.glb"
    
    else -> null
}

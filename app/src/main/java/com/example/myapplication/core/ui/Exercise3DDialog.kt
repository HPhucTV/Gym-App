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

    // Dùng trực tiếp ID bài tập để làm tham số nạp hoạt cảnh stick-figure tương ứng
    val modelName = exerciseId

    // Kiểm tra xem trình hiển thị HTML có tồn tại trong assets hay không (luôn có)
    val assetExists = remember(context) {
        runCatching {
            context.assets.open("3d/model_viewer.html").use { }
            true
        }.getOrDefault(false)
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
                    if (assetExists) {
                        AndroidView(
                            factory = { ctx ->
                                WebView(ctx).apply {
                                    layoutParams = android.view.ViewGroup.LayoutParams(
                                        android.view.ViewGroup.LayoutParams.MATCH_PARENT,
                                        android.view.ViewGroup.LayoutParams.MATCH_PARENT
                                    )

                                    settings.javaScriptEnabled = true
                                    settings.domStorageEnabled = true
                                    settings.allowFileAccess = true
                                    settings.allowContentAccess = true
                                    @Suppress("DEPRECATION")
                                    settings.allowFileAccessFromFileURLs = true
                                    @Suppress("DEPRECATION")
                                    settings.allowUniversalAccessFromFileURLs = true
                                    
                                    // Bật nền trong suốt và chuyển sang chế độ dựng hình phần mềm (Software Layer Type)
                                    // Chế độ SOFTWARE giải quyết triệt để lỗi không hiển thị/không compositing WebView trong hộp thoại Dialog phụ trên một số thiết bị
                                    setBackgroundColor(android.graphics.Color.TRANSPARENT)
                                    setLayerType(android.view.View.LAYER_TYPE_SOFTWARE, null)
                                    
                                    // Bật gỡ lỗi WebView qua Chrome DevTools trên máy tính
                                    WebView.setWebContentsDebuggingEnabled(true)
                                    
                                    // Sử dụng WebViewClient tùy biến để inject ID bài tập sau khi trang tải xong
                                    // Tránh việc truyền tham số qua URL (?model=...) vì giao thức file:/// của một số thiết bị có thể chặn hoặc làm sai lệch đường dẫn
                                    webViewClient = object : android.webkit.WebViewClient() {
                                        override fun onPageFinished(view: WebView?, url: String?) {
                                            super.onPageFinished(view, url)
                                            android.util.Log.d("GymApp3D", "onPageFinished: $url")
                                            view?.evaluateJavascript(
                                                "if (window.initExercise) { window.initExercise('$modelName'); } else { console.error('initExercise function not found'); }", 
                                                null
                                            )
                                        }

                                        override fun onReceivedError(
                                            view: WebView?,
                                            errorCode: Int,
                                            description: String?,
                                            failingUrl: String?
                                        ) {
                                            android.util.Log.e("GymApp3D", "Error ($errorCode): $description for $failingUrl")
                                        }

                                        @androidx.annotation.RequiresApi(android.os.Build.VERSION_CODES.M)
                                        override fun onReceivedError(
                                            view: WebView?,
                                            request: android.webkit.WebResourceRequest?,
                                            error: android.webkit.WebResourceError?
                                        ) {
                                            android.util.Log.e("GymApp3D", "Error: ${error?.description} for ${request?.url}")
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
                                    
                                    // Tải tệp HTML sạch không kèm query params
                                    loadUrl("file:///android_asset/3d/model_viewer.html")
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

// Ánh xạ ID bài tập sang tên để đồng bộ cấu trúc code cũ. Vì dùng Canvas 2D, ta trả về trực tiếp exerciseId.
private fun get3DModelName(exerciseId: String): String = exerciseId

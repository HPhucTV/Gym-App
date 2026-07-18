import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme/colors.dart';

class Exercise3DDialog extends StatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final List<String> instructions;
  final VoidCallback onDismiss;

  const Exercise3DDialog({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.instructions,
    required this.onDismiss,
  });

  @override
  State<Exercise3DDialog> createState() => _Exercise3DDialogState();
}

class _Exercise3DDialogState extends State<Exercise3DDialog> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isHtmlLoaded = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _injectExerciseId();
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView error: ${error.description}");
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      );
    _loadHtmlAsset();
  }

  Future<void> _loadHtmlAsset() async {
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      String html = await rootBundle.loadString('assets/3d/model_viewer.html');
      String js =
          await rootBundle.loadString('assets/3d/exercise_animations.js');

      // Inline the JS content to avoid relative path errors in WebView across platforms
      html = html.replaceFirst(
        '<script src="exercise_animations.js" onerror="showError(\'Không thể nạp tệp exercise_animations.js\')"></script>',
        '<script>$js</script>',
      );

      // Dynamically inject the theme state (isDarkTheme)
      html = html.replaceFirst(
        "const isDarkTheme = urlParams.get('theme') === 'dark' || true;",
        "const isDarkTheme = $isDark;",
      );

      await _webViewController.loadHtmlString(html);
      if (mounted) {
        setState(() {
          _isHtmlLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading HTML or JS assets: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _injectExerciseId() {
    final modelName = widget.exerciseId;
    _webViewController.runJavaScript(
        "if (window.initExercise) { window.initExercise('$modelName'); } else { console.error('initExercise function not found'); }");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? const Color(0xFFF3F4F6) : const Color(0xFF14213D);
    final backgroundColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 24.dp),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exerciseName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Mô hình 3D trực quan 🔄",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.energyOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onDismiss,
                  icon: Text(
                    "✕",
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // 3D Viewer Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: _hasError
                    ? _buildFallbackUI(textColor)
                    : Stack(
                        children: [
                          if (_isHtmlLoaded)
                            WebViewWidget(controller: _webViewController),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.energyOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Title
            Text(
              "Hướng dẫn thực hiện:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            // Instructions Area
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(
                      widget.instructions.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${index + 1}.",
                              style: const TextStyle(
                                color: AppColors.energyOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.instructions[index],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.energyOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedCornerShape(14),
                  elevation: 0,
                ),
                child: const Text(
                  "Đã hiểu",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackUI(Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "🏃‍♂️",
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            "Mô hình 3D đang được cập nhật",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Chúng tôi đang xây dựng mô hình chuyển động chuẩn cho bài tập này. Vui lòng tham khảo hướng dẫn chi tiết bên dưới.",
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Helper to make dp work like double in Compose or standard double
extension DpExtension on num {
  double get dp => toDouble();
}

// Custom RoundedCornerShape equivalent in Flutter
class RoundedCornerShape extends RoundedRectangleBorder {
  RoundedCornerShape(double radius)
      : super(
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        );
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/model/nutrition_models.dart';
import '../../ui/theme/colors.dart';
import '../../ui/theme/theme.dart';
import 'nutrition_ui_state.dart';
import 'nutrition_view_model.dart';

class FoodCatalogSection extends ConsumerStatefulWidget {
  final NutritionContent state;

  const FoodCatalogSection({super.key, required this.state});

  @override
  ConsumerState<FoodCatalogSection> createState() => _FoodCatalogSectionState();
}

class _FoodCatalogSectionState extends ConsumerState<FoodCatalogSection> {
  int _selectedTab = 0;
  int? _expandedFoodId;
  double _inputGrams = 100.0;
  String _inputMealTime = "BREAKFAST";

  @override
  void initState() {
    super.initState();
    _inputMealTime = _defaultMealTime();
  }

  String _defaultMealTime() {
    final hour = DateTime.now().hour;
    if (hour < 10) return "BREAKFAST";
    if (hour < 14) return "LUNCH";
    if (hour < 17) return "SNACK";
    return "DINNER";
  }

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      final byteData =
          await rootBundle.load('assets/catalog/thuc_pham_mau.xlsx');
      final bytes = byteData.buffer.asUint8List();

      File file;
      bool savedToPublicDownload = false;

      if (Platform.isAndroid) {
        final downloadDir = Directory('/storage/emulated/0/Download');
        try {
          if (downloadDir.existsSync()) {
            final testFile = File('${downloadDir.path}/.test_write');
            testFile.writeAsStringSync('test');
            testFile.deleteSync();

            file = File('${downloadDir.path}/thuc_pham_mau.xlsx');
            file.writeAsBytesSync(bytes);
            savedToPublicDownload = true;
          } else {
            final dir = await getApplicationDocumentsDirectory();
            file = File('${dir.path}/thuc_pham_mau.xlsx');
            file.writeAsBytesSync(bytes);
          }
        } catch (_) {
          final dir = await getApplicationDocumentsDirectory();
          file = File('${dir.path}/thuc_pham_mau.xlsx');
          file.writeAsBytesSync(bytes);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        file = File('${dir.path}/thuc_pham_mau.xlsx');
        file.writeAsBytesSync(bytes);
      }

      final path = file.path;

      if (mounted) {
        final message = savedToPublicDownload
            ? 'Đã tải tệp mẫu "thuc_pham_mau.xlsx" vào thư mục Tải xuống (Download).'
            : 'Đã tải tệp mẫu thành công tại: $path';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải tệp mẫu: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _importFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        final bytes = await file.readAsBytes();
        final fileName = result.files.single.name;

        await ref
            .read(nutritionNotifierProvider.notifier)
            .importNutritionFile(fileName, bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn tệp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportCatalog(BuildContext context) async {
    try {
      final bytes = await ref
          .read(nutritionNotifierProvider.notifier)
          .exportFoodCatalogToXlsx();
      if (bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có thực phẩm nào để xuất.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/danh_sach_thuc_pham.xlsx');
      await file.writeAsBytes(bytes);
      final path = file.path;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất danh mục thành công tại: $path'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xuất danh mục: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final isDark = theme.brightness == Brightness.dark;
    final customColors = context.customColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Tra cứu & Nhập thực phẩm 📁",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: customColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (state.foodCatalogCount == 0)
          Card(
            color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Hướng dẫn tự thêm thực phẩm 📝",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: customColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "1. Nhấp \"Tải file mẫu Excel\" bên dưới để lưu tệp thuc_pham_mau.xlsx về điện thoại.\n"
                    "2. Mở tệp vừa tải và điền tên món ăn, calo, đạm, tinh bột, béo theo cấu trúc.\n"
                    "3. Nhấp \"Nhập thực phẩm\" và chọn tệp Excel vừa điền để tra cứu nhanh.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _downloadTemplate(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF97316)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Tải file mẫu Excel",
                            style: TextStyle(
                                color: Color(0xFFF97316),
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _importFile(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF97316),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Nhập thực phẩm",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else ...[
          Text(
            "Đã nhập ${state.foodCatalogCount} món thực phẩm",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _exportCatalog(context),
                child: Text(
                  "Tải Excel hiện tại",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: () => ref
                    .read(nutritionNotifierProvider.notifier)
                    .clearFoodCatalog(),
                child: const Text(
                  "Đặt lại danh mục",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab(0, "Danh mục 📁"),
                _buildTab(1, "Yêu thích ⭐"),
                _buildTab(2, "Gần đây 🕒"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (val) => ref
                .read(nutritionNotifierProvider.notifier)
                .searchFoodsCatalog(val),
            style: TextStyle(color: customColors.primaryText),
            decoration: InputDecoration(
              labelText: "Tìm kiếm thực phẩm...",
              labelStyle: TextStyle(color: customColors.primaryText.withValues(alpha: 0.7)),
              prefixIcon: Icon(Icons.search, color: customColors.primaryText),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFF97316)),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isDark ? AppColors.darkSurface : AppColors.surfaceGray),
                borderRadius: BorderRadius.circular(12),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          _buildFoodList(context),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _importFile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondaryContainer,
              foregroundColor: theme.colorScheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              "Cập nhật / Nhập thêm CSV/Excel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    final customColors = context.customColors;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
            _expandedFoodId = null;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : customColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList(BuildContext context) {
    final state = widget.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;

    final List<FoodCatalogItem> displayedFoods = () {
      final query = state.searchQuery.toLowerCase();
      switch (_selectedTab) {
        case 0:
          return state.foodCatalogItems;
        case 1:
          return state.favorites
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();
        default:
          return state.recentFoods
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();
      }
    }();

    if (displayedFoods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          "Không có thực phẩm nào.",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: displayedFoods.take(10).map((food) {
        final isExpanded = _expandedFoodId == food.id;

        return Card(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceGray,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                title: Text(
                  food.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: customColors.primaryText),
                ),
                subtitle: Text(
                  "${food.caloriesPerServing.toInt()} kcal / ${food.gramsPerServing.toInt()}g  |  P: ${food.proteinPerServing.toInt()}g  C: ${food.carbsPerServing.toInt()}g  F: ${food.fatPerServing.toInt()}g",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Text(food.isFavorite ? "⭐" : "☆",
                          style: const TextStyle(
                              fontSize: 18, color: Color(0xFFF97316))),
                      onPressed: () => ref
                          .read(nutritionNotifierProvider.notifier)
                          .toggleFavoriteCatalog(food.id, !food.isFavorite),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedTab == 1) ...[
                      IconButton(
                        icon: const Text("⚡", style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          ref
                              .read(nutritionNotifierProvider.notifier)
                              .addFoodFromCatalog(food, food.gramsPerServing);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đã ăn 1 khẩu phần ${food.name} ⚡"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedFoodId = null;
                          } else {
                            _expandedFoodId = food.id;
                            _inputGrams = food.gramsPerServing;
                            _inputMealTime = _defaultMealTime();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 4.0),
                      ),
                      child: Text(isExpanded ? "Đóng" : "+ Chọn",
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              if (isExpanded) _buildExpandedSection(food),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandedSection(FoodCatalogItem food) {
    final customColors = context.customColors;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            "Chọn bữa ăn:",
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildMealTimeButton("BREAKFAST", "Sáng"),
              const SizedBox(width: 6),
              _buildMealTimeButton("LUNCH", "Trưa"),
              const SizedBox(width: 6),
              _buildMealTimeButton("DINNER", "Tối"),
              const SizedBox(width: 6),
              _buildMealTimeButton("SNACK", "Phụ"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Khối lượng:",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                "${_inputGrams.toInt()}g",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF97316),
                    fontSize: 15),
              ),
            ],
          ),
          Slider(
            value: _inputGrams,
            onChanged: (val) {
              setState(() {
                _inputGrams = val;
              });
            },
            min: 10,
            max: 1000,
            activeColor: const Color(0xFFF97316),
            inactiveColor: Colors.grey.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [50, 100, 150, 200, 300, 500].map((grams) {
              final isSel = _inputGrams.toInt() == grams;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _inputGrams = grams.toDouble();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor:
                          isSel ? const Color(0xFFF97316) : Colors.transparent,
                      side: BorderSide(
                        color: isSel
                            ? const Color(0xFFF97316)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      "${grams}g",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : customColors.primaryText,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(nutritionNotifierProvider.notifier)
                        .addToCart(food, _inputGrams, _inputMealTime);
                    setState(() {
                      _expandedFoodId = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Color(0xFFF97316)),
                  ),
                  child: const Text("+ Giỏ hàng 🛒",
                      style: TextStyle(color: Color(0xFFF97316))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(nutritionNotifierProvider.notifier)
                        .addFoodFromCatalog(food, _inputGrams);
                    setState(() {
                      _expandedFoodId = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Ăn ngay ✔️",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeButton(String timeVal, String timeLabel) {
    final isSelected = _inputMealTime == timeVal;
    final customColors = context.customColors;
    return Expanded(
      child: isSelected
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
              ),
              child: Text(timeLabel,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
            )
          : OutlinedButton(
              onPressed: () {
                setState(() {
                  _inputMealTime = timeVal;
                });
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Text(timeLabel,
                  style:
                      TextStyle(fontSize: 11, color: customColors.primaryText)),
            ),
    );
  }
}

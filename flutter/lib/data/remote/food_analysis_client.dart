import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/model/nutrition_models.dart';
import 'backend_config.dart';

abstract class FoodAnalysisClient {
  Future<ScanResult?> analyze(Uint8List imageBytes);
  Future<ScanResult?> scanBarcode(String barcode);
  Future<bool> registerBarcode(String barcode, ScanResult result);
}

class DioFoodAnalysisClient implements FoodAnalysisClient {
  final Dio _dio;
  final String? Function() _endpointProvider;

  DioFoodAnalysisClient({
    Dio? dio,
    String? Function()? endpointProvider,
  })  : _dio = dio ?? Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        )),
        _endpointProvider = endpointProvider ??
            (() => BackendConfig.baseUrl != null
                ? '${BackendConfig.baseUrl}/api/analyze-food'
                : null);

  @override
  Future<ScanResult?> scanBarcode(String barcode) async {
    final baseUrl = BackendConfig.baseUrl;
    if (baseUrl == null) return null;
    final url = '$baseUrl/api/scan-barcode?barcode=$barcode';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ScanResult.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Lỗi HTTP ${e.response?.statusCode}: ${e.response?.data}');
    } catch (e) {
      throw Exception('Phản hồi trống hoặc lỗi từ máy chủ: $e');
    }
  }

  @override
  Future<bool> registerBarcode(String barcode, ScanResult result) async {
    final baseUrl = BackendConfig.baseUrl;
    if (baseUrl == null) return false;
    final url = '$baseUrl/api/register-barcode';

    try {
      final response = await _dio.post(
        url,
        data: {
          'barcode': barcode,
          'dishName': result.dishName,
          'totalCalories': result.totalCalories,
          'proteinGrams': result.proteinGrams,
          'carbsGrams': result.carbsGrams,
          'fatGrams': result.fatGrams,
          'advice': result.advice,
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ScanResult?> analyze(Uint8List imageBytes) async {
    final endpointUrl = _endpointProvider();
    if (endpointUrl == null) return null;

    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'food.jpg',
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final response = await _dio.post(
        endpointUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ScanResult.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? message;
      if (errorData is Map<String, dynamic>) {
        message = errorData['error'] as String?;
      }
      throw Exception(message ?? 'Lỗi HTTP ${e.response?.statusCode}');
    } catch (e) {
      throw Exception('Phản hồi trống hoặc lỗi từ máy chủ: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/config.dart';
import '../models/confusion_matrix_data.dart';
import '../models/validation_point.dart';

/// Service untuk mengelola validation data (Confusion Matrix, Field vs Drone)
/// Digunakan untuk Dashboard Asisten - Tier 3
class ValidationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _baseUrl = Config.apiBaseUrl;

  /// Get confusion matrix data untuk analisis akurasi drone
  /// Returns: TP/FP/TN/FN metrics, accuracy, precision, recall, F1-score
  Future<ConfusionMatrixData> getConfusionMatrix({
    String? divisi,
    String? blok,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('🔍 [ValidationService] Fetching confusion matrix...');
      debugPrint('   Divisi: ${divisi ?? "all"}, Blok: ${blok ?? "all"}');

      // Build query parameters
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      // Get auth token
      final token = await _getAuthToken();

      // Call backend API
      final uri = Uri.parse('$_baseUrl/api/v1/validation/confusion-matrix')
          .replace(queryParameters: queryParams);

      debugPrint('   API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('   Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final data = ConfusionMatrixData.fromJson(
            json['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [ValidationService] Confusion matrix loaded');
          debugPrint('   Total: ${data.totalTrees}, Accuracy: ${data.accuracy.toStringAsFixed(1)}%');
          return data;
        } else {
          throw Exception(json['message'] ?? 'Failed to load confusion matrix');
        }
      } else if (response.statusCode == 404) {
        // API endpoint belum tersedia - return dummy data
        debugPrint('⚠️ [ValidationService] API not available, using dummy data');
        return _getDummyConfusionMatrix();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('❌ [ValidationService] Error fetching confusion matrix: $e');
      // Return dummy data untuk development
      return _getDummyConfusionMatrix();
    }
  }

  /// Get field vs drone validation distribution
  /// Returns: List of validation points untuk scatter plot analysis
  Future<FieldVsDroneData> getFieldVsDrone({
    String? divisi,
    String? blok,
    String? stressLevel,
    String? category, // 'TP', 'FP', 'TN', 'FN'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('🔍 [ValidationService] Fetching field vs drone data...');

      // Build query parameters
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (stressLevel != null) queryParams['stress_level'] = stressLevel;
      if (category != null) queryParams['category'] = category;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/validation/field-vs-drone')
          .replace(queryParameters: queryParams);

      debugPrint('   API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('   Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('📋 [DEBUG] Field vs Drone RAW Response Body:');
        debugPrint(response.body.substring(0, response.body.length > 500 ? 500 : response.body.length));
        
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (json['success'] == true) {
          final data = FieldVsDroneData.fromJson(
            json['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [ValidationService] Field vs drone data loaded');
          debugPrint('   Total distributions: ${data.distribution.length}');
          return data;
        } else {
          throw Exception(json['message'] ?? 'Failed to load field vs drone');
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [ValidationService] API not available, using dummy data');
        return _getDummyFieldVsDrone();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('❌ [ValidationService] Error fetching field vs drone: $e');
      return _getDummyFieldVsDrone();
    }
  }

  /// Get trees by category (for drill-down)
  /// Category: 'TP', 'FP', 'TN', 'FN'
  Future<List<ValidationPoint>> getTreesByCategory({
    required String category,
    String? divisi,
    String? blok,
  }) async {
    try {
      final data = await getFieldVsDrone(
        divisi: divisi,
        blok: blok,
        category: category,
      );

      // Find distribution for this category
      final categoryMap = {
        'TP': 'True Positive',
        'FP': 'False Positive',
        'TN': 'True Negative',
        'FN': 'False Negative',
      };

      final categoryName = categoryMap[category] ?? category;
      final distribution = data.distribution.firstWhere(
        (d) => d.category == categoryName,
        orElse: () => throw Exception('Category not found: $category'),
      );

      return distribution.trees;
    } catch (e) {
      debugPrint('❌ [ValidationService] Error fetching trees by category: $e');
      return [];
    }
  }

  /// Override validation result (manual correction)
  /// Used when Asisten Manager identifies incorrect drone prediction
  Future<bool> overrideValidation({
    required String validationId,
    required String correctStatus,
    required String reason,
  }) async {
    try {
      debugPrint('🔄 [ValidationService] Overriding validation...');
      debugPrint('   ID: $validationId, Status: $correctStatus');

      final token = await _getAuthToken();
      final user = _supabase.auth.currentUser;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/validation/$validationId/override'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'correct_status': correctStatus,
          'reason': reason,
          'overridden_by': user?.email ?? 'unknown',
        }),
      );

      debugPrint('   Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ [ValidationService] Validation overridden successfully');
        return true;
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [ValidationService] API not available');
        return false;
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('❌ [ValidationService] Error overriding validation: $e');
      return false;
    }
  }

  /// Get validation override audit log
  Future<List<Map<String, dynamic>>> getValidationOverrides({
    DateTime? startDate,
    DateTime? endDate,
    String? overriddenBy,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (overriddenBy != null) queryParams['overridden_by'] = overriddenBy;

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/audit/validation-overrides')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(json['data']['overrides']);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ [ValidationService] Error fetching overrides: $e');
      return [];
    }
  }

  /// Get auth token from Supabase
  Future<String> _getAuthToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('User not authenticated');
    }
    return session.accessToken;
  }

  /// Dummy data for development (when backend API not available)
  ConfusionMatrixData _getDummyConfusionMatrix() {
    return ConfusionMatrixData(
      truePositive: 118,
      falsePositive: 23,
      trueNegative: 745,
      falseNegative: 24,
      accuracy: 0.948,
      precision: 0.837,
      recall: 0.831,
      f1Score: 0.834,
      fpr: 0.025,
      fnr: 0.169,
      recommendations: [
        'Adjust NDRE threshold untuk Blok A5 dari 0.30 → 0.25',
        'Recalibrate drone sensor (FN rate 16.9% > target 10%)',
        'Review validation SOP dengan Mandor Joko',
      ],
      totalValidated: 910,
      validationDateStart: DateTime.now().subtract(const Duration(days: 14)),
      validationDateEnd: DateTime.now(),
      perDivisi: [
        DivisiAccuracy(
          divisi: 'Divisi 1',
          accuracy: 0.92,
          precision: 0.85,
          totalTrees: 350,
          blokTerburuk: BlokTerburuk(
            blok: 'A5',
            accuracy: 0.62,
            issue: 'High false positive rate',
          ),
        ),
        DivisiAccuracy(
          divisi: 'Divisi 2',
          accuracy: 0.96,
          precision: 0.88,
          totalTrees: 560,
        ),
      ],
    );
  }

  FieldVsDroneData _getDummyFieldVsDrone() {
    return FieldVsDroneData(
      distribution: [
        ValidationDistribution(
          dronePrediction: 'Stres Berat',
          fieldActual: 'Stres Berat',
          count: 118,
          percentage: 12.97,
          category: 'True Positive',
          avgNdre: 0.23,
          trees: [],
          commonCauses: null,
        ),
        ValidationDistribution(
          dronePrediction: 'Stres Berat',
          fieldActual: 'Sehat',
          count: 23,
          percentage: 2.53,
          category: 'False Positive',
          avgNdre: 0.28,
          trees: [],
          commonCauses: [
            CommonCause(cause: 'Bayangan awan', count: 12, percentage: 52.17),
            CommonCause(cause: 'Embun pagi', count: 7, percentage: 30.43),
            CommonCause(
              cause: 'Kamera angle tidak optimal',
              count: 4,
              percentage: 17.39,
            ),
          ],
        ),
        ValidationDistribution(
          dronePrediction: 'Normal',
          fieldActual: 'Stres Berat',
          count: 24,
          percentage: 2.64,
          category: 'False Negative',
          avgNdre: 0.48,
          trees: [],
          commonCauses: [
            CommonCause(
              cause: 'Stress muncul setelah survey',
              count: 15,
              percentage: 62.5,
            ),
            CommonCause(
              cause: 'Sensor calibration issue',
              count: 9,
              percentage: 37.5,
            ),
          ],
        ),
        ValidationDistribution(
          dronePrediction: 'Normal',
          fieldActual: 'Normal',
          count: 745,
          percentage: 81.87,
          category: 'True Negative',
          avgNdre: 0.68,
          trees: [],
          commonCauses: null,
        ),
      ],
      recommendations: [
        'Reschedule drone survey: Avoid 06:00-09:00 (embun)',
        'Update pilot SOP: Camera angle consistency',
        'Threshold adjustment: 0.30 → 0.25 for Blok A5',
      ],
      totalTrees: 910,
      accuracy: 0.948, // (TP + TN) / Total = (118 + 745) / 910
      precision: 0.837, // TP / (TP + FP) = 118 / (118 + 23)
      recall: 0.831, // TP / (TP + FN) = 118 / (118 + 24)
      f1Score: 0.834, // 2 * (precision * recall) / (precision + recall)
    );
  }
}

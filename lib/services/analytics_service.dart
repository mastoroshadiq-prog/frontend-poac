import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/config.dart';
import '../models/anomaly_item.dart';
import '../models/mandor_performance.dart';

/// Service untuk analytics data (Anomaly Detection, Mandor Performance)
/// Digunakan untuk Dashboard Asisten - Tier 3
class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _baseUrl = Config.apiBaseUrl;

  /// Get anomaly detection data
  /// Returns: List of operational issues (pohon miring, mati, gambut, spacing)
  Future<AnomalyData> getAnomalyDetection({
    String? divisi,
    String? blok,
    String? anomalyType, // 'miring', 'mati', 'gambut', 'spacing', 'ndre'
    String? severity, // 'high', 'medium', 'low'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('🔍 [AnalyticsService] Fetching anomaly detection...');
      debugPrint('   Type: ${anomalyType ?? "all"}, Severity: ${severity ?? "all"}');

      // Build query parameters
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (anomalyType != null) queryParams['anomaly_type'] = anomalyType;
      if (severity != null) queryParams['severity'] = severity;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/analytics/anomaly-detection')
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
          final data = AnomalyData.fromJson(
            json['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [AnalyticsService] Anomaly data loaded');
          debugPrint('   Total anomalies: ${data.summary.totalAnomalies}');
          return data;
        } else {
          throw Exception(json['message'] ?? 'Failed to load anomaly data');
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [AnalyticsService] API not available, using dummy data');
        return _getDummyAnomalyData();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error fetching anomaly detection: $e');
      return _getDummyAnomalyData();
    }
  }

  /// Get mandor performance tracking data
  /// Returns: KPI metrics untuk all mandors (completion rate, quality, speed)
  Future<MandorPerformanceData> getMandorPerformance({
    String? mandorId, // Optional: specific mandor
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('🔍 [AnalyticsService] Fetching mandor performance...');
      debugPrint('   Mandor ID: ${mandorId ?? "all"}');

      // Build query parameters
      final queryParams = <String, String>{};
      if (mandorId != null) queryParams['mandor_id'] = mandorId;
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/analytics/mandor-performance')
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
          final data = MandorPerformanceData.fromJson(
            json['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ [AnalyticsService] Mandor performance loaded');
          debugPrint('   Total mandors: ${data.summary.totalMandors}');
          return data;
        } else {
          throw Exception(
            json['message'] ?? 'Failed to load mandor performance',
          );
        }
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [AnalyticsService] API not available, using dummy data');
        return _getDummyMandorPerformance();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error fetching mandor performance: $e');
      return _getDummyMandorPerformance();
    }
  }

  /// Get surveyor workload distribution
  Future<List<Map<String, dynamic>>> getSurveyorWorkload({
    String? mandorId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (mandorId != null) queryParams['mandor_id'] = mandorId;

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/analytics/surveyor-workload')
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
        return List<Map<String, dynamic>>.from(json['data']['surveyors']);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ [AnalyticsService] Error fetching surveyor workload: $e');
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

  /// Dummy data for development
  AnomalyData _getDummyAnomalyData() {
    return AnomalyData(
      summary: AnomaliSummary(
        totalAnomalies: 35,
        highSeverity: 20,
        mediumSeverity: 12,
        lowSeverity: 3,
      ),
      anomalies: [
        AnomalyItem(
          type: 'pohon_miring',
          severity: 'high',
          count: 12,
          criteria: 'Kemiringan > 30 derajat',
          trees: [],
          recommendedAction: 'Create SPK penegakan pohon + penyangga',
          estimatedCost: 1800000,
          priority: 'urgent',
          dueDate: DateTime.now().add(const Duration(days: 7)),
        ),
        AnomalyItem(
          type: 'pohon_mati',
          severity: 'high',
          count: 8,
          criteria: 'Tidak ada tanda kehidupan, daun kering',
          trees: [],
          recommendedAction: 'Create SPK eradikasi + karantina area',
          estimatedCost: 4000000,
          priority: 'critical',
          dueDate: DateTime.now().add(const Duration(days: 2)),
        ),
        AnomalyItem(
          type: 'gambut_amblas',
          severity: 'medium',
          count: 5,
          criteria: 'Permukaan tanah turun >20cm',
          bloks: ['A3', 'A4', 'A5', 'B2', 'C1'],
          treesAffected: 125,
          recommendedAction: 'Create SPK pembenahan drainase',
          estimatedCost: 15000000,
          priority: 'high',
          dueDate: DateTime.now().add(const Duration(days: 12)),
        ),
        AnomalyItem(
          type: 'spacing',
          severity: 'medium',
          count: 3,
          criteria: 'Jarak tanam tidak standar (>10% deviasi)',
          bloks: ['B1', 'B3', 'C2'],
          treesAffected: 45,
          recommendedAction: 'Create SPK reposisi/marking',
          estimatedCost: 2500000,
          priority: 'normal',
          dueDate: DateTime.now().add(const Duration(days: 30)),
        ),
        AnomalyItem(
          type: 'ndre',
          severity: 'low',
          count: 23,
          criteria: 'NDRE rendah tapi pohon sehat (FP)',
          trees: [],
          recommendedAction: 'Update threshold config',
          estimatedCost: 0,
          priority: 'normal',
          dueDate: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
    );
  }

  MandorPerformanceData _getDummyMandorPerformance() {
    return MandorPerformanceData(
      summary: PerformanceSummary(
        totalMandors: 7,
        avgCompletionRate: 0.82,
        avgQualityScore: 0.91,
      ),
      mandors: [
        MandorPerformance(
          mandorId: 'uuid-1',
          name: 'Joko Susilo',
          afdeling: 'Afdeling 1',
          performance: PerformanceMetrics(
            spkAssigned: 5,
            spkCompleted: 4,
            spkOverdue: 1,
            completionRate: 0.80,
            avgCompletionDays: 2.3,
            qualityScore: 0.92,
          ),
          breakdown: PerformanceBreakdown(
            validationAccuracy: 0.94,
            sopCompliance: 0.90,
            speedScore: 0.85,
            surveyorRating: 4.6,
          ),
          issues: [
            PerformanceIssue(
              type: 'overdue_spk',
              spkId: 'uuid-spk-1',
              nomorSpk: 'SPK/VAL/2025/005',
              daysOverdue: 3,
              reason: 'Surveyor sakit',
            ),
          ],
          recommendations: [
            'Reallocate SPK/VAL/2025/005 to Siti Aminah (available)',
            'Provide recognition for high quality score (92%)',
          ],
        ),
        MandorPerformance(
          mandorId: 'uuid-2',
          name: 'Siti Aminah',
          afdeling: 'Afdeling 2',
          performance: PerformanceMetrics(
            spkAssigned: 4,
            spkCompleted: 4,
            spkOverdue: 0,
            completionRate: 1.00,
            avgCompletionDays: 1.8,
            qualityScore: 0.95,
          ),
          breakdown: PerformanceBreakdown(
            validationAccuracy: 0.96,
            sopCompliance: 0.95,
            speedScore: 0.92,
            surveyorRating: 4.8,
          ),
          issues: [],
          recommendations: [
            'Top performer - assign high-priority tasks',
            'Consider as mentor for low-performing mandor',
          ],
        ),
        MandorPerformance(
          mandorId: 'uuid-3',
          name: 'Ahmad Yani',
          afdeling: 'Afdeling 1',
          performance: PerformanceMetrics(
            spkAssigned: 3,
            spkCompleted: 2,
            spkOverdue: 0,
            completionRate: 0.67,
            avgCompletionDays: 3.1,
            qualityScore: 0.88,
          ),
          breakdown: PerformanceBreakdown(
            validationAccuracy: 0.89,
            sopCompliance: 0.85,
            speedScore: 0.78,
            surveyorRating: 4.2,
          ),
          issues: [],
          recommendations: [
            'Provide training on validation techniques',
            'Monitor completion speed - below target',
          ],
        ),
      ],
      rankings: PerformanceRankings(
        byCompletionRate: [
          MandorRanking(mandorId: 'uuid-2', name: 'Siti Aminah', rate: 1.00),
          MandorRanking(mandorId: 'uuid-1', name: 'Joko Susilo', rate: 0.80),
          MandorRanking(mandorId: 'uuid-3', name: 'Ahmad Yani', rate: 0.67),
        ],
        byQuality: [
          MandorRanking(mandorId: 'uuid-2', name: 'Siti Aminah', rate: 0.95),
          MandorRanking(mandorId: 'uuid-1', name: 'Joko Susilo', rate: 0.92),
          MandorRanking(mandorId: 'uuid-3', name: 'Ahmad Yani', rate: 0.88),
        ],
        bySpeed: [
          MandorRanking(mandorId: 'uuid-2', name: 'Siti Aminah', rate: 0.92),
          MandorRanking(mandorId: 'uuid-1', name: 'Joko Susilo', rate: 0.85),
          MandorRanking(mandorId: 'uuid-3', name: 'Ahmad Yani', rate: 0.78),
        ],
      ),
    );
  }
}

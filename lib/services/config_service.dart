import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/config.dart';

/// Service untuk configuration management (NDRE Threshold, Settings)
/// Digunakan untuk Dashboard Asisten - Tier 3
class ConfigService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _baseUrl = Config.apiBaseUrl;

  /// Get NDRE threshold configuration
  /// Returns current threshold values per divisi/blok
  Future<NdreThresholdConfig> getNdreThreshold({
    String? divisi,
    String? blok,
  }) async {
    try {
      debugPrint('🔍 [ConfigService] Fetching NDRE threshold...');
      debugPrint('   Divisi: ${divisi ?? "default"}, Blok: ${blok ?? "default"}');

      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/config/ndre-threshold')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ [ConfigService] NDRE threshold loaded');
        return NdreThresholdConfig.fromJson(json['data']);
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [ConfigService] API not available, using defaults');
        return _getDefaultThreshold();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('❌ [ConfigService] Error fetching NDRE threshold: $e');
      return _getDefaultThreshold();
    }
  }

  /// Update NDRE threshold configuration
  /// Used by Asisten Manager to adjust sensitivity
  Future<NdreThresholdUpdateResult> updateNdreThreshold({
    String? divisi,
    String? blok,
    required double newThreshold,
    required String reason,
  }) async {
    try {
      debugPrint('🔄 [ConfigService] Updating NDRE threshold...');
      debugPrint('   New threshold: $newThreshold');

      final token = await _getAuthToken();
      final user = _supabase.auth.currentUser;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/v1/config/ndre-threshold'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
        body: jsonEncode({
          if (divisi != null) 'divisi': divisi,
          if (blok != null) 'blok': blok,
          'new_threshold': newThreshold,
          'reason': reason,
          'updated_by': user?.email ?? 'unknown',
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ [ConfigService] NDRE threshold updated');
        return NdreThresholdUpdateResult.fromJson(json['data']);
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ [ConfigService] API not available');
        return NdreThresholdUpdateResult(
          success: false,
          impactAnalysis: ImpactAnalysis(
            treesAffectedCount: 0,
            previouslyStres: 0,
            nowStres: 0,
            reclassificationRate: 0.0,
          ),
          message: 'API endpoint not available',
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('❌ [ConfigService] Error updating NDRE threshold: $e');
      return NdreThresholdUpdateResult(
        success: false,
        impactAnalysis: ImpactAnalysis(
          treesAffectedCount: 0,
          previouslyStres: 0,
          nowStres: 0,
          reclassificationRate: 0.0,
        ),
        message: e.toString(),
      );
    }
  }

  /// Get threshold change history
  Future<List<ThresholdChangeLog>> getThresholdHistory({
    String? divisi,
    String? blok,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (divisi != null) queryParams['divisi'] = divisi;
      if (blok != null) queryParams['blok'] = blok;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final token = await _getAuthToken();
      final uri = Uri.parse('$_baseUrl/api/v1/config/ndre-threshold/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return (json['data']['history'] as List)
            .map((e) => ThresholdChangeLog.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ [ConfigService] Error fetching threshold history: $e');
      return [];
    }
  }

  /// Get auth token
  Future<String> _getAuthToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('User not authenticated');
    }
    return session.accessToken;
  }

  /// Default threshold values
  NdreThresholdConfig _getDefaultThreshold() {
    return NdreThresholdConfig(
      currentThreshold: Config.ndreThresholdStresBerat,
      recommendedThreshold: Config.ndreThresholdStresBerat,
      divisi: null,
      blok: null,
      history: [],
    );
  }
}

/// NDRE Threshold Configuration Model
class NdreThresholdConfig {
  final double currentThreshold;
  final double recommendedThreshold;
  final String? divisi;
  final String? blok;
  final List<ThresholdChangeLog> history;

  NdreThresholdConfig({
    required this.currentThreshold,
    required this.recommendedThreshold,
    this.divisi,
    this.blok,
    required this.history,
  });

  factory NdreThresholdConfig.fromJson(Map<String, dynamic> json) {
    return NdreThresholdConfig(
      currentThreshold: (json['current_threshold'] as num).toDouble(),
      recommendedThreshold: (json['recommended'] as num).toDouble(),
      divisi: json['divisi'] as String?,
      blok: json['blok'] as String?,
      history: json['history'] != null
          ? (json['history'] as List)
              .map((e) => ThresholdChangeLog.fromJson(e))
              .toList()
          : [],
    );
  }
}

/// Threshold Change Log
class ThresholdChangeLog {
  final DateTime timestamp;
  final double oldThreshold;
  final double newThreshold;
  final String reason;
  final String updatedBy;

  ThresholdChangeLog({
    required this.timestamp,
    required this.oldThreshold,
    required this.newThreshold,
    required this.reason,
    required this.updatedBy,
  });

  factory ThresholdChangeLog.fromJson(Map<String, dynamic> json) {
    return ThresholdChangeLog(
      timestamp: DateTime.parse(json['timestamp']),
      oldThreshold: (json['old_threshold'] as num).toDouble(),
      newThreshold: (json['new_threshold'] as num).toDouble(),
      reason: json['reason'] as String,
      updatedBy: json['updated_by'] as String,
    );
  }
}

/// Threshold Update Result
class NdreThresholdUpdateResult {
  final bool success;
  final ImpactAnalysis impactAnalysis;
  final String? message;

  NdreThresholdUpdateResult({
    required this.success,
    required this.impactAnalysis,
    this.message,
  });

  factory NdreThresholdUpdateResult.fromJson(Map<String, dynamic> json) {
    return NdreThresholdUpdateResult(
      success: json['success'] as bool? ?? false,
      impactAnalysis: ImpactAnalysis.fromJson(json['impact_analysis']),
      message: json['message'] as String?,
    );
  }
}

/// Impact Analysis of Threshold Change
class ImpactAnalysis {
  final int treesAffectedCount;
  final int previouslyStres;
  final int nowStres;
  final double reclassificationRate;

  ImpactAnalysis({
    required this.treesAffectedCount,
    required this.previouslyStres,
    required this.nowStres,
    required this.reclassificationRate,
  });

  factory ImpactAnalysis.fromJson(Map<String, dynamic> json) {
    return ImpactAnalysis(
      treesAffectedCount: json['trees_affected_count'] as int,
      previouslyStres: json['previously_stres'] as int,
      nowStres: json['now_stres'] as int,
      reclassificationRate: (json['reclassification_rate'] as num).toDouble(),
    );
  }
}

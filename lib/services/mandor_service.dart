import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mandor_dashboard_data.dart';

/// Service untuk Mandor Dashboard API
/// Base URL: http://localhost:3000/api/v1/mandor
class MandorService {
  static const String baseUrl = 'http://localhost:3000/api/v1/mandor';

  /// GET /mandor/:id/dashboard - Dashboard Overview
  Future<MandorDashboardData> getDashboard(String mandorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$mandorId/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      print('📊 Dashboard API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return MandorDashboardData.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Dashboard API Error: $e');
      print('📦 Using dummy data for dashboard');
      return _getDummyDashboard();
    }
  }

  /// GET /mandor/:id/surveyors - Surveyor List
  Future<SurveyorListData> getSurveyors(String mandorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$mandorId/surveyors'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      print('👥 Surveyors API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return SurveyorListData.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Surveyors API Error: $e');
      print('📦 Using dummy data for surveyors');
      return _getDummySurveyors();
    }
  }

  /// GET /mandor/:id/tasks/realtime - Real-time Task Monitoring
  Future<RealtimeTaskData> getRealtimeTasks(String mandorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$mandorId/tasks/realtime'),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      print('⏱️ Realtime Tasks API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return RealtimeTaskData.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Realtime Tasks API Error: $e');
      print('📦 Using dummy data for realtime tasks');
      return _getDummyRealtimeTasks();
    }
  }

  /// GET /mandor/:id/performance/daily - Daily Performance Report
  Future<DailyPerformanceData> getDailyPerformance(
    String mandorId, {
    String? date,
  }) async {
    try {
      final uri = date != null
          ? Uri.parse('$baseUrl/$mandorId/performance/daily?date=$date')
          : Uri.parse('$baseUrl/$mandorId/performance/daily');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
        },
      );

      print('📈 Performance API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return DailyPerformanceData.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['error'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Performance API Error: $e');
      print('📦 Using dummy data for performance');
      return _getDummyPerformance();
    }
  }

  // ==================== DUMMY DATA ====================

  MandorDashboardData _getDummyDashboard() {
    return MandorDashboardData(
      summary: DashboardSummary(
        activeSpk: 5,
        pendingTasks: 12,
        inProgressTasks: 8,
        completedToday: 15,
        urgentCount: 3,
        overdueCount: 2,
      ),
      todayTargets: TodayTargets(
        treesToValidate: 50,
        completed: 32,
        remaining: 18,
        progressPercentage: 64.0,
      ),
      surveyorWorkload: [],
      urgentItems: [],
    );
  }

  SurveyorListData _getDummySurveyors() {
    return SurveyorListData(
      surveyors: [
        SurveyorData(
          surveyorId: 'surv-001',
          name: 'Budi Santoso',
          status: 'WORKING',
          currentWorkload: SurveyorWorkload(
            activeTasks: 3,
            pendingTasks: 2,
            completedToday: 5,
          ),
          performance: SurveyorPerformance(
            completionRate: 92.5,
            avgTimePerTask: 25,
            qualityScore: 4.5,
          ),
        ),
        SurveyorData(
          surveyorId: 'surv-002',
          name: 'Siti Aminah',
          status: 'AVAILABLE',
          currentWorkload: SurveyorWorkload(
            activeTasks: 0,
            pendingTasks: 4,
            completedToday: 7,
          ),
          performance: SurveyorPerformance(
            completionRate: 95.0,
            avgTimePerTask: 22,
            qualityScore: 4.8,
          ),
        ),
        SurveyorData(
          surveyorId: 'surv-003',
          name: 'Ahmad Yani',
          status: 'WORKING',
          currentWorkload: SurveyorWorkload(
            activeTasks: 2,
            pendingTasks: 3,
            completedToday: 4,
          ),
          performance: SurveyorPerformance(
            completionRate: 88.0,
            avgTimePerTask: 28,
            qualityScore: 4.2,
          ),
        ),
        SurveyorData(
          surveyorId: 'surv-004',
          name: 'Dewi Lestari',
          status: 'OFF_DUTY',
          currentWorkload: SurveyorWorkload(
            activeTasks: 0,
            pendingTasks: 0,
            completedToday: 0,
          ),
          performance: SurveyorPerformance(
            completionRate: 90.0,
            avgTimePerTask: 24,
            qualityScore: 4.6,
          ),
        ),
      ],
      summary: SurveyorSummary(
        totalSurveyors: 4,
        available: 1,
        working: 2,
        offDuty: 1,
      ),
    );
  }

  RealtimeTaskData _getDummyRealtimeTasks() {
    return RealtimeTaskData(
      activeTasks: [
        ActiveTask(
          taskId: 'task-001',
          surveyorName: 'Budi Santoso',
          treeId: 'TREE-D001A-001-001',
          location: 'Blok D001A, Baris 1, Pokok 1',
          status: 'IN_PROGRESS',
          elapsedTimeMins: 12,
          photosUploaded: 3,
          checklistCompleted: 5,
        ),
        ActiveTask(
          taskId: 'task-002',
          surveyorName: 'Ahmad Yani',
          treeId: 'TREE-D001A-001-005',
          location: 'Blok D001A, Baris 1, Pokok 5',
          status: 'IN_PROGRESS',
          elapsedTimeMins: 8,
          photosUploaded: 2,
          checklistCompleted: 3,
        ),
      ],
      recentCompletions: [
        RecentCompletion(
          taskId: 'task-100',
          surveyorName: 'Siti Aminah',
          treeId: 'TREE-D001A-002-003',
          completedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          timeTakenMins: 18,
          result: 'VALIDATED',
        ),
        RecentCompletion(
          taskId: 'task-099',
          surveyorName: 'Budi Santoso',
          treeId: 'TREE-D001A-002-001',
          completedAt: DateTime.now().subtract(const Duration(minutes: 15)),
          timeTakenMins: 22,
          result: 'VALIDATED',
        ),
      ],
    );
  }

  DailyPerformanceData _getDummyPerformance() {
    final today = DateTime.now();
    return DailyPerformanceData(
      date: '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      targets: PerformanceTargets(
        plannedTasks: 50,
        completed: 32,
        inProgress: 8,
        pending: 10,
        achievementRate: 64.0,
      ),
      bySurveyor: [
        SurveyorPerformanceDetail(
          surveyorId: 'surv-001',
          surveyorName: 'Budi Santoso',
          assignedTasks: 15,
          completedTasks: 10,
          completionRate: 66.7,
          avgTimePerTask: 25,
          qualityScore: 4.5,
        ),
        SurveyorPerformanceDetail(
          surveyorId: 'surv-002',
          surveyorName: 'Siti Aminah',
          assignedTasks: 15,
          completedTasks: 12,
          completionRate: 80.0,
          avgTimePerTask: 22,
          qualityScore: 4.8,
        ),
        SurveyorPerformanceDetail(
          surveyorId: 'surv-003',
          surveyorName: 'Ahmad Yani',
          assignedTasks: 12,
          completedTasks: 8,
          completionRate: 66.7,
          avgTimePerTask: 28,
          qualityScore: 4.2,
        ),
      ],
      issues: [
        PerformanceIssue(
          type: 'DELAYED',
          severity: 'medium',
          description: '2 tasks melewati target waktu (>30 menit)',
          affectedTasks: ['task-045', 'task-048'],
        ),
        PerformanceIssue(
          type: 'QUALITY',
          severity: 'low',
          description: 'Foto kurang jelas pada 1 task',
          affectedTasks: ['task-042'],
        ),
      ],
      recommendations: [
        Recommendation(
          priority: 'high',
          action: 'Alokasi ulang 5 tasks dari Budi ke Siti',
          reason: 'Siti memiliki completion rate tertinggi (80%)',
        ),
        Recommendation(
          priority: 'medium',
          action: 'Review proses dokumentasi foto dengan Ahmad',
          reason: 'Waktu rata-rata Ahmad 28 menit (tertinggi)',
        ),
      ],
    );
  }
}

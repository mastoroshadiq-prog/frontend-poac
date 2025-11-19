/// Models untuk Mandor Dashboard
/// Source: API_MANDOR_DASHBOARD_GUIDE.md
library;

/// Dashboard Overview Response
class MandorDashboardData {
  final DashboardSummary summary;
  final TodayTargets todayTargets;
  final List<dynamic> surveyorWorkload;
  final List<dynamic> urgentItems;

  MandorDashboardData({
    required this.summary,
    required this.todayTargets,
    required this.surveyorWorkload,
    required this.urgentItems,
  });

  factory MandorDashboardData.fromJson(Map<String, dynamic> json) {
    return MandorDashboardData(
      summary: DashboardSummary.fromJson(json['summary']),
      todayTargets: TodayTargets.fromJson(json['today_targets']),
      surveyorWorkload: json['surveyor_workload'] as List? ?? [],
      urgentItems: json['urgent_items'] as List? ?? [],
    );
  }
}

/// Summary statistics
class DashboardSummary {
  final int activeSpk;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedToday;
  final int urgentCount;
  final int overdueCount;

  DashboardSummary({
    required this.activeSpk,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completedToday,
    required this.urgentCount,
    required this.overdueCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeSpk: json['active_spk'] as int? ?? 0,
      pendingTasks: json['pending_tasks'] as int? ?? 0,
      inProgressTasks: json['in_progress_tasks'] as int? ?? 0,
      completedToday: json['completed_today'] as int? ?? 0,
      urgentCount: json['urgent_count'] as int? ?? 0,
      overdueCount: json['overdue_count'] as int? ?? 0,
    );
  }
}

/// Today's targets and progress
class TodayTargets {
  final int treesToValidate;
  final int completed;
  final int remaining;
  final double progressPercentage;

  TodayTargets({
    required this.treesToValidate,
    required this.completed,
    required this.remaining,
    required this.progressPercentage,
  });

  factory TodayTargets.fromJson(Map<String, dynamic> json) {
    return TodayTargets(
      treesToValidate: json['trees_to_validate'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Surveyor data dengan status dan performance
class SurveyorData {
  final String surveyorId;
  final String name;
  final String status; // AVAILABLE, WORKING, OFF_DUTY
  final SurveyorWorkload currentWorkload;
  final SurveyorPerformance performance;

  SurveyorData({
    required this.surveyorId,
    required this.name,
    required this.status,
    required this.currentWorkload,
    required this.performance,
  });

  factory SurveyorData.fromJson(Map<String, dynamic> json) {
    return SurveyorData(
      surveyorId: json['surveyor_id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      currentWorkload: SurveyorWorkload.fromJson(json['current_workload']),
      performance: SurveyorPerformance.fromJson(json['performance']),
    );
  }
}

class SurveyorWorkload {
  final int activeTasks;
  final int pendingTasks;
  final int completedToday;

  SurveyorWorkload({
    required this.activeTasks,
    required this.pendingTasks,
    required this.completedToday,
  });

  factory SurveyorWorkload.fromJson(Map<String, dynamic> json) {
    return SurveyorWorkload(
      activeTasks: json['active_tasks'] as int? ?? 0,
      pendingTasks: json['pending_tasks'] as int? ?? 0,
      completedToday: json['completed_today'] as int? ?? 0,
    );
  }
}

class SurveyorPerformance {
  final double completionRate;
  final int avgTimePerTask;
  final double qualityScore;

  SurveyorPerformance({
    required this.completionRate,
    required this.avgTimePerTask,
    required this.qualityScore,
  });

  factory SurveyorPerformance.fromJson(Map<String, dynamic> json) {
    return SurveyorPerformance(
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      avgTimePerTask: json['avg_time_per_task'] as int? ?? 0,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Surveyor List Response
class SurveyorListData {
  final List<SurveyorData> surveyors;
  final SurveyorSummary summary;

  SurveyorListData({
    required this.surveyors,
    required this.summary,
  });

  factory SurveyorListData.fromJson(Map<String, dynamic> json) {
    return SurveyorListData(
      surveyors: (json['surveyors'] as List)
          .map((s) => SurveyorData.fromJson(s))
          .toList(),
      summary: SurveyorSummary.fromJson(json['summary']),
    );
  }
}

class SurveyorSummary {
  final int totalSurveyors;
  final int available;
  final int working;
  final int offDuty;

  SurveyorSummary({
    required this.totalSurveyors,
    required this.available,
    required this.working,
    required this.offDuty,
  });

  factory SurveyorSummary.fromJson(Map<String, dynamic> json) {
    return SurveyorSummary(
      totalSurveyors: json['total_surveyors'] as int? ?? 0,
      available: json['available'] as int? ?? 0,
      working: json['working'] as int? ?? 0,
      offDuty: json['off_duty'] as int? ?? 0,
    );
  }
}

/// Real-time Task Monitoring
class RealtimeTaskData {
  final List<ActiveTask> activeTasks;
  final List<RecentCompletion> recentCompletions;

  RealtimeTaskData({
    required this.activeTasks,
    required this.recentCompletions,
  });

  factory RealtimeTaskData.fromJson(Map<String, dynamic> json) {
    return RealtimeTaskData(
      activeTasks: (json['active_tasks'] as List)
          .map((t) => ActiveTask.fromJson(t))
          .toList(),
      recentCompletions: (json['recent_completions'] as List)
          .map((c) => RecentCompletion.fromJson(c))
          .toList(),
    );
  }
}

class ActiveTask {
  final String taskId;
  final String surveyorName;
  final String treeId;
  final String location;
  final String status;
  final int elapsedTimeMins;
  final int photosUploaded;
  final int checklistCompleted;

  ActiveTask({
    required this.taskId,
    required this.surveyorName,
    required this.treeId,
    required this.location,
    required this.status,
    required this.elapsedTimeMins,
    required this.photosUploaded,
    required this.checklistCompleted,
  });

  factory ActiveTask.fromJson(Map<String, dynamic> json) {
    return ActiveTask(
      taskId: json['task_id'] as String,
      surveyorName: json['surveyor_name'] as String,
      treeId: json['tree_id'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      elapsedTimeMins: json['elapsed_time_mins'] as int? ?? 0,
      photosUploaded: json['photos_uploaded'] as int? ?? 0,
      checklistCompleted: json['checklist_completed'] as int? ?? 0,
    );
  }
}

class RecentCompletion {
  final String taskId;
  final String surveyorName;
  final String treeId;
  final DateTime completedAt;
  final int timeTakenMins;
  final String result;

  RecentCompletion({
    required this.taskId,
    required this.surveyorName,
    required this.treeId,
    required this.completedAt,
    required this.timeTakenMins,
    required this.result,
  });

  factory RecentCompletion.fromJson(Map<String, dynamic> json) {
    return RecentCompletion(
      taskId: json['task_id'] as String,
      surveyorName: json['surveyor_name'] as String,
      treeId: json['tree_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      timeTakenMins: json['time_taken_mins'] as int? ?? 0,
      result: json['result'] as String,
    );
  }
}

/// Daily Performance Report
class DailyPerformanceData {
  final String date;
  final PerformanceTargets targets;
  final List<SurveyorPerformanceDetail> bySurveyor;
  final List<PerformanceIssue> issues;
  final List<Recommendation> recommendations;

  DailyPerformanceData({
    required this.date,
    required this.targets,
    required this.bySurveyor,
    required this.issues,
    required this.recommendations,
  });

  factory DailyPerformanceData.fromJson(Map<String, dynamic> json) {
    return DailyPerformanceData(
      date: json['date'] as String,
      targets: PerformanceTargets.fromJson(json['targets']),
      bySurveyor: (json['by_surveyor'] as List)
          .map((s) => SurveyorPerformanceDetail.fromJson(s))
          .toList(),
      issues: (json['issues'] as List)
          .map((i) => PerformanceIssue.fromJson(i))
          .toList(),
      recommendations: (json['recommendations'] as List)
          .map((r) => Recommendation.fromJson(r))
          .toList(),
    );
  }
}

class PerformanceTargets {
  final int plannedTasks;
  final int completed;
  final int inProgress;
  final int pending;
  final double achievementRate;

  PerformanceTargets({
    required this.plannedTasks,
    required this.completed,
    required this.inProgress,
    required this.pending,
    required this.achievementRate,
  });

  factory PerformanceTargets.fromJson(Map<String, dynamic> json) {
    return PerformanceTargets(
      plannedTasks: json['planned_tasks'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      achievementRate: (json['achievement_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SurveyorPerformanceDetail {
  final String surveyorId;
  final String surveyorName;
  final int assignedTasks;
  final int completedTasks;
  final double completionRate;
  final int avgTimePerTask;
  final double qualityScore;

  SurveyorPerformanceDetail({
    required this.surveyorId,
    required this.surveyorName,
    required this.assignedTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.avgTimePerTask,
    required this.qualityScore,
  });

  factory SurveyorPerformanceDetail.fromJson(Map<String, dynamic> json) {
    return SurveyorPerformanceDetail(
      surveyorId: json['surveyor_id'] as String,
      surveyorName: json['surveyor_name'] as String,
      assignedTasks: json['assigned_tasks'] as int? ?? 0,
      completedTasks: json['completed_tasks'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      avgTimePerTask: json['avg_time_per_task'] as int? ?? 0,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PerformanceIssue {
  final String type; // DELAYED, QUALITY, BOTTLENECK
  final String severity; // low, medium, high, critical
  final String description;
  final List<String> affectedTasks;

  PerformanceIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedTasks,
  });

  factory PerformanceIssue.fromJson(Map<String, dynamic> json) {
    return PerformanceIssue(
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      affectedTasks: (json['affected_tasks'] as List).cast<String>(),
    );
  }
}

class Recommendation {
  final String priority; // low, medium, high
  final String action;
  final String reason;

  Recommendation({
    required this.priority,
    required this.action,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      priority: json['priority'] as String,
      action: json['action'] as String,
      reason: json['reason'] as String,
    );
  }
}

import 'package:flutter/material.dart';

class SurveyAnalysis {
  final bool status;
  final String message;
  final List<SurveyAnalysisData> data;

  const SurveyAnalysis({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SurveyAnalysis.fromJson(Map<String, dynamic> json) {
    return SurveyAnalysis(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => SurveyAnalysisData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SurveyAnalysisData {
  final int id;
  final String title;
  final String description;
  final List<SurveyQuestion> questions;
  final int branchId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final SurveyBranch branch;
  final List<SurveyResponse> responses;

  const SurveyAnalysisData({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.branchId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.branch,
    this.responses = const [],
  });

  factory SurveyAnalysisData.fromJson(Map<String, dynamic> json) {
    return SurveyAnalysisData(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => SurveyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      branchId: json['branch_id'] as int,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      branch: SurveyBranch.fromJson(json['branch'] as Map<String, dynamic>),
      responses:
          (json['responses'] as List<dynamic>?)
              ?.map((e) => SurveyResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toJson()).toList(),
      'branch_id': branchId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'branch': branch.toJson(),
      'responses': responses.map((e) => e.toJson()).toList(),
    };
  }

  // Helper methods for analysis
  int get totalResponses => responses.length;
  int get totalQuestions => questions.length;

  // Get total responses excluding manager responses
  int getTotalResponsesExcludingManagers(List<int>? excludeUserIds) {
    if (excludeUserIds == null) return responses.length;
    return responses
        .where((response) => !excludeUserIds.contains(response.userId))
        .length;
  }

  double get completionRate {
    if (totalQuestions == 0) return 0.0;
    // For demo purposes, we'll simulate completion rates
    // In real implementation, this would be calculated based on actual response data
    final rates = [89.0, 94.0, 23.0];
    return rates[id % rates.length];
  }

  // Calculate completion rate based on total users in branch
  double calculateCompletionRate(int totalUsersInBranch) {
    if (totalUsersInBranch == 0) return 0.0;
    return (totalResponses / totalUsersInBranch) * 100;
  }

  // Calculate completion rate excluding manager responses
  double calculateCompletionRateExcludingManagers(
    int totalUsersInBranch,
    List<int>? excludeUserIds,
  ) {
    if (totalUsersInBranch == 0) return 0.0;
    final nonManagerResponseCount = getTotalResponsesExcludingManagers(
      excludeUserIds,
    );
    final nonManagerUserCount =
        totalUsersInBranch - (excludeUserIds?.length ?? 0);
    if (nonManagerUserCount == 0) return 0.0;
    return (nonManagerResponseCount / nonManagerUserCount) * 100;
  }

  String get statusText {
    if (status == 'active') {
      final daysLeft = (id % 7) + 1; // Simulate days left
      return 'Active • $daysLeft days left';
    }
    return 'Completed';
  }

  String get actionText {
    if (status == 'active') {
      return completionRate > 80 ? 'View Details' : 'Promote';
    }
    return 'View Results';
  }

  Color get statusColor {
    final colors = [
      const Color(0xFF6B8E23), // Green
      const Color(0xFF1E40AF), // Blue
      const Color(0xFFF97316), // Orange
    ];
    return colors[id % colors.length];
  }
}

class SurveyQuestion {
  final String question;
  final String type;

  const SurveyQuestion({required this.question, required this.type});

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      question: json['question'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'type': type};
  }
}

class SurveyBranch {
  final int id;
  final String name;
  final String address;
  final String createdAt;
  final String updatedAt;

  const SurveyBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyBranch.fromJson(Map<String, dynamic> json) {
    return SurveyBranch(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SurveyResponse {
  final int id;
  final int surveyId;
  final int userId;
  final List<SurveyAnswer> answers;
  final String submittedAt;
  final String createdAt;
  final String updatedAt;

  const SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.userId,
    required this.answers,
    required this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      userId: json['user_id'] as int,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => SurveyAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      submittedAt: json['submitted_at'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'user_id': userId,
      'answers': answers.map((e) => e.toJson()).toList(),
      'submitted_at': submittedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SurveyAnswer {
  final String question;
  final String answer;

  const SurveyAnswer({required this.question, required this.answer});

  factory SurveyAnswer.fromJson(Map<String, dynamic> json) {
    return SurveyAnswer(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}

// Analytics data for charts
class SurveyAnalytics {
  final List<SurveyDataPoint> monthlyData;
  final int totalResponses;
  final int activeSurveys;

  const SurveyAnalytics({
    required this.monthlyData,
    required this.totalResponses,
    required this.activeSurveys,
  });

  factory SurveyAnalytics.fromSurveys(
    List<SurveyAnalysisData> surveys, {
    List<int>? excludeUserIds,
  }) {
    // Generate actual monthly data based on survey responses (excluding manager responses)
    final monthlyData = _generateMonthlyDataFromSurveys(
      surveys,
      excludeUserIds: excludeUserIds,
    );

    final totalResponses = surveys.fold(
      0,
      (sum, survey) =>
          sum + _countNonManagerResponses(survey.responses, excludeUserIds),
    );
    final activeSurveys = surveys.where((s) => s.status == 'active').length;

    return SurveyAnalytics(
      monthlyData: monthlyData,
      totalResponses: totalResponses,
      activeSurveys: activeSurveys,
    );
  }

  static List<SurveyDataPoint> _generateMonthlyDataFromSurveys(
    List<SurveyAnalysisData> surveys, {
    List<int>? excludeUserIds,
  }) {
    // Group responses by month based on creation dates (excluding manager responses)
    final Map<String, int> monthlyResponses = {};

    // Initialize all months with 0 responses
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (final month in months) {
      monthlyResponses[month] = 0;
    }

    // Count responses by month (excluding manager responses)
    for (final survey in surveys) {
      for (final response in survey.responses) {
        // Skip responses from excluded users (managers)
        if (excludeUserIds != null &&
            excludeUserIds.contains(response.userId)) {
          continue;
        }

        try {
          final responseDate = DateTime.parse(response.createdAt);
          final monthIndex = responseDate.month - 1;
          if (monthIndex >= 0 && monthIndex < months.length) {
            final monthName = months[monthIndex];
            monthlyResponses[monthName] =
                (monthlyResponses[monthName] ?? 0) + 1;
          }
        } catch (e) {
          // If date parsing fails, skip this response
          continue;
        }
      }
    }

    // Convert to SurveyDataPoint list (show last 6 months)
    final currentMonth = DateTime.now().month;
    final dataPoints = <SurveyDataPoint>[];

    for (int i = 5; i >= 0; i--) {
      final monthIndex = (currentMonth - 1 - i + 12) % 12;
      final monthName = months[monthIndex];
      final responses = monthlyResponses[monthName] ?? 0;
      dataPoints.add(SurveyDataPoint(month: monthName, responses: responses));
    }

    return dataPoints;
  }

  // Helper method to count responses excluding manager responses
  static int _countNonManagerResponses(
    List<SurveyResponse> responses,
    List<int>? excludeUserIds,
  ) {
    if (excludeUserIds == null) return responses.length;

    return responses
        .where((response) => !excludeUserIds.contains(response.userId))
        .length;
  }
}

class SurveyDataPoint {
  final String month;
  final int responses;

  const SurveyDataPoint({required this.month, required this.responses});
}

// Combined model for survey analysis with branch users data
class SurveyAnalysisWithUsers {
  final SurveyAnalysis surveyAnalysis;
  final int totalUsersInBranch;

  const SurveyAnalysisWithUsers({
    required this.surveyAnalysis,
    required this.totalUsersInBranch,
  });

  // Calculate completion rate for each survey based on total users in branch
  List<SurveyAnalysisDataWithCompletion> get surveysWithCompletion {
    return surveyAnalysis.data.map((survey) {
      final completionRate = survey.calculateCompletionRate(totalUsersInBranch);
      return SurveyAnalysisDataWithCompletion(
        survey: survey,
        completionRate: completionRate,
        totalUsersInBranch: totalUsersInBranch,
      );
    }).toList();
  }
}

// Extended survey data with calculated completion rate
class SurveyAnalysisDataWithCompletion {
  final SurveyAnalysisData survey;
  final double completionRate;
  final int totalUsersInBranch;

  const SurveyAnalysisDataWithCompletion({
    required this.survey,
    required this.completionRate,
    required this.totalUsersInBranch,
  });

  // Get the actual completion rate (responses / total users * 100)
  double get actualCompletionRate => completionRate;

  // Get the actual completion rate excluding managers
  double getActualCompletionRateExcludingManagers(List<int>? excludeUserIds) {
    return survey.calculateCompletionRateExcludingManagers(
      totalUsersInBranch,
      excludeUserIds,
    );
  }

  // Get the number of users who haven't responded (excluding managers)
  int get nonRespondents => totalUsersInBranch - survey.totalResponses;

  // Get completion status text
  String get completionStatusText {
    if (completionRate >= 80) {
      return 'Excellent';
    } else if (completionRate >= 60) {
      return 'Good';
    } else {
      return 'Fair';
    }
  }
}

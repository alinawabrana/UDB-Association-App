class Survey {
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

  const Survey({
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

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
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
}

class SurveyQuestion {
  final String question;
  final String type;
  final List<String>? options;

  const SurveyQuestion({
    required this.question,
    required this.type,
    this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      question: json['question'] as String,
      type: json['type'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((option) => option.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type,
      if (options != null) 'options': options,
    };
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
  final List<Map<String, dynamic>> answers;
  final String createdAt;
  final String updatedAt;

  const SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.userId,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as int,
      surveyId: json['survey_id'] as int,
      userId: json['user_id'] as int,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'survey_id': surveyId,
      'user_id': userId,
      'answers': answers,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class SurveyApiResponse {
  final bool status;
  final String message;
  final List<Survey> data;

  const SurveyApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SurveyApiResponse.fromJson(Map<String, dynamic> json) {
    return SurveyApiResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Survey.fromJson(e as Map<String, dynamic>))
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

// Survey completion status enum
enum SurveyStatus { active, inactive, completed, pending }

// Survey category enum for filtering
enum SurveyCategory { all, completed, uncompleted }

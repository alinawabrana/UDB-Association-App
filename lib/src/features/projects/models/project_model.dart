class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String? tagline;
  final List<String>? images;
  final String? issueDate;
  final String? expireDate;
  final int branchId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final BranchModel branch;
  final List<TaskModel> tasks;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.tagline,
    this.images,
    this.issueDate,
    this.expireDate,
    required this.branchId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.branch,
    required this.tasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      tagline: json['tagline'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : null,
      issueDate: json['issue_date']?.toString(),
      expireDate: json['expire_date']?.toString(),
      branchId: json['branch_id'] as int,
      status: (json['status'] ?? 'active') as String,
      createdAt: (json['created_at'] ?? '') as String,
      updatedAt: (json['updated_at'] ?? '') as String,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : BranchModel(
              id: 0,
              name: '',
              address: '',
              createdAt: '',
              updatedAt: '',
            ),
      tasks:
          (json['tasks'] as List?)
              ?.map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tagline': tagline,
      'images': images,
      'issue_date': issueDate,
      'expire_date': expireDate,
      'branch_id': branchId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'branch': branch.toJson(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}

class BranchModel {
  final int id;
  final String name;
  final String address;
  final String createdAt;
  final String updatedAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      createdAt: (json['created_at'] ?? '') as String,
      updatedAt: (json['updated_at'] ?? '') as String,
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

class TaskModel {
  final int id;
  final String title;
  final String description;
  final int projectId;
  final int assignedTo;
  final String status;
  final String dueDate;
  final int branchId;
  final String createdAt;
  final String updatedAt;
  final ProjectModel? project;
  final BranchModel? branch;
  final AssigneeModel? assignee;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.assignedTo,
    required this.status,
    required this.dueDate,
    required this.branchId,
    required this.createdAt,
    required this.updatedAt,
    this.project,
    this.branch,
    this.assignee,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      projectId: json['project_id'] as int,
      assignedTo: json['assigned_to'] as int,
      status: (json['status'] ?? 'pending') as String,
      dueDate: (json['due_date'] ?? '') as String,
      branchId: json['branch_id'] as int,
      createdAt: (json['created_at'] ?? '') as String,
      updatedAt: (json['updated_at'] ?? '') as String,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      assignee: json['assignee'] != null
          ? AssigneeModel.fromJson(json['assignee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'project_id': projectId,
      'assigned_to': assignedTo,
      'status': status,
      'due_date': dueDate,
      'branch_id': branchId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'project': project?.toJson(),
      'branch': branch?.toJson(),
      'assignee': assignee?.toJson(),
    };
  }
}

class AssigneeModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? provider;
  final String? providerId;
  final String role;
  final bool isApproved;
  final String createdAt;
  final String updatedAt;

  const AssigneeModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.provider,
    this.providerId,
    required this.role,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssigneeModel.fromJson(Map<String, dynamic> json) {
    return AssigneeModel(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      role: (json['role'] ?? 'user') as String,
      isApproved: json['is_approved'] as bool? ?? false,
      createdAt: (json['created_at'] ?? '') as String,
      updatedAt: (json['updated_at'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
      'role': role,
      'is_approved': isApproved,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProjectsResponse {
  final bool status;
  final String message;
  final List<ProjectModel> data;

  const ProjectsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectsResponse.fromJson(Map<String, dynamic> json) {
    return ProjectsResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] ?? '') as String,
      data:
          (json['data'] as List?)
              ?.map(
                (item) => ProjectModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((project) => project.toJson()).toList(),
    };
  }
}

class TasksResponse {
  final bool status;
  final String message;
  final List<TaskModel> data;

  const TasksResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TasksResponse.fromJson(Map<String, dynamic> json) {
    return TasksResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] ?? '') as String,
      data:
          (json['data'] as List?)
              ?.map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((task) => task.toJson()).toList(),
    };
  }
}

class TaskStatusUpdateResponse {
  final bool status;
  final String message;
  final TaskModel? data;

  const TaskStatusUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory TaskStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return TaskStatusUpdateResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] ?? '') as String,
      data: json['data'] != null
          ? TaskModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

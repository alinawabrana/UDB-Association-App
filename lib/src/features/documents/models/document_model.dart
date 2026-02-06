class DocumentModel {
  final int id;
  final String title;
  final String category;
  final String? description;
  final String fileUrl;
  final String downloadUrl;
  final String createdAt;

  const DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.fileUrl,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      downloadUrl: json['download_url'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'file_url': fileUrl,
      'download_url': downloadUrl,
      'created_at': createdAt,
    };
  }
}

class DocumentsResponse {
  final List<DocumentModel> data;
  final Pagination pagination;

  const DocumentsResponse({required this.data, required this.pagination});

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsResponse(
      data: (json['data'] as List)
          .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  const Pagination({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      total: json['total'] as int,
      perPage: json['per_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total': total,
      'per_page': perPage,
      'last_page': lastPage,
    };
  }
}

/// Model for Division (Province/Branch)
class Division {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final String? logoPath; // Asset path or network URL
  final List<Department> departments;

  const Division({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.email,
    this.logoPath,
    this.departments = const [],
  });
}

/// Model for Department
class Department {
  final String id;
  final String name;
  final String divisionId;
  final String? description;
  final String? phone;
  final String? email;
  final String? logoPath;
  final List<Agent> agents;

  const Department({
    required this.id,
    required this.name,
    required this.divisionId,
    this.description,
    this.phone,
    this.email,
    this.logoPath,
    this.agents = const [],
  });
}

/// Model for Agent
class Agent {
  final String id;
  final String name;
  final String? title;
  final String? role;
  final String? department;
  final String? division;
  final String? phone;
  final String? email;
  final String? profileImage;
  final String? province;
  final String? departement;
  final String? commune;
  final String? arrondissement;
  final String? branchName; // Branch name for API-based agents
  final String? function;
  final String? direction;

  const Agent({
    required this.id,
    required this.name,
    this.title,
    this.role,
    this.department,
    this.division,
    this.phone,
    this.email,
    this.profileImage,
    this.province,
    this.departement,
    this.commune,
    this.arrondissement,
    this.branchName,
    this.function,
    this.direction,
  });
}


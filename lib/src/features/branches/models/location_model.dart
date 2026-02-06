/// Model for Location (Province with Departments)
class Location {
  final int id;
  final String country;
  final String province;
  final List<String> departments;

  const Location({
    required this.id,
    required this.country,
    required this.province,
    required this.departments,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      country: json['country'] as String,
      province: json['province'] as String,
      departments: (json['departments'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'province': province,
      'departments': departments,
    };
  }

  static List<Location> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map((e) => Location.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }
}


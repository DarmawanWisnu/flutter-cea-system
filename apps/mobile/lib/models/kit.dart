class Kit {
  final String id;
  final String name;
  final DateTime createdAt;

  Kit({required this.id, required this.name, required this.createdAt});

  factory Kit.fromJson(Map<String, dynamic> j) {
    return Kit(
      id: j['id'],
      name: j['name'],
      createdAt: DateTime.parse(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'createdAt': createdAt.toIso8601String()};
  }
}

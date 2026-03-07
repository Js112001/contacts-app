class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final bool isSynced;
  final int createdAt;
  final int updatedAt;
  final bool isFavorite;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isSynced: (json['isSynced'] ?? 0) == 1,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      isFavorite: (json['isFavorite'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isFavorite': isFavorite,
    };
  }

  factory ContactModel.fromFirestore(Map<String, dynamic> data) {
    return ContactModel(
      id: data['id'] as String,
      name: data['name'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      isSynced: true,
      createdAt: data['createdAt'] as int,
      updatedAt: data['updatedAt'] as int,
      isFavorite: data['isFavorite'] ?? false,
    );
  }
}

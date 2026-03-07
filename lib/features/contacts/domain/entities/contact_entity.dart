import '../../data/models/contact_model.dart';

class ContactEntity extends ContactModel {
  final bool isFavorite;

  ContactEntity({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.isSynced,
    required super.createdAt,
    required super.updatedAt,
    this.isFavorite = false,
  });

  factory ContactEntity.fromModel(ContactModel model) {
    return ContactEntity(
      id: model.id,
      name: model.name,
      phone: model.phone,
      email: model.email,
      isSynced: model.isSynced,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isFavorite: model.isFavorite,
    );
  }

  ContactModel toModel() {
    return ContactModel(
      id: id,
      name: name,
      phone: phone,
      email: email,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFavorite: isFavorite,
    );
  }
}

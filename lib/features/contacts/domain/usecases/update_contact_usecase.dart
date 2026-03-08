import '../entities/contact_entity.dart';
import '../repository/contact_repository.dart';

class UpdateContactUseCase {
  final ContactRepository repository;

  UpdateContactUseCase(this.repository);

  Future<void> call(ContactEntity contact) async {
    await repository.updateContact(contact);
  }
}

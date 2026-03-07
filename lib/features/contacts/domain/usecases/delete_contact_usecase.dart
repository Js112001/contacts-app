import '../repository/contact_repository.dart';

class DeleteContactUseCase {
  final ContactRepository repository;

  DeleteContactUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteContact(id);
  }
}

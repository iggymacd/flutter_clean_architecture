import 'package:dartz/dartz.dart';

import '../../application/interfaces/repository.dart';
import '../../domain/entities/identifiable.dart';
import '../../utilities/error/failures.dart';

class InMemoryRepository<E extends Identifiable> implements Repository<E> {
  static const void unit = null;

  final Map<String, E> entitySet;
  factory InMemoryRepository.fromList(List<E> entities) {
    final map =
        Map<String, E>.fromEntries(entities.map((e) => MapEntry(e.id, e)));
    return InMemoryRepository._(map);
  }

  InMemoryRepository._(this.entitySet);

  @override
  Future<Either<Failure, void>> add(E entity) async {
    entitySet[entity.id] = entity;
    return Future.value(Right(unit));
  }

  @override
  Future<Either<Failure, void>> delete(E entity) {
    entitySet.remove(entity);
    return Future.value(Right(unit));
  }

  @override
  Future<Either<Failure, List<E>>> getAll() {
    final list = entitySet.values.toList();
    return Future.value(Right(list));
  }

  @override
  Future<Either<Failure, E>> getById(UniqueId id) {
    final entity = entitySet[id.value];
    return Future.value(Right(entity));
  }

  @override
  Future<Either<Failure, void>> update(E entity) {
    entitySet[entity.id] = entity;
    return Future.value(Right(unit));
  }
}

import 'package:dartz/dartz.dart';

import '../../domain/entities/identifiable.dart';
import '../../utilities/error/failures.dart';

abstract class Repository<EntityType> {
  Future<Either<Failure, void>> add(EntityType entity);
  Future<Either<Failure, void>> delete(EntityType entity);
  Future<Either<Failure, List<EntityType>>> getAll();
  Future<Either<Failure, EntityType>> getById(UniqueId id);
  Future<Either<Failure, void>> update(EntityType entity);
}

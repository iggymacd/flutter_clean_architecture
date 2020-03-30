import 'package:clean_architecture_template/domain/entities/unique_id.dart';
import 'package:clean_architecture_template/domain/errors/failure.dart';
import 'package:dartz/dartz.dart';

abstract class Repository<EntityType> {
  Future<Either<Failure, EntityType>> getById(UniqueId id);
  Future<Either<Failure, List<EntityType>>> getAll();
  Future<Either<Failure, void>> add(EntityType entity);
  Future<Either<Failure, void>> edit(EntityType entity);
  Future<Either<Failure, void>> delete(EntityType entity);
}

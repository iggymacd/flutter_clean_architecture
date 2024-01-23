import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import '../../application/interfaces/repository.dart';
import '../../domain/entities/identifiable.dart';
import '../../utilities/error/failures.dart';
import '../../utilities/network_info.dart';

class NetworkConnectivityFailure extends Failure {}

class RemoteFirstRepository<Entity extends Identifiable>
    implements Repository<Entity> {
  static final Task<Either<Failure, dynamic>> connectivityFailureTask =
      Task(() => Future.value(Left(NetworkConnectivityFailure())));
  final Repository<Entity> remoteRepository;
  final Repository<Entity> cacheRepository;

  final NetworkInfo networkChecker;

  RemoteFirstRepository({
    required this.networkChecker,
    required this.remoteRepository,
    required this.cacheRepository,
  });

  /// Adds new entity
  ///
  /// Fails if remote fails. Caches only when remote succeeds.
  @override
  Future<Either<Failure, void>> add(Entity entity) {
    final task = Task(() => remoteRepository.add(entity)).bindEither((_) {
      return Task(() => cacheRepository.add(entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) => isConnected ? task : connectivityFailureTask)
        .run();
  }

  /// Delete entity
  ///
  /// Fails is remote fails.
  /// Deletes from cache only when first deleted from remote
  @override
  Future<Either<Failure, void>> delete(Entity entity) {
    final task = Task(() => remoteRepository.delete(entity)).bindEither((_) {
      return Task(() => cacheRepository.delete(entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) => isConnected ? task : connectivityFailureTask)
        .run();
  }

  /// Get all entities
  ///
  /// If remote succeeds results are cached.
  /// If remote fails fallback to cache result.
  @override
  Future<Either<Failure, List<Entity>>> getAll() {
    final cacheTask = Task(() => cacheRepository.getAll());
    final remoteTask = Task(() => remoteRepository.getAll());

    final task = remoteTask.bindEither((list) {
      return Task(() async {
        for (final entity in list) {
          await cacheRepository.add(entity);
        }

        return Right(list);
      });
    }).orDefault(cacheTask);

    return Task(() => networkChecker.isConnected)
        .flatMap((hasConnection) => hasConnection ? task : cacheTask)
        .run();
  }

  /// Get entity by id
  ///
  /// If remote succeeds the entity is cached.
  /// If remote fails fallback to cache result.
  @override
  Future<Either<Failure, Entity>> getById(UniqueId id) {
    final cacheTask = Task(() => cacheRepository.getById(id));
    final remoteTask = Task(() => remoteRepository.getById(id));

    final task = remoteTask.bindEither((entity) {
      return Task(() async {
        await cacheRepository.add(entity);
        return Right(entity);
      });
    }).orDefault(cacheTask);

    return Task(() => networkChecker.isConnected)
        .flatMap((hasConnection) => hasConnection ? task : cacheTask)
        .run();
  }

  /// Update entity
  /// Fails on any remote failure
  /// Caches only when remote update succeeds
  @override
  Future<Either<Failure, void>> update(Entity entity) {
    final task = Task(() => remoteRepository.update(entity)).bindEither((_) {
      return Task(() => cacheRepository.update(entity));
    });

    return Task(() => networkChecker.isConnected)
        .flatMap((isConnected) => isConnected ? task : connectivityFailureTask)
        .run();
  }
}

extension TaskEitherAlternative<T> on Task<Either<Failure, T>> {
  Task<Either<Failure, T>> orDefault(Task<Either<Failure, T>> task) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => task.run(),
            (valueT) => Future.value(Right(valueT)),
          );
        }));
  }
}

extension TaskEitherMonad<T> on Task<Either<Failure, T>> {
  Task<Either<Failure, A>> bindEither<A>(
      Function1<T, Task<Either<Failure, A>>> f) {
    return bind((eitherT) => Task(() {
          return eitherT.fold(
            (failure) => Future.value(Left(failure)),
            (valueT) => f(valueT).run(),
          );
        }));
  }
}

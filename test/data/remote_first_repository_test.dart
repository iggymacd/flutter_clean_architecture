import 'package:clean_architecture_template/application/interfaces/repository.dart';
import 'package:clean_architecture_template/data/respositories/remote_first_repository.dart';
import 'package:clean_architecture_template/domain/entities/identifiable.dart';
import 'package:clean_architecture_template/utilities/error/failures.dart';
import 'package:clean_architecture_template/utilities/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mockito/mockito.dart';

class Todo extends Equatable implements Identifiable {
  final String note;

  @override
  final String id;

  const Todo({
    @required this.note,
    @required this.id,
  });

  @override
  List<Object> get props => [note, id];
}

class MockRemoteRepository extends Mock implements Repository<Todo> {}

class MockLocalRepository extends Mock implements Repository<Todo> {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  RemoteFirstRepository sut;
  MockRemoteRepository mockRemoteRepository;
  MockLocalRepository mockLocalRepository;
  MockNetworkInfo mockNetworkChecker;

  final listEquality = const ListEquality().equals;
  const tEntity = Todo(id: '0', note: '');
  final tUniqueId = UniqueId('');
  final tEntities = [
    const Todo(id: '0', note: ''),
    const Todo(id: '0', note: ''),
    const Todo(id: '0', note: ''),
  ];
  const void unit = null;

  setUp(() {
    mockRemoteRepository = MockRemoteRepository();
    mockLocalRepository = MockLocalRepository();
    mockNetworkChecker = MockNetworkInfo();

    sut = RemoteFirstRepository(
        networkChecker: mockNetworkChecker,
        cacheRepository: mockLocalRepository,
        remoteRepository: mockRemoteRepository);
  });

// ======================== Online tests ========================
  group('Device is online', () {
    setUp(() {
      when(mockNetworkChecker.isConnected).thenAnswer((_) async => true);
    });
    group('add operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        final result = await sut.add(tEntity);
        expect(result, Left(ServerFailure()));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        await sut.add(tEntity);
        verify(mockRemoteRepository.add(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.add(any))
            .thenAnswer((_) async => Right(unit));
        await sut.add(tEntity);
        verify(mockLocalRepository.add(tEntity));
      });
    });

    group('delete operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        final result = await sut.delete(tEntity);
        expect(result, Left(ServerFailure()));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        await sut.delete(tEntity);
        verify(mockRemoteRepository.delete(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.delete(any))
            .thenAnswer((_) async => Right(unit));
        await sut.delete(tEntity);
        verify(mockLocalRepository.delete(tEntity));
      });
    });
    group('update operation', () {
      test('fails when remote repository fails', () async {
        //arrange
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        final result = await sut.update(tEntity);
        expect(result, Left(ServerFailure()));
      });
      test('does not call cache when remote repository fails', () async {
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        await sut.update(tEntity);
        verify(mockRemoteRepository.update(tEntity));
        verifyZeroInteractions(mockLocalRepository);
      });

      test('calls cache when remote repository succeeds', () async {
        when(mockRemoteRepository.update(any))
            .thenAnswer((_) async => Right(unit));
        await sut.update(tEntity);
        verify(mockLocalRepository.update(tEntity));
      });
    });

    // READ OPERATIONS
    group('get all operation', () {
      test('falls back to cache when remote fails', () async {
        when(mockRemoteRepository.getAll())
            .thenAnswer((_) async => Left(ServerFailure()));
        when(mockLocalRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        final result = await sut.getAll();
        final entities = result.fold((_) => [], (v) => v);

        assert(result.isRight());
        assert(listEquality(entities, tEntities));
        verify(mockRemoteRepository.getAll());
        verify(mockLocalRepository.getAll());
      });

      test(
          'caches every entity gotten from remote when remote fetch is succesful',
          () async {
        when(mockRemoteRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        final result = await sut.getAll();
        assert(result.isRight());
        verify(mockLocalRepository.add(any)).called(tEntities.length);
      });
    });
    group('get by id', () {
      test('falls back to cache when remote fails', () async {
        when(mockRemoteRepository.getById(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        when(mockLocalRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);

        expect(result, Right(tEntity));
        verify(mockRemoteRepository.getById(tUniqueId));
        verify(mockLocalRepository.getById(tUniqueId));
      });

      test(
          'caches every entity gotten from remote when remote fetch is succesful',
          () async {
        when(mockRemoteRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);
        assert(result.isRight());
        verify(mockLocalRepository.add(any)).called(1);
      });
    });
  });

// ======================== Offline tests ========================
  group('Device is offline', () {
    setUp(() {
      when(mockNetworkChecker.isConnected).thenAnswer((_) async => false);
    });
    group('get by id', () {
      test('calls cache directly if internet connectivity is down', () async {
        when(mockLocalRepository.getById(any))
            .thenAnswer((_) async => Right(tEntity));

        final result = await sut.getById(tUniqueId);

        expect(result, Right(tEntity));
        verify(mockLocalRepository.getById(tUniqueId));
        verifyZeroInteractions(mockRemoteRepository);
      });
    });

    group('get all', () {
      test('calls cache directly if internet connectivity is down', () async {
        when(mockLocalRepository.getAll())
            .thenAnswer((_) async => Right(tEntities));

        await sut.getAll();

        verify(mockLocalRepository.getAll());
        verifyZeroInteractions(mockRemoteRepository);
      });
    });

    group('add operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.add(tEntity);
        verifyZeroInteractions(mockRemoteRepository);
        expect(result, Left(NetworkConnectivityFailure()));
      });
    });

    group('delete operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.delete(tEntity);
        verifyZeroInteractions(mockRemoteRepository);
        expect(result, Left(NetworkConnectivityFailure()));
      });
    });

    group('update operation', () {
      test('fails withouth calling remote when connectiviy is down', () async {
        final result = await sut.update(tEntity);
        verifyZeroInteractions(mockRemoteRepository);
        expect(result, Left(NetworkConnectivityFailure()));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeleton/core/error/failure.dart';
import 'package:skeleton/core/usecase/usecase.dart';

class _Double extends UseCase<int, int> {
  @override
  Future<Either<Failure, int>> call(int params) async =>
      params < 0 ? const Left(Failure.validation()) : Right(params * 2);
}

class _Now extends UseCase<String, NoParams> {
  @override
  Future<Either<Failure, String>> call(NoParams params) async =>
      const Right('ok');
}

void main() {
  test('returns Right on success', () async {
    expect(await _Double()(2), const Right<Failure, int>(4));
  });

  test('returns Left on failure', () async {
    expect(await _Double()(-1), const Left<Failure, int>(Failure.validation()));
  });

  test('NoParams works as a no-argument contract', () async {
    expect(await _Now()(const NoParams()), const Right<Failure, String>('ok'));
  });
}

/// Typed failures the data layer maps Dio/parse errors into, so presentation
/// code never handles raw exceptions.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Could not reach the server. Is the API running?');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

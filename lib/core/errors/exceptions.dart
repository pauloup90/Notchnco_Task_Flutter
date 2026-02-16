
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
  
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation failed']);
  
  @override
  String toString() => 'ValidationException: $message';
}

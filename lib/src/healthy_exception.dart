import 'package:equatable/equatable.dart';

/// An [Ecxeption], that is thrown, when an error appears in this plugin.
class HealthyException with EquatableMixin implements Exception {
  const HealthyException(this.code, {this.message, this.details});

  final String code;
  final String? message;
  final String? details;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [code, message, details];
}

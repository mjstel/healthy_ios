import 'package:equatable/equatable.dart';
import 'package:healthy_ios/healthy_ios.dart';
import 'package:healthy_ios/src/healthy_hk_types.dart';

/// A class that represents the results of the [getHealthSamplesForCategroyType] method
/// on the [HealthStore]
class HKCategorySample with EquatableMixin {
  HKCategorySample(this.type, this.from, this.to, this.value);

  final num value;
  final HKCategoryType type;
  final DateTime from;
  final DateTime to;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [value, type, from, to];
}

/// A class that represents the results of the [getHealthSamplesForCQuantityType] method
/// on the [HealthStore]
class HKQuantitySample with EquatableMixin {
  HKQuantitySample(this.type, this.unit, this.from, this.to, this.value);

  final num value;
  final HKQuantityType type;
  final String unit;
  final DateTime from;
  final DateTime to;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [value, type, unit, from, to];
}

/// A class that represents the results of the [getHealthStatisticsForType] method
/// on the [HealthStore]
class HKStatistics with EquatableMixin {
  HKStatistics(this.type, this.unit, this.from, this.to,
      {this.sum, this.avg, this.max, this.min});

  final num? sum;
  final num? avg;
  final num? min;
  final num? max;
  final HKQuantityType type;
  final String unit;
  final DateTime from;
  final DateTime to;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [sum, avg, min, max, type, unit, from, to];
}

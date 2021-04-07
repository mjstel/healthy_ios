import 'package:equatable/equatable.dart';

enum HKQuantityType {
  ActiveEnergyBurned,
  BasalEnergyBurned,
  BloodGlucose,
  OxygenSaturation,
  BloodPressureDiastolic,
  BloodPressureSystolic,
  BodyFatPercentage,
  BodyMassIndex,
  BodyTemperature,
  HeartRate,
  Height,
  RestingHeartRate,
  StepCount,
  WaistCircumference,
  WalkingHeartRateAverage,
  BodyMass,
  FlightsClimbed,
  DistanceWalkingRunning,
  DietaryWater,
}
enum HKCategoryType {
  MindfulSession,
  SleepAnalysis,
}

extension HKQuantityTypeX on HKQuantityType {
  String identifier() =>
      'HKQuantityTypeIdentifier' + toString().split('.').last;
  HKQuantityTypeUnitTuple withUnit(String unit) =>
      HKQuantityTypeUnitTuple(this, unit);
}

extension HKCategoryTypeX on HKCategoryType {
  String identifier() =>
      'HKCategoryTypeIdentifier' + toString().split('.').last;
}

class HKQuantityTypeUnitTuple with EquatableMixin {
  final HKQuantityType type;
  final String unit;

  const HKQuantityTypeUnitTuple(this.type, this.unit);

  Map<String, dynamic> toMap() {
    return {
      'type': type.identifier(),
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [type, unit];
}

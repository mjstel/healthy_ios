import 'package:equatable/equatable.dart';

/// All available HealthKit HKQuantityType types
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
  HeartRateVariabilitySDNN,
  EnvironmentalAudioExposure,
  HeadphoneAudioExposure,
}

/// All available HealthKit HKCategoryType types
enum HKCategoryType {
  MindfulSession,
  SleepAnalysis,
}

/// A class to create a tuple of [HKQuantityType] and a [String] that matches
/// a unit, which we want to measure the [type] in.
class HKQuantityTypeUnitTuple with EquatableMixin {
  final String type;
  final String unit;

  const HKQuantityTypeUnitTuple(this.type, this.unit);

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [type, unit];
}

/// Extensions for the [HKQuantityType]
extension HKQuantityTypeX on HKQuantityType {
  String get identifier =>
      'HKQuantityTypeIdentifier' + toString().split('.').last;

  HKQuantityTypeUnitTuple withUnit(String unit) =>
      HKQuantityTypeUnitTuple(identifier, unit);
}

/// Extensions for the [HKCategoryType]
extension HKCategoryTypeX on HKCategoryType {
  String get identifier =>
      'HKCategoryTypeIdentifier' + toString().split('.').last;
}

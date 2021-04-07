# healthy_ios

A small wrapper for sample- and statisticsqueries against HealthKit that is inspired by [health library from CACHET](https://pub.dev/packages/health).

## Usage

1. add `healthy_ios` to your `pubspec.yaml`

2. Add the following entries to your `plist.info`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Add a reason why you need this.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Add a reason why you need this.</string>
```

3. Open your project and add "HealthKit" as an capability.

### After the setup

Now you can instanciate a HealthStore object:
```dart
final store = HealthStore();
```

Before you query for data make sure, that you ask the user for their permission by calling:
```dart
final stepType = HKQuantityType.StepCount.identifier();
final permissionsGranted = await store.requestTypes([stepType]);
```

Now you can query for the samples. If you query for QuantityTypes you need to provide a tuple of the Type and the unit you want to query for. There is an extension function on the HKQuantityType, so you can do:
```dart
final now = DateTime.now();
final samples = await store.getHealthSamplesForQuantityType(
  start: now.subtract(Duration(days: 2)),
  end: now,
  types: [ 
    // manually constructing the tuple
    HKQuantityTypeUnitTuple(HKQuantityType.StepCount, 'count'),
    // using the extension
    HKQuantityType.HeartRate.withUnit('count/min'),
  ]);
```

If you are querying for CategoryTypes, you don't pass a unit, therefore the value property of the result contains the enum value of the subtype.[[See SleepAnalysis for example]](https://developer.apple.com/documentation/healthkit/hkcategoryvaluesleepanalysis)

Getting statistics data is also very easy. You need to additionally pass an intervall, which is used to accumulate the statistics and and achorDate, which is used to determine where to start an interval [[See here for more information](https://developer.apple.com/documentation/healthkit/hkstatisticscollectionquery/1615241-anchordate)]:
```dart
final now = DateTime.now();
final start = DateTime(now.year, now.month, now.day, 0, 0);
final samples = await store.getHealthStatisticsForType(
  start: start,
  end: now,
  interval: StatisticsInterval(hour: 1),
  anchor: start,
  types: [
    HKQuantityType.StepCount.withUnit('count'),
  ]);
```
The resulting statistics object has 4 value fields (sum, avg, min, max). If the HKQuantityType is cumulative, only sum will hold a value. If the type is dicrete avg, min, and max will hold a value. 

### Aditional Information:
 * For valid units see [here](https://developer.apple.com/documentation/healthkit/hkunit)

## Supported Data Types
Quantitative Types:
 * ActiveEnergyBurned
 * BasalEnergyBurned
 * BloodGlucose
 * OxygenSaturation
 * BloodPressureDiastolic
 * BloodPressureSystolic
 * BodyFatPercentage
 * BodyMassIndex
 * BodyTemperature
 * HeartRate
 * Height
 * RestingHeartRate
 * StepCount
 * WaistCircumference
 * WalkingHeartRateAverage
 * BodyMass
 * FlightsClimbed
 * DistanceWalkingRunning
 * DietaryWater

Categorical Types: 
 * MindfulSession
 * SleepAnalysis
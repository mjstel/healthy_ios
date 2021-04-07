import 'package:flutter/services.dart';
import 'package:healthy_ios/healthy_ios.dart';
import 'package:healthy_ios/src/healthy_hk_types.dart';

import './healthy_data_record.dart';
import 'statistics_interval.dart';

class HealthStore {
  static const MethodChannel _channel = MethodChannel('healthy_ios');

  Future<bool> requestTypes(Iterable<String> typeIdentifiers) async {
    final types = typeIdentifiers.toList(growable: false);
    return await _channel.invokeMethod('requestTypes', {'types': types});
  }

  Future<Iterable<HKQuantitySample>> getHealthSamplesForQuantityType({
    required DateTime start,
    required DateTime end,
    required Iterable<HKQuantityTypeUnitTuple> types,
  }) async {
    final result = <HKQuantitySample>{};

    for (final tuple in types) {
      final fetchedSample = await _query(
        'requestQuantitativeData',
        start: start,
        end: end,
        args: tuple.toMap(),
      );
      final records = fetchedSample.map(
        (sample) => HKQuantitySample(
          tuple.type,
          tuple.unit,
          DateTime.fromMillisecondsSinceEpoch(sample['from'] as int),
          DateTime.fromMillisecondsSinceEpoch(sample['to'] as int),
          sample['value'] as num,
        ),
      );
      result.addAll(records);
    }
    return result;
  }

  Future<Iterable<HKCategorySample>> getHealthSamplesForCategroyType({
    required DateTime start,
    required DateTime end,
    required Iterable<HKCategoryType> types,
  }) async {
    final result = <HKCategorySample>{};
    for (final type in types) {
      final fetchedSample = await _query(
        'requestCategoricalData',
        start: start,
        end: end,
        args: {
          'type': type.identifier,
        },
      );
      final records = fetchedSample.map(
        (sample) => HKCategorySample(
          type,
          DateTime.fromMillisecondsSinceEpoch(sample['from'] as int),
          DateTime.fromMillisecondsSinceEpoch(sample['to'] as int),
          sample['value'] as num,
        ),
      );
      result.addAll(records);
    }
    return result;
  }

  Future<Iterable<HKStatistics>> getHealthStatisticsForType({
    required DateTime start,
    required DateTime end,
    required StatisticsInterval interval,
    required DateTime anchor,
    required Iterable<HKQuantityTypeUnitTuple> types,
  }) async {
    final records = <HKStatistics>{};

    for (final tuple in types) {
      final fetchedSample = await _query(
        'requestStatisticsData',
        start: start,
        end: end,
        args: {
          ...tuple.toMap(),
          'dateComponents': interval.toMap(),
          'anchor': anchor.millisecondsSinceEpoch,
        },
      );
      final result = fetchedSample.map(
        (sample) => HKStatistics(
          tuple.type,
          tuple.unit,
          DateTime.fromMillisecondsSinceEpoch(sample['from'] as int),
          DateTime.fromMillisecondsSinceEpoch(sample['to'] as int),
          sum: sample['sum'] as num?,
          avg: sample['avg'] as num?,
          max: sample['max'] as num?,
          min: sample['min'] as num?,
        ),
      );
      records.addAll(result);
    }
    return records;
  }

  Future<Iterable<dynamic>> _query(String method,
      {required DateTime start,
      required DateTime end,
      Map<String, dynamic> args = const {}}) async {
    final arguments = {
      ...args,
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch
    };
    try {
      return await _channel.invokeMethod(
            method,
            arguments,
          ) ??
          [];
    } on PlatformException catch (e) {
      throw HealthyException(e.code, message: e.message, details: e.details);
    }
  }
}

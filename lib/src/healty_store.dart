import 'package:flutter/services.dart';
import 'package:healthy_ios/healthy_ios.dart';
import 'package:healthy_ios/src/healthy_hk_types.dart';

import './healthy_data_record.dart';
import 'statistics_interval.dart';

/// A class that provides Methods to access HealthKit
class HealthStore {
  static const MethodChannel _channel = MethodChannel('healthy_ios');

  /// Returns true if the user has seen the dialog to give the permissions for requested informations
  ///
  /// Request specific [HKQuantityType]s and [HKCategoryType]s
  /// by passing all [typeIdentifiers].
  ///
  /// The returned boolean does not implies, that the user granted or denied
  /// the access to the requested data types, but if the dialog to give the
  /// permissions was shown.
  Future<bool> requestTypes(Iterable<String> typeIdentifiers) async {
    final types = typeIdentifiers.toList(growable: false);
    return await _channel.invokeMethod('requestTypes', {'types': types});
  }

  /// Returns a list of all samples for the requested types in a given time range.
  ///
  /// The returned [Iterable] includes all samples in the time range, where the
  /// starting point of each sample lays strictly between [start] and [end].
  /// The Unit for each sample is definied by the unit you pass into the
  /// [HKQuantityTypeUnitTuple] for the requested [HKQuantityType].
  ///
  /// Please remember to first ask for permission to access the [types] via the
  /// [requestTypes] method.
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

  /// Returns a list of all samples for the requested types in a given time range.
  ///
  /// The returned [Iterable] includes all samples in the time range, where the
  /// starting point of each sample lays strictly between [start] and [end].
  ///
  /// Please remember to first ask for permission to access the [types] via the
  /// [requestTypes] method.
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

  /// Returns a list of all the statistics for the requested types in a given time range
  /// for the specified interval.
  ///
  /// The returned [Iterable] includes statistics in the time range, where the
  /// starting point of each sample lays strictly between [start] and [end].
  /// The Unit for each sample is definied by the unit you pass into the
  /// [HKQuantityTypeUnitTuple] for the requested [HKQuantityType].
  /// The Interval is specified by the [interval]. The [anchor] timestamp can
  /// be considered as the starting point of the interval.
  ///
  /// E.g.: The interval is 1 hour and the anchor date is 2021-04-14T10:38 and
  /// your start date is 2021-04-16T11:00, your statistcs will be calculated for
  /// each hour starting with 2021-04-16T11:38 - 2021-04-16T12:38, 2021-04-16T12:38 -
  /// 2021-04-16T13:38 ... and so on.
  ///
  /// Please remember to first ask for permission to access the [types] via the
  /// [requestTypes] method.
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

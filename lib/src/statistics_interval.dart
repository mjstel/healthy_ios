import 'package:equatable/equatable.dart';
import 'package:healthy_ios/healthy_ios.dart';

/// A class to specifiy an interval for the getHealthStatisticsForType method
/// on the [HealthStore]
class StatisticsInterval extends Equatable {
  final int day;
  final int hour;
  final int minute;

  StatisticsInterval({this.day = 0, this.hour = 0, this.minute = 0})
      : assert(day + hour + minute > 0, 'You cannot pass an empty interval');

  @override
  List<Object?> get props => [day, hour, minute];

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'hour': hour,
      'minute': minute,
    };
  }
}

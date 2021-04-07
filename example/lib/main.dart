import 'package:flutter/material.dart';
import 'package:healthy_ios/healthy_ios.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isLoading = false;
  var _result = '';
  final store = HealthStore();

  @override
  void initState() {
    super.initState();
  }

  void _fetchCategoricalSamples() async {
    final types = [
      HKCategoricalType.SleepAnalysis,
      HKCategoricalType.MindfulSession
    ];
    final granted = await store.requestTypes(types.map((e) => e.identifier()));

    setState(() {
      isLoading = true;
    });

    try {
      if (granted) {
        final now = DateTime.now();
        final samples = await store.getHealthSamplesForCategroyType(
            start: now.subtract(Duration(days: 5)), end: now, types: types);
        setState(() {
          _result = samples.map((e) => e.toString()).join('\n');
        });
      }
    } on HealthyException catch (e) {
      setState(() {
        _result = e.code;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchQuantitySamples() async {
    final types = [HKQuantityType.StepCount, HKQuantityType.ActiveEnergyBurned]
        .map((e) => e.identifier());
    final granted = await store.requestTypes(types);

    setState(() {
      isLoading = true;
    });

    try {
      if (granted) {
        final now = DateTime.now();
        final samples = await store.getHealthSamplesForQuantityType(
            start: now.subtract(Duration(days: 2)),
            end: now,
            types: [
              HKQuantityTypeUnitTuple(HKQuantityType.StepCount, 'count'),
            ]);

        setState(() {
          _result = samples.map((e) => e.toString()).join('\n');
        });
      }
    } on HealthyException catch (e) {
      setState(() {
        _result = e.code;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _fetchStatisticalData() async {
    final types = [HKQuantityType.StepCount, HKQuantityType.HeartRate]
        .map((e) => e.identifier());
    final granted = await store.requestTypes(types);

    setState(() {
      isLoading = true;
    });

    try {
      if (granted) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day, 0, 0);
        final samples = await store.getHealthStatisticsForType(
          start: start,
          end: now,
          interval: StatisticsInterval(hour: 1),
          anchor: start,
          types: [
            HKQuantityType.StepCount.withUnit('count'),
            HKQuantityType.HeartRate.withUnit('count/min'),
          ],
        );

        setState(() {
          _result = samples.map((e) => e.toString()).join('\n');
        });
      }
    } on HealthyException catch (e) {
      setState(() {
        _result = e.code;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: isLoading
            ? const CircularProgressIndicator()
            : Center(
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: _fetchQuantitySamples,
                            child: Text('Sample')),
                        ElevatedButton(
                            onPressed: _fetchCategoricalSamples,
                            child: Text('Categorical')),
                        ElevatedButton(
                            onPressed: _fetchStatisticalData,
                            child: Text('Statistical')),
                      ],
                    ),
                    Text(_result),
                  ],
                )),
              ),
      ),
    );
  }
}

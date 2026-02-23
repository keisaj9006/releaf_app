// usuń niepotrzebny import 'labirynth_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class LabirynthStatsScreen extends StatefulWidget {
  const LabirynthStatsScreen({super.key});

  @override
  State<LabirynthStatsScreen> createState() => _LabirynthStatsScreenState();
}

class _LabirynthStatsScreenState extends State<LabirynthStatsScreen> {
  List<FlSpot> timePoints = [];
  List<FlSpot> collisionPoints = [];
  double averageTime = 0;
  int totalCollisions = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<FlSpot> tempTime = [];
    List<FlSpot> tempCollisions = [];
    double totalTime = 0;
    int collisionsSum = 0;
    int count = 0;

    for (int i = 1; i <= 50; i++) {
      int? time = prefs.getInt('labirynth_stats_time_$i');
      int? collisions = prefs.getInt('labirynth_stats_collisions_$i');

      if (time != null && collisions != null) {
        tempTime.add(FlSpot(i.toDouble(), time.toDouble()));
        tempCollisions.add(FlSpot(i.toDouble(), collisions.toDouble()));
        totalTime += time;
        collisionsSum += collisions;
        count++;
      }
    }

    setState(() {
      timePoints = tempTime;
      collisionPoints = tempCollisions;
      averageTime = count > 0 ? totalTime / count : 0;
      totalCollisions = collisionsSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7EB),
      appBar: AppBar(
        title: const Text('📈 Labirynth Stats'),
        backgroundColor: const Color(0xFF154314),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFCF6DB)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFFCF6DB),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Average time: ${averageTime.toStringAsFixed(1)}s',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
            ),
            Text(
              'Total collisions: $totalCollisions',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Time per level',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            timePoints.isEmpty
                ? const Text(
                  'No data yet.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                )
                : SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: timePoints,
                          isCurved: true,
                          color: Colors.green,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 24),
            const Text(
              'Collisions per level',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            collisionPoints.isEmpty
                ? const Text(
                  'No data yet.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                )
                : SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: collisionPoints,
                          isCurved: true,
                          color: Colors.red,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

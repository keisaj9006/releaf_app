import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class MemoryStatsScreen extends StatefulWidget {
  const MemoryStatsScreen({super.key});

  @override
  State<MemoryStatsScreen> createState() => _MemoryStatsScreenState();
}

class _MemoryStatsScreenState extends State<MemoryStatsScreen> {
  List<BarChartGroupData> timeBarData = [];
  List<FlSpot> mistakeSpots = [];
  bool showLast10 = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> stats = [];

    for (int level = 1; level <= 50; level++) {
      int? time = prefs.getInt('memory_stats_time_$level');
      int? mistakes = prefs.getInt('memory_stats_mistakes_$level');
      if (time != null && mistakes != null) {
        stats.add({'level': level, 'time': time, 'mistakes': mistakes});
      }
    }

    if (showLast10 && stats.length > 10) {
      stats = stats.sublist(stats.length - 10);
    }

    setState(() {
      timeBarData =
          stats
              .map(
                (e) => BarChartGroupData(
                  x: e['level'],
                  barRods: [BarChartRodData(toY: e['time'].toDouble())],
                ),
              )
              .toList();

      mistakeSpots =
          stats
              .map(
                (e) => FlSpot(e['level'].toDouble(), e['mistakes'].toDouble()),
              )
              .toList();
    });
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 50; i++) {
      await prefs.remove('memory_stats_time_$i');
      await prefs.remove('memory_stats_mistakes_$i');
    }
    setState(() {
      timeBarData = [];
      mistakeSpots = [];
    });
  }

  Widget _buildChart() {
    if (timeBarData.isEmpty) {
      return const Center(
        child: Text('No stats yet', style: TextStyle(fontFamily: 'Poppins')),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              barGroups: timeBarData,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget:
                        (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
          LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: mistakeSpots,
                  isCurved: true,
                  color: Colors.redAccent,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memory Game Stats',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF154314),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Reset Stats',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Reset All Stats"),
                      content: const Text(
                        "Are you sure you want to delete all memory game stats?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Reset"),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await _resetStats();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show only last 10 levels',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                Switch(
                  value: showLast10,
                  onChanged: (value) {
                    setState(() {
                      showLast10 = value;
                    });
                    _loadStats();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '⏱️ Time per Level (bars) & ❌ Mistakes (red line)',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildChart(),
          ],
        ),
      ),
    );
  }
}

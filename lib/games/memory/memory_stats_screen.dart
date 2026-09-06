import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../theme/releaf_design_tokens.dart';

class MemoryStatsScreen extends StatefulWidget {
  const MemoryStatsScreen({super.key});

  @override
  State<MemoryStatsScreen> createState() => _MemoryStatsScreenState();
}

class _MemoryStatsScreenState extends State<MemoryStatsScreen> {
  List<_MemoryLevelStat> _allStats = const [];
  bool _showLast10 = true;

  List<_MemoryLevelStat> get _visibleStats {
    if (!_showLast10 || _allStats.length <= 10) return _allStats;
    return _allStats.sublist(_allStats.length - 10);
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = <_MemoryLevelStat>[];

    for (var level = 1; level <= 50; level++) {
      final time = prefs.getInt('memory_stats_time_$level');
      final mistakes = prefs.getInt('memory_stats_mistakes_$level');
      if (time == null || mistakes == null) continue;
      stats.add(
        _MemoryLevelStat(
          level: level,
          timeSeconds: time,
          mistakes: mistakes,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _allStats = stats);
  }

  Future<void> _resetStats() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ReleafColors.backgroundRaised,
        title: const Text('Reset Memory stats?'),
        content: const Text(
          'This removes saved completion time and mistake history for Memory levels. Your current Memory level is kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep stats'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset stats'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    for (var level = 1; level <= 50; level++) {
      await prefs.remove('memory_stats_time_$level');
      await prefs.remove('memory_stats_mistakes_$level');
    }

    if (!mounted) return;
    setState(() => _allStats = const []);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _visibleStats;
    final bestTime = _allStats.isEmpty
        ? null
        : _allStats.map((item) => item.timeSeconds).reduce((a, b) => a < b ? a : b);
    final fewestMistakes = _allStats.isEmpty
        ? null
        : _allStats.map((item) => item.mistakes).reduce((a, b) => a < b ? a : b);

    return Theme(
      data: AppTheme.premiumDark(),
      child: Scaffold(
        backgroundColor: ReleafColors.background,
        appBar: AppBar(
          backgroundColor: ReleafColors.background,
          surfaceTintColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEMORY',
                style: ReleafTypography.eyebrow.copyWith(
                  color: const Color(0xFF91A4EF),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Training history',
                style: ReleafTypography.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              key: const Key('memory-stats-reset'),
              tooltip: 'Reset Memory stats',
              onPressed: _allStats.isEmpty ? null : _resetStats,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              ReleafSpacing.screen,
              ReleafSpacing.md,
              ReleafSpacing.screen,
              ReleafSpacing.xxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryRow(
                      completed: _allStats.length,
                      bestTime: bestTime,
                      fewestMistakes: fewestMistakes,
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    _RangeToggle(
                      showLast10: _showLast10,
                      enabled: _allStats.length > 10,
                      onChanged: (value) => setState(() => _showLast10 = value),
                    ),
                    const SizedBox(height: ReleafSpacing.lg),
                    if (stats.isEmpty)
                      const _EmptyStats()
                    else ...[
                      _ChartCard(
                        title: 'Completion time',
                        subtitle: 'Seconds used on each completed level.',
                        child: _TimeChart(stats: stats),
                      ),
                      const SizedBox(height: ReleafSpacing.md),
                      _ChartCard(
                        title: 'Mistakes',
                        subtitle:
                            'Fewer mismatched pairs means more efficient recall.',
                        child: _MistakeChart(stats: stats),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryLevelStat {
  const _MemoryLevelStat({
    required this.level,
    required this.timeSeconds,
    required this.mistakes,
  });

  final int level;
  final int timeSeconds;
  final int mistakes;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.completed,
    required this.bestTime,
    required this.fewestMistakes,
  });

  final int completed;
  final int? bestTime;
  final int? fewestMistakes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: ReleafSpacing.xs,
      runSpacing: ReleafSpacing.xs,
      children: [
        _SummaryPill(label: 'LEVELS', value: '$completed'),
        _SummaryPill(
          label: 'BEST TIME',
          value: bestTime == null ? '—' : '${bestTime}s',
        ),
        _SummaryPill(
          label: 'FEWEST ERRORS',
          value: fewestMistakes?.toString() ?? '—',
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151A26),
        borderRadius: BorderRadius.circular(ReleafRadii.pill),
        border: Border.all(
          color: const Color(0xFF91A4EF).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textMuted,
              fontSize: 9,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            value,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({
    required this.showLast10,
    required this.enabled,
    required this.onChanged,
  });

  final bool showLast10;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ReleafSpacing.md,
        vertical: ReleafSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.medium),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history_rounded,
            color: Color(0xFF91A4EF),
            size: 20,
          ),
          const SizedBox(width: ReleafSpacing.sm),
          Expanded(
            child: Text(
              'Show only the latest 10 completed levels',
              style: ReleafTypography.body.copyWith(
                color: enabled
                    ? ReleafColors.textPrimary
                    : ReleafColors.textMuted,
              ),
            ),
          ),
          Switch.adaptive(
            value: showLast10 && enabled,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ReleafSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xEE10151D),
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(
          color: const Color(0xFF91A4EF).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ReleafTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ReleafTypography.meta.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
          const SizedBox(height: ReleafSpacing.lg),
          SizedBox(height: 250, child: child),
        ],
      ),
    );
  }
}

class _TimeChart extends StatelessWidget {
  const _TimeChart({required this.stats});

  final List<_MemoryLevelStat> stats;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: ReleafColors.borderSoft,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        barTouchData: BarTouchData(enabled: true),
        barGroups: [
          for (final item in stats)
            BarChartGroupData(
              x: item.level,
              barRods: [
                BarChartRodData(
                  toY: item.timeSeconds.toDouble(),
                  width: 12,
                  color: const Color(0xFF91A4EF),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MistakeChart extends StatelessWidget {
  const _MistakeChart({required this.stats});

  final List<_MemoryLevelStat> stats;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: ReleafColors.borderSoft,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _titles(),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (final item in stats)
                FlSpot(item.level.toDouble(), item.mistakes.toDouble()),
            ],
            isCurved: true,
            barWidth: 3,
            color: const Color(0xFFD490B9),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFD490B9).withValues(alpha: 0.08),
            ),
            dotData: FlDotData(show: stats.length <= 10),
          ),
        ],
      ),
    );
  }
}

FlTitlesData _titles() {
  return FlTitlesData(
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 34,
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) {
          final level = value.toInt();
          return Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              'L$level',
              style: ReleafTypography.meta.copyWith(
                color: ReleafColors.textMuted,
                fontSize: 9,
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('memory-stats-empty'),
      padding: const EdgeInsets.all(ReleafSpacing.xl),
      decoration: BoxDecoration(
        color: ReleafColors.surfaceSoft,
        borderRadius: BorderRadius.circular(ReleafRadii.extraLarge),
        border: Border.all(color: ReleafColors.borderSoft),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.insights_outlined,
            color: Color(0xFF91A4EF),
            size: 38,
          ),
          const SizedBox(height: ReleafSpacing.sm),
          Text(
            'No completed levels yet',
            style: ReleafTypography.cardTitle,
          ),
          const SizedBox(height: 4),
          Text(
            'Finish a Memory level and Releaf will show your time and mistake trend here.',
            textAlign: TextAlign.center,
            style: ReleafTypography.body.copyWith(
              color: ReleafColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

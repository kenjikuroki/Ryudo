import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import '../data/database_provider.dart';
import 'game_provider.dart';
import 'dashboard_provider.dart';
import 'game_settings_provider.dart';
import '../../monetization/presentation/ad_banner_widget.dart';
import '../../monetization/application/billing_provider.dart';
import 'stylish_confirm_dialog.dart';
import '../../monetization/presentation/premium_upgrade_dialog.dart';
import '../../../app/responsive_layout.dart';
import 'package:archery/l10n/gen/app_localizations.dart';

// Providers moved to dashboard_provider.dart

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSessions = ref.watch(recentSessionsProvider);
    final globalStats = ref.watch(globalStatsProvider);
    final homeMode = ref.watch(homeModeProvider);
    final isRound = homeMode == GameMode.round;

    final backgroundColor = isRound ? Colors.indigo.shade50 : Colors.grey.shade50;
    final primaryTextColor = isRound ? Colors.indigo.shade900 : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        actions: [
          _PremiumButton(),
        ],
      ),
      body: ResponsiveLayout(
        backgroundColor: backgroundColor,
        child: CustomScrollView(
          slivers: [
            // Mode Select Buttons (Dedicated Area)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeToggleButton(
                          isActive: !isRound,
                          icon: Icons.all_inclusive,
                          label: AppLocalizations.of(context)!.freePractice,
                          activeColor: isRound ? Colors.indigo : Colors.grey.shade700,
                          onTap: () {
                            if (isRound) {
                              ref.read(gameSettingsNotifierProvider.notifier).updateMode(GameMode.unlimited);
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        _ModeToggleButton(
                          isActive: isRound,
                          icon: Icons.timer,
                          label: AppLocalizations.of(context)!.competition,
                          activeColor: isRound ? Colors.indigo : Colors.grey.shade700,
                          onTap: () {
                            if (!isRound) {
                              ref.read(gameSettingsNotifierProvider.notifier).updateMode(GameMode.round);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // A. Score Trend Graph & Stats
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offset = isRound 
                    ? Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(animation)
                    : Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Padding(
                  key: ValueKey(homeMode),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildTrendChart(context, recentSessions, isRound),
                      ),
                      globalStats.when(
                        data: (stats) => _buildStatsSummary(context, stats, isRound),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                AppLocalizations.of(context)!.recentSessions,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // C. Recent Sessions List (Grouped by Month)
          recentSessions.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text(AppLocalizations.of(context)!.noSessionsRecorded)),
                  ),
                );
              }

              // Group by "yyyy/MM"
              final grouped = <String, List<SessionWithStats>>{};
              for (var s in sessions) {
                final monthKey = DateFormat('yyyy/MM').format(s.session.createdAt);
                grouped.putIfAbsent(monthKey, () => []).add(s);
              }
              
              final sortedMonths = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monthKey = sortedMonths[index];
                    final monthSessions = grouped[monthKey]!;
                    final monthDate = DateFormat('yyyy/MM').parse(monthKey);
                    final locale = Localizations.localeOf(context).toString();
                   final format = locale.startsWith('ja') ? 'yyyy年 MMMM' : 'MMMM yyyy';
                   final displayName = DateFormat(format, locale).format(monthDate);

                    return Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: index == 0, // Expand the latest month by default
                        title: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isRound ? Colors.indigo.shade700 : Colors.blueGrey.shade700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        children: monthSessions.map((s) => _SessionCard(data: s)).toList(),
                      ),
                    );
                  },
                  childCount: sortedMonths.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),

        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentMode = ref.read(homeModeProvider);
          final settings = ref.read(gameSettingsNotifierProvider);
          
          ref.read(gameSettingsNotifierProvider.notifier).updateMode(currentMode);
          
          ref.read(gameNotifierProvider.notifier).startSession(
            mode: currentMode,
            targetEnds: currentMode == GameMode.round ? settings.totalEnds : null,
            shotsPerEnd: settings.shotsPerEnd,
            distance: settings.distance,
            sightMark: settings.sightMark,
          );
          context.go('/game');
        },
        icon: const Icon(Icons.add),
        label: Text(isRound ? AppLocalizations.of(context)!.startMatch : AppLocalizations.of(context)!.newPractice),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildTrendChart(BuildContext context, AsyncValue<List<SessionWithStats>> sessionData, bool isRound) {
    final accentColor = isRound ? Colors.indigo : Colors.blueGrey;

    return sessionData.when(
      data: (data) {
        if (data.isEmpty) return SizedBox(height: 200, child: Center(child: Text(AppLocalizations.of(context)!.noRecordsForMode)));

        // Limit to latest 30 sessions for the trend but keep it scrollable
        final sortedData = data.toList()..sort((a, b) => a.session.createdAt.compareTo(b.session.createdAt));
        final spots = sortedData.asMap().entries.map((e) {
          final stats = e.value;
          final rate = stats.totalShots > 0 ? (stats.totalScore / stats.totalShots) * 100 : 0.0;
          return FlSpot(e.key.toDouble(), rate);
        }).toList();

        final chartWidth = sortedData.length * 60.0;
        final scrollController = ScrollController();
        
        // Use a PostFrameCallback to scroll to the end (latest data)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });

        return Container(
          height: 220,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 24, left: 8, top: 24, bottom: 12),
            child: SizedBox(
              width: chartWidth < 300 ? 300 : chartWidth,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 != 0) return const SizedBox.shrink();
                          final index = value.toInt();
                          if (index < 0 || index >= sortedData.length) return const SizedBox.shrink();
                          return Text(
                            DateFormat('MM/dd').format(sortedData[index].session.createdAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: accentColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: accentColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatsSummary(BuildContext context, GlobalStats stats, bool isRound) {
    final accentColor = isRound ? Colors.indigo : Colors.blueGrey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _StatCard(label: AppLocalizations.of(context)!.sessions, value: '${stats.sessionCount}', icon: Icons.calendar_month, color: Colors.orange),
          const SizedBox(width: 12),
          _StatCard(label: AppLocalizations.of(context)!.total, value: '${stats.totalArrows}', icon: Icons.gps_fixed, color: accentColor),
          const SizedBox(width: 12),
          _StatCard(label: AppLocalizations.of(context)!.hitRate, value: '${(stats.average * 100).toStringAsFixed(1)}%', icon: Icons.analytics, color: Colors.green),
        ],
      ),
    );
  }
}

class _PremiumButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingNotifierProvider);
    final isPremium = billingState.value ?? false;

    if (isPremium) {
      return IconButton(
        icon: const Icon(Icons.verified_user, color: Colors.orange),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.premiumMemberMessage)),
          );
        },
      );
    }

    return IconButton(
      icon: const Icon(Icons.workspace_premium),
      onPressed: () => _showPremiumDialog(context, ref),
    );
  }

  void _showPremiumDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const PremiumUpgradeDialog(),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : activeColor.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : activeColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  final SessionWithStats data;

  const _SessionCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('yyyy/MM/dd').format(data.session.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${data.totalShots} ${AppLocalizations.of(context)!.arrows}'),
            if (data.session.distance != null || data.session.sightMark != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    if (data.session.distance != null) ...[
                      Icon(Icons.straighten, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(data.session.distance!, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(width: 12),
                    ],
                    if (data.session.sightMark != null) ...[
                      Icon(Icons.tune, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${AppLocalizations.of(context)!.bow}: ${data.session.sightMark}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${data.totalScore}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () async {
          // Load session as GameState and navigate
          final db = ref.read(appDatabaseProvider);
          final gameState = await db.getSessionAsGameState(data.session.id);
          if (gameState != null && context.mounted) {
            context.go('/results', extra: {
              'gameState': gameState,
              'isReadOnly': true,
            });
          }
        },
      ),
    );
  }
}

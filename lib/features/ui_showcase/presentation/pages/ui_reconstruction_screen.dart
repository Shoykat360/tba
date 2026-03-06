import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/showcase_theme.dart';
import '../widgets/icc_dummy_data.dart';
import '../widgets/icc_header_section.dart';
import '../widgets/icc_tab_bar.dart';
import '../widgets/icc_date_selector.dart';
import '../widgets/match_event_card.dart';
import '../widgets/statistics_tab.dart';
import '../widgets/my_games_tab.dart';

class UiReconstructionScreen extends StatefulWidget {
  const UiReconstructionScreen({super.key});

  @override
  State<UiReconstructionScreen> createState() => _UiReconstructionScreenState();
}

class _UiReconstructionScreenState extends State<UiReconstructionScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0=Schedule, 1=My games, 2=Statistics
  int _selectedDayIndex = 3; // 18 February selected by default

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    _fadeController.reverse().then((_) {
      setState(() => _selectedTab = index);
      _fadeController.forward();
    });
  }

  void _onDaySelected(int index) {
    setState(() => _selectedDayIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: ShowcaseTheme.background,
      body: Column(
        children: [
          // ── Fixed header (no scroll) ──────────────────────────────────────
          const IccHeaderSection(),
          IccTabBar(
            selectedIndex: _selectedTab,
            onTabChanged: _onTabChanged,
          ),
          const Divider(height: 1, thickness: 0.5, color: ShowcaseTheme.divider),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildScheduleTab();
      case 1:
        return const MyGamesTab();
      case 2:
        return const StatisticsTab();
      default:
        return _buildScheduleTab();
    }
  }

  Widget _buildScheduleTab() {
    // Determine which content to show based on selected day
    final bool isDay17 = _selectedDayIndex == 2; // Feb 17 -> Results
    final bool isDay18 = _selectedDayIndex == 3; // Feb 18 -> Live + Pre-match
    final bool isDay19 = _selectedDayIndex == 4; // Feb 19 -> Pre-match only

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: IccDateSelector(
            selectedDayIndex: _selectedDayIndex,
            onDaySelected: _onDaySelected,
          ),
        ),
        if (isDay17) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Results'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MatchEventCard(event: IccDummyData.resultsEvents[i]),
              childCount: IccDummyData.resultsEvents.length,
            ),
          ),
        ] else if (isDay18) ...[
          // Live Events
          SliverToBoxAdapter(
            child: MatchEventCard(
              event: IccDummyData.scheduleEvents[0],
              showSectionHeader: true,
              sectionTitle: 'Live events',
            ),
          ),
          // Pre-match Events
          SliverToBoxAdapter(
            child: MatchEventCard(
              event: IccDummyData.scheduleEvents[1],
              showSectionHeader: true,
              sectionTitle: 'Pre-match events',
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MatchEventCard(
                event: IccDummyData.scheduleEvents.skip(2).toList()[i],
              ),
              childCount: IccDummyData.scheduleEvents.skip(2).length,
            ),
          ),
        ] else if (isDay19) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Pre-match events'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MatchEventCard(event: IccDummyData.preMatchEvents19Feb[i]),
              childCount: IccDummyData.preMatchEvents19Feb.length,
            ),
          ),
        ] else ...[
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Pre-match events'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MatchEventCard(event: IccDummyData.scheduleEvents.where((e) => e.isPreMatch).toList()[i % 2]),
              childCount: 2,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShowcaseTheme.textPrimary,
            ),
          ),
          if (title == 'Live events') ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: ShowcaseTheme.liveRed,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

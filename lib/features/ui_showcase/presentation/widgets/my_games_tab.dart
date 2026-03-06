import 'package:flutter/material.dart';
import 'showcase_theme.dart';
import 'icc_dummy_data.dart';
import 'match_event_card.dart';

class MyGamesTab extends StatelessWidget {
  const MyGamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // My bets
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          decoration: BoxDecoration(
            color: ShowcaseTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ShowcaseTheme.divider, width: 0.8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ShowcaseTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.access_time, color: ShowcaseTheme.primary, size: 20),
            ),
            title: const Text(
              'My bets',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: ShowcaseTheme.textSecondary),
          ),
        ),
        // My teams
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'My teams',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShowcaseTheme.textPrimary,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Change button
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ShowcaseTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ShowcaseTheme.divider),
                    ),
                    child: const Icon(Icons.tune, color: ShowcaseTheme.primary, size: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text('Change', style: TextStyle(fontSize: 10, color: ShowcaseTheme.textSecondary)),
                ],
              ),
              const SizedBox(width: 12),
              ...IccDummyData.myTeams.map((team) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Center(
                        child: Text(team.flagEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      team.name,
                      style: const TextStyle(fontSize: 10, color: ShowcaseTheme.textSecondary),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        // Teams' matches
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            "Teams' matches",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShowcaseTheme.textPrimary,
            ),
          ),
        ),
        ...IccDummyData.scheduleEvents
            .where((e) => e.isPreMatch)
            .map((e) => MatchEventCard(event: e)),
      ],
    );
  }
}

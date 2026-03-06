import 'package:flutter/material.dart';
import 'showcase_theme.dart';
import 'icc_dummy_data.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Standings card
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
              child: const Icon(Icons.grid_on, color: ShowcaseTheme.primary, size: 20),
            ),
            title: const Text(
              'Standings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text(
              "Find out the teams' rankings",
              style: TextStyle(fontSize: 12, color: ShowcaseTheme.textSecondary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: ShowcaseTheme.textSecondary),
          ),
        ),
        // Top players section
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Top players',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShowcaseTheme.textPrimary,
            ),
          ),
        ),
        ...IccDummyData.topPlayers.map((player) => _TopPlayerRow(player: player)),
      ],
    );
  }
}

class _TopPlayerRow extends StatelessWidget {
  final TopPlayer player;
  const _TopPlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ShowcaseTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ShowcaseTheme.divider, width: 0.8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${player.rank}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ShowcaseTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: ShowcaseTheme.background,
            child: Text(
              player.name.substring(0, 1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ShowcaseTheme.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ShowcaseTheme.textPrimary,
                  ),
                ),
                Text(
                  player.country,
                  style: const TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'RN',
                style: TextStyle(fontSize: 10, color: ShowcaseTheme.textSecondary),
              ),
              Text(
                '${player.points}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ShowcaseTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

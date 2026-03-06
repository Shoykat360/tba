import 'package:flutter/material.dart';
import 'showcase_theme.dart';
import 'icc_dummy_data.dart';

class MatchEventCard extends StatelessWidget {
  final MatchEvent event;
  final bool showSectionHeader;
  final String? sectionTitle;

  const MatchEventCard({
    super.key,
    required this.event,
    this.showSectionHeader = false,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSectionHeader && sectionTitle != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  sectionTitle!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShowcaseTheme.textPrimary,
                  ),
                ),
                if (sectionTitle == 'Live events') ...[
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
          ),
        ],
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: ShowcaseTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ShowcaseTheme.divider, width: 0.8),
          ),
          child: Column(
            children: [
              // Tournament row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Center(
                        child: Text('🏏', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.tournamentName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ShowcaseTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (event.hasVideo)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.play_circle_outline, size: 18, color: ShowcaseTheme.textSecondary),
                      ),
                    if (event.hasBell)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.notifications_none, size: 18, color: ShowcaseTheme.textSecondary),
                      ),
                    if (event.hasStar)
                      const Icon(Icons.star_border, size: 18, color: ShowcaseTheme.textSecondary),
                  ],
                ),
              ),
              // Type label
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event.tournamentStage,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ShowcaseTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.5, color: ShowcaseTheme.divider),
              // Teams
              if (event.isLive) _buildLiveTeams() else if (event.isPreMatch) _buildPreMatchTeams() else if (event.isResult) _buildResultTeams(),
              // Odds row
              if (event.oddW1 != null) _buildOddsRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveTeams() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          _TeamScoreRow(
            flagEmoji: event.team1Flag ?? '',
            teamName: event.team1Name ?? '',
            score: event.team1Score ?? '',
            isBold: false,
          ),
          const SizedBox(height: 4),
          _TeamScoreRow(
            flagEmoji: event.team2Flag ?? '',
            teamName: event.team2Name ?? '',
            score: event.team2Score ?? '',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPreMatchTeams() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(event.team1Flag ?? '', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Text(
                event.team1Name ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ShowcaseTheme.textPrimary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ShowcaseTheme.textSecondary,
                  ),
                ),
              ),
              Text(
                event.team2Name ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ShowcaseTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(event.team2Flag ?? '', style: const TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          if (event.countdownTimer != null)
            _buildCountdownRow(),
        ],
      ),
    );
  }

  Widget _buildResultTeams() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          _TeamScoreRow(
            flagEmoji: event.team1Flag ?? '',
            teamName: event.team1Name ?? '',
            score: event.team1Score ?? '',
            isBold: false,
          ),
          const SizedBox(height: 4),
          _TeamScoreRow(
            flagEmoji: event.team2Flag ?? '',
            teamName: event.team2Name ?? '',
            score: event.team2Score ?? '',
            isBold: true,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${event.matchDate} (${event.matchTime})',
                style: const TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            child: Row(
              children: [
                const Text(
                  'Additional information',
                  style: TextStyle(
                    fontSize: 12,
                    color: ShowcaseTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: ShowcaseTheme.primaryLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CountdownSegment(value: event.countdownTimer!.split(' : ')[0]),
            const _CountdownSep(),
            _CountdownSegment(value: event.countdownTimer!.split(' : ')[1]),
            const _CountdownSep(),
            _CountdownSegment(value: event.countdownTimer!.split(' : ')[2]),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${event.matchDate} ${event.matchTime}',
          style: const TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildOddsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ShowcaseTheme.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text('W1', style: TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary)),
          const SizedBox(width: 8),
          _OddsChip(value: event.oddW1!.toString()),
          const Spacer(),
          const Text('X', style: TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary)),
          const SizedBox(width: 8),
          _OddsChip(value: event.oddX != null ? event.oddX!.toInt().toString() : '-'),
          const Spacer(),
          const Text('W2', style: TextStyle(fontSize: 11, color: ShowcaseTheme.textSecondary)),
          const SizedBox(width: 8),
          _OddsChip(value: event.oddW2!.toString()),
        ],
      ),
    );
  }
}

class _TeamScoreRow extends StatelessWidget {
  final String flagEmoji;
  final String teamName;
  final String score;
  final bool isBold;

  const _TeamScoreRow({
    required this.flagEmoji,
    required this.teamName,
    required this.score,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(flagEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            teamName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: ShowcaseTheme.textPrimary,
            ),
          ),
        ),
        Text(
          score,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            color: isBold ? ShowcaseTheme.textPrimary : ShowcaseTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OddsChip extends StatelessWidget {
  final String value;
  const _OddsChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ShowcaseTheme.oddsBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ShowcaseTheme.oddsText,
        ),
      ),
    );
  }
}

class _CountdownSegment extends StatelessWidget {
  final String value;
  const _CountdownSegment({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ShowcaseTheme.textPrimary,
        letterSpacing: 2,
      ),
    );
  }
}

class _CountdownSep extends StatelessWidget {
  const _CountdownSep();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ShowcaseTheme.textPrimary,
        ),
      ),
    );
  }
}

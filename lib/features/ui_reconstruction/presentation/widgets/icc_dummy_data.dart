// ─── Data Models ───────────────────────────────────────────────────────────

class MatchEvent {
  final String tournamentName;
  final String tournamentStage;
  final bool isLive;
  final bool isPreMatch;
  final bool isResult;
  final String? team1Name;
  final String? team2Name;
  final String? team1Flag;
  final String? team2Flag;
  final String? team1Score;
  final String? team2Score;
  final String? countdownTimer;
  final String? matchDate;
  final String? matchTime;
  final double? oddW1;
  final double? oddX;
  final double? oddW2;
  final bool hasVideo;
  final bool hasBell;
  final bool hasStar;
  final String? additionalInfo;

  const MatchEvent({
    required this.tournamentName,
    required this.tournamentStage,
    this.isLive = false,
    this.isPreMatch = false,
    this.isResult = false,
    this.team1Name,
    this.team2Name,
    this.team1Flag,
    this.team2Flag,
    this.team1Score,
    this.team2Score,
    this.countdownTimer,
    this.matchDate,
    this.matchTime,
    this.oddW1,
    this.oddX,
    this.oddW2,
    this.hasVideo = false,
    this.hasBell = true,
    this.hasStar = true,
    this.additionalInfo,
  });
}

class DateTab {
  final int day;
  final String month;
  final bool isSelected;
  final bool hasLiveIndicator;

  const DateTab({
    required this.day,
    required this.month,
    this.isSelected = false,
    this.hasLiveIndicator = false,
  });
}

class TopPlayer {
  final int rank;
  final String name;
  final String country;
  final int points;
  final String avatarAsset;

  const TopPlayer({
    required this.rank,
    required this.name,
    required this.country,
    required this.points,
    required this.avatarAsset,
  });
}

class MyTeam {
  final String name;
  final String flagEmoji;

  const MyTeam({required this.name, required this.flagEmoji});
}

// ─── Dummy Data ─────────────────────────────────────────────────────────────

class IccDummyData {
  static const List<DateTab> dateTabs = [
    DateTab(day: 15, month: 'February'),
    DateTab(day: 16, month: 'February'),
    DateTab(day: 17, month: 'February'),
    DateTab(day: 18, month: 'February', isSelected: true, hasLiveIndicator: true),
    DateTab(day: 19, month: 'February'),
    DateTab(day: 20, month: 'February'),
  ];

  static const List<MatchEvent> scheduleEvents = [
    // Live Events
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group D',
      tournamentStage: 'T20',
      isLive: true,
      team1Name: 'South Africa',
      team2Name: 'United Arab Emirates',
      team1Flag: '🇿🇦',
      team2Flag: '🇦🇪',
      team1Score: '0/0',
      team2Score: '29/0 (2.5 ov)',
      oddW1: 1.075,
      oddX: null,
      oddW2: 8.48,
      hasVideo: true,
      hasBell: true,
      hasStar: true,
    ),
    // Pre-match Events
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group A',
      tournamentStage: '1X2',
      isPreMatch: true,
      team1Name: 'Pakistan',
      team2Name: 'Namibia',
      team1Flag: '🇵🇰',
      team2Flag: '🇳🇦',
      countdownTimer: '03 : 44 : 43',
      matchDate: '18.02.26',
      matchTime: '15:30',
      oddW1: 1.079,
      oddX: 25,
      oddW2: 8.8,
      hasBell: true,
      hasStar: true,
    ),
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group A',
      tournamentStage: '1X2',
      isPreMatch: true,
      team1Name: 'India',
      team2Name: 'Netherlands',
      team1Flag: '🇮🇳',
      team2Flag: '🇳🇱',
      countdownTimer: '04 : 12 : 18',
      matchDate: '18.02.26',
      matchTime: '18:00',
      oddW1: 1.045,
      oddX: 32,
      oddW2: 11.5,
      hasBell: true,
      hasStar: true,
    ),
  ];

  static const List<MatchEvent> resultsEvents = [
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group C',
      tournamentStage: 'Result',
      isResult: true,
      team1Name: 'Scotland',
      team2Name: 'Nepal',
      team1Flag: '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
      team2Flag: '🇳🇵',
      team1Score: '170/7',
      team2Score: '171/3',
      matchDate: '17.02.2026',
      matchTime: '19:00',
      additionalInfo: 'Additional information',
    ),
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group D',
      tournamentStage: 'Result',
      isResult: true,
      team1Name: 'New Zealand',
      team2Name: 'Canada',
      team1Flag: '🇳🇿',
      team2Flag: '🇨🇦',
      team1Score: '176/2',
      team2Score: '173/4',
      matchDate: '17.02.2026',
      matchTime: '11:00',
      additionalInfo: 'Additional information',
    ),
  ];

  static const List<MatchEvent> preMatchEvents19Feb = [
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group C',
      tournamentStage: '1X2',
      isPreMatch: true,
      team1Name: 'West Indies',
      team2Name: 'Italy',
      team1Flag: '🌴',
      team2Flag: '🇮🇹',
      matchDate: '19.02.26',
      matchTime: '11:30',
      oddW1: 1.079,
      oddX: 25,
      oddW2: 8.8,
      hasBell: true,
      hasStar: true,
    ),
    MatchEvent(
      tournamentName: 'T20 World Cup. 2026. Group stage. Group B',
      tournamentStage: '1X2',
      isPreMatch: true,
      team1Name: 'Sri Lanka',
      team2Name: 'Zimbabwe',
      team1Flag: '🇱🇰',
      team2Flag: '🇿🇼',
      matchDate: '19.02.26',
      matchTime: '15:30',
      oddW1: 1.41,
      oddX: 25,
      oddW2: 3.025,
      hasBell: true,
      hasStar: true,
    ),
  ];

  static const List<MyTeam> myTeams = [
    MyTeam(name: 'India', flagEmoji: '🇮🇳'),
    MyTeam(name: 'Pakistan', flagEmoji: '🇵🇰'),
    MyTeam(name: 'Netherlands', flagEmoji: '🇳🇱'),
    MyTeam(name: 'Namibia', flagEmoji: '🇳🇦'),
    MyTeam(name: 'USA', flagEmoji: '🇺🇸'),
  ];

  static const List<TopPlayer> topPlayers = [
    TopPlayer(rank: 1, name: 'Tim Seifert', country: 'New Zealand', points: 453, avatarAsset: ''),
    TopPlayer(rank: 2, name: 'Rahmanullah Gurbaz', country: 'Afghanistan', points: 331, avatarAsset: ''),
    TopPlayer(rank: 3, name: 'George Munsey', country: 'Scotland', points: 288, avatarAsset: ''),
    TopPlayer(rank: 4, name: 'Sherfane Rutherford', country: 'Guyana', points: 279, avatarAsset: ''),
    TopPlayer(rank: 5, name: 'Jacob Graham Bethell', country: 'England', points: 263, avatarAsset: ''),
  ];
}

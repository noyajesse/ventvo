
enum CrashOutType {
  text,
  voice,
}

enum CrashOutStatus {
  released,
  keptPrivate,
  letGo,
  convertedToVent,
  findingPeople,
}

enum ConnectionNeed {
  justListen,
  sharedExperience,
  openDiscussion,
  unsure,
}

class CrashOut {
  final String id;

  /// Text content when the user types their Crash Out.
  final String? textContent;

  /// Future path/URL for a recorded Crash Out.
  final String? audioPath;

  final CrashOutType type;

  final DateTime createdAt;

  CrashOutStatus status;

  /// Whether this Crash Out can eventually be considered
  /// by the matching system.
  final bool matchingEligible;

  /// What kind of human connection the user wants.
  final ConnectionNeed? connectionNeed;

  CrashOut({
    required this.id,
    this.textContent,
    this.audioPath,
    required this.type,
    required this.createdAt,
    this.status = CrashOutStatus.released,
    this.matchingEligible = false,
    this.connectionNeed,
  });
}


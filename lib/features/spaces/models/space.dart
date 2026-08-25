enum SpaceMode {
  justListen,
  openDiscussion,
}

class Space {
  final String id;
  final SpaceMode mode;
  final String originatingVentId;
  final String creatorVoiceMark;
  final DateTime createdAt;

  const Space({
    required this.id,
    required this.mode,
    required this.originatingVentId,
    required this.creatorVoiceMark,
    required this.createdAt,
  });

  bool get isJustListen => mode == SpaceMode.justListen;

  bool get isOpenDiscussion => mode == SpaceMode.openDiscussion;

  String get modeLabel {
    switch (mode) {
      case SpaceMode.justListen:
        return 'Just Listen';
      case SpaceMode.openDiscussion:
        return 'Open Discussion';
    }
  }
}

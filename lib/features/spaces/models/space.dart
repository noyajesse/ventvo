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
  final List<String> ventIds;

  const Space({
    required this.id,
    required this.mode,
    required this.originatingVentId,
    required this.creatorVoiceMark,
    required this.createdAt,
    this.ventIds = const [],
  });

  bool get isJustListen => mode == SpaceMode.justListen;

  bool get isOpenDiscussion => mode == SpaceMode.openDiscussion;

  List<String> get allVentIds {
    if (ventIds.contains(originatingVentId)) return ventIds;
    return [originatingVentId, ...ventIds];
  }

  String get modeLabel {
    switch (mode) {
      case SpaceMode.justListen:
        return 'Just Listen';
      case SpaceMode.openDiscussion:
        return 'Open Discussion';
    }
  }
}

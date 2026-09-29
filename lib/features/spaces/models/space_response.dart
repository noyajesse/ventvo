enum EchoKind {
  livedSomethingSimilar,
  seeItDifferently,
  broughtSomethingForward,
}

extension EchoKindLabel on EchoKind {
  String get label {
    switch (this) {
      case EchoKind.livedSomethingSimilar:
        return 'I have lived something like this';
      case EchoKind.seeItDifferently:
        return 'This made me see it differently';
      case EchoKind.broughtSomethingForward:
        return 'This brought something forward for me';
    }
  }
}

class SpaceResponse {
  final String id;
  final String spaceId;
  final String? ventId;
  final String voiceMark;
  final String? authorVoiceId;
  final String content;
  final DateTime createdAt;
  final bool isMoment;
  final bool isHeard;
  final EchoKind? echoKind;

  const SpaceResponse({
    required this.id,
    required this.spaceId,
    this.ventId,
    required this.voiceMark,
    this.authorVoiceId,
    required this.content,
    required this.createdAt,
    this.isMoment = false,
    this.isHeard = false,
    this.echoKind,
  });
}

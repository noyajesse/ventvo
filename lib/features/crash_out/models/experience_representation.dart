enum HumanTension {
  connection,
  attention,
  dependence,
  explanation,
  presence,
  responsibility,
  recognition,
  control,
  belonging,
  vulnerability,
}

enum ExperienceDirection {
  toward,
  away,
}

enum ExperiencePosition {
  seeking,
  resisting,
  overwhelmed,
  lacking,
  protective,
  uncertain,
}

class ExperienceAtom {
  final HumanTension tension;
  final ExperiencePosition position;
  final ExperienceDirection direction;
  final double confidence;
  final double intensity;
  final List<String> evidence;

  const ExperienceAtom({
    required this.tension,
    required this.position,
    required this.direction,
    required this.confidence,
    required this.intensity,
    this.evidence = const [],
  });

  bool opposes(ExperienceAtom other) {
    return tension == other.tension && direction != other.direction;
  }
}

class ExperienceRepresentation {
  final List<ExperienceAtom> atoms;
  final Set<String> contexts;

  const ExperienceRepresentation({
    this.atoms = const [],
    this.contexts = const {},
  });

  bool get isMeaningful => atoms.any(
        (atom) => atom.confidence >= 0.55 && atom.intensity >= 0.35,
      );
}

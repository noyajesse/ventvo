class CrashOutReflection {
  final String id;
  final String crashOutId;
  final String threadId;
  final String content;
  final DateTime createdAt;

  const CrashOutReflection({
    required this.id,
    required this.crashOutId,
    required this.threadId,
    required this.content,
    required this.createdAt,
  });
}

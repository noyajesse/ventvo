import '../models/vent.dart';
import '../providers/vent_provider.dart';

class VentLifecycleService {
  final VentNotifier notifier;

  const VentLifecycleService({required this.notifier});

  Future<void> archive(Vent vent) async {
    if (!vent.isActive) return;
    await notifier.updateVent(
      vent.copyWith(lifecycleState: VentLifecycleState.archived),
    );
  }

  Future<void> restore(Vent vent) async {
    if (vent.isActive) return;
    await notifier.updateVent(
      vent.copyWith(lifecycleState: VentLifecycleState.active),
    );
  }
}

import '../models/vent.dart';
import '../providers/vent_provider.dart';

class VentLifecycleService {
  final VentNotifier notifier;

  const VentLifecycleService({required this.notifier});

  Future<void> archive(Vent vent) async {
    if (vent.status == VentStatus.archived) return;
    await notifier.updateVent(vent.copyWith(status: VentStatus.archived));
  }

  Future<void> restore(Vent vent) async {
    if (vent.status == VentStatus.active) return;
    await notifier.updateVent(vent.copyWith(status: VentStatus.active));
  }
}

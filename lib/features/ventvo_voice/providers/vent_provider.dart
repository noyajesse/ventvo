import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vent.dart';


class VentNotifier extends Notifier<List<Vent>> {

  @override
  List<Vent> build() {
    return [];
  }


  void addVent(Vent vent) {

    state = [
      ...state,
      vent,
    ];

  }

}


final ventProvider =
    NotifierProvider<VentNotifier, List<Vent>>(
  VentNotifier.new,
);
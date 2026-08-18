enum VentvoVoice {
  vaelor,
  nyven,
  auren,
}

extension VentvoVoiceExtension on VentvoVoice {
  String get name {
    switch (this) {
      case VentvoVoice.vaelor:
        return 'VAELOR';

      case VentvoVoice.nyven:
        return 'NYVEN';

      case VentvoVoice.auren:
        return 'AUREN';
    }
  }

  String get principle {
    switch (this) {
      case VentvoVoice.vaelor:
        return 'Give it somewhere to exist.';

      case VentvoVoice.nyven:
        return 'You are heard.';

      case VentvoVoice.auren:
        return 'You can become something different.';
    }
  }

  String get mark {
    switch (this) {
      case VentvoVoice.vaelor:
        return '◇';

      case VentvoVoice.nyven:
        return '∿';

      case VentvoVoice.auren:
        return '✦';
    }
  }
}
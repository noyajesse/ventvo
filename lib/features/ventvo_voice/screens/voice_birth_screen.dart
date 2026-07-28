import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_created_screen.dart';
import '../providers/voice_provider.dart';

class VoiceBirthScreen extends ConsumerStatefulWidget {
  const VoiceBirthScreen({super.key});

  @override
  ConsumerState<VoiceBirthScreen> createState() =>
      _VoiceBirthScreenState();
}

class _VoiceBirthScreenState
    extends ConsumerState<VoiceBirthScreen> {

  bool revealed = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          setState(() {
            revealed = true;
          });
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    final voice = ref.watch(
      ventvoVoiceProvider,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFF111111),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 32,
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                AnimatedOpacity(
                  opacity:
                      revealed ? 1 : 0.3,

                  duration:
                      const Duration(seconds: 2),

                  child: Text(
                    revealed
                        ? (voice.mark ?? "◇")
                        : "◌",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                    ),
                  ),
                ),


                const SizedBox(height: 40),


                Text(
                  revealed
                      ? "Your Voice has awakened."
                      : "Your Voice is taking shape...",

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 25),


                if (revealed)
                  Text(
                    voice.name ??
                        "Unnamed Voice",

                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),


                const SizedBox(height: 20),


                if (revealed)
                  Text(
                    "A Voice carrying "
                    "${voice.resonance ?? "its own resonance"}.",

                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 17,
                    ),
                  ),


                const SizedBox(height: 50),


                if (revealed)

                  SizedBox(
                    width:
                        double.infinity,

                    height:
                        55,

                    child:
                        ElevatedButton(

                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const VoiceCreatedScreen(),
                          ),
                        );

                      },

                      child:
                          const Text(
                        "Meet Your Voice",
                        style:
                            TextStyle(
                          fontSize: 17,
                        ),
                      ),

                    ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';
import 'crash_out_fate_screen.dart';

class CrashOutScreen extends ConsumerStatefulWidget {
  const CrashOutScreen({super.key});

  @override
  ConsumerState<CrashOutScreen> createState() =>
      _CrashOutScreenState();
}

class _CrashOutScreenState
    extends ConsumerState<CrashOutScreen> {
  final TextEditingController _controller =
      TextEditingController();

  bool get hasText =>
      _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _releaseText() {
    if (!hasText) return;

    final crashOut = CrashOut(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      textContent: _controller.text.trim(),
      type: CrashOutType.text,
      createdAt: DateTime.now(),
    );

    // Add the Crash Out to the user's Crash Out history.
    // Its initial state remains "released" until
    // the user chooses what to do with it.
    ref
        .read(crashOutProvider.notifier)
        .addCrashOut(crashOut);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CrashOutFateScreen(
          crashOut: crashOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF111111),
        elevation: 0,

        title: const Text(
          'Crash Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 25),

              const Text(
                "You don't have to make\n"
                "sense of it yet.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Just let it out.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(20),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white10,

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),

                    border:
                        Border.all(
                      color:
                          Colors.white12,
                    ),
                  ),

                  child: TextField(
                    controller:
                        _controller,

                    expands: true,
                    maxLines: null,
                    minLines: null,

                    textAlignVertical:
                        TextAlignVertical.top,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 18,
                      height: 1.5,
                    ),

                    cursorColor:
                        Colors.white,

                    decoration:
                        const InputDecoration(
                      border:
                          InputBorder.none,

                      hintText:
                          "Let it out...",

                      hintStyle:
                          TextStyle(
                        color:
                            Colors.white24,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Voice release is coming next.",
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.mic_none,
                  ),

                  label: const Text(
                    "Say it instead",
                  ),

                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Colors.white,

                    side:
                        const BorderSide(
                      color:
                          Colors.white24,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton(
                  onPressed:
                      hasText
                          ? _releaseText
                          : null,

                  child:
                      const Text(
                    "Release",
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
    );
  }
}
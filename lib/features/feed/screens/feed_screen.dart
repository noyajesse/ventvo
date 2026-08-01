import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';


class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final vents = ref.watch(ventProvider);


    return Scaffold(

      backgroundColor: const Color(0xFF111111),


      appBar: AppBar(

        backgroundColor: const Color(0xFF111111),

        elevation: 0,

        title: const Text(

          "Ventvo Feed",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),


      body: vents.isEmpty

          ? const Center(

              child: Text(

                "No Voices yet.\nBe the first to express.",

                textAlign: TextAlign.center,

                style: TextStyle(

                  color: Colors.white54,

                  fontSize: 18,

                ),

              ),

            )


          : ListView.builder(

              padding: const EdgeInsets.all(20),


              itemCount: vents.length,


              itemBuilder: (context, index) {


                final vent = vents[index];


                return Container(

                  margin: const EdgeInsets.only(
                    bottom: 18,
                  ),


                  padding: const EdgeInsets.all(20),


                  decoration: BoxDecoration(

                    color: Colors.white10,

                    borderRadius:
                        BorderRadius.circular(22),

                  ),


                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [


                      Text(

                        vent.content,


                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 17,

                        ),

                      ),


                      const SizedBox(height: 15),


                      Text(

                        vent.interactionType,


                        style: const TextStyle(

                          color: Colors.white54,

                          fontSize: 14,

                        ),

                      ),


                      const SizedBox(height: 15),


                      const Row(

                        children: [


                          Text(

                            "🌊 Echo",

                            style: TextStyle(

                              color: Colors.white70,

                            ),

                          ),


                          SizedBox(width: 20),


                          Text(

                            "💬 Discuss",

                            style: TextStyle(

                              color: Colors.white70,

                            ),

                          ),


                        ],

                      ),

                    ],

                  ),

                );

              },

            ),

    );

  }
}
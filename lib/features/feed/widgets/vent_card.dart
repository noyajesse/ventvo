import 'package:flutter/material.dart';

import '../../ventvo_voice/models/vent.dart';


class VentCard extends StatelessWidget {

  final Vent vent;


  const VentCard({

    super.key,

    required this.vent,

  });



  String spaceName() {

    if (vent.spaceType == "Just Listen") {

      return "🌊 Listening Space";

    }


    if (vent.spaceType == "Open Discussion") {

      return "💬 Open Discussion Space";

    }


    return "🌱 Open Space";

  }



  @override
  Widget build(BuildContext context) {


    return Container(

      margin: const EdgeInsets.only(

        bottom: 20,

      ),


      padding: const EdgeInsets.all(22),


      decoration: BoxDecoration(

        color: Colors.white10,

        borderRadius:

            BorderRadius.circular(24),

      ),



      child: Column(

        crossAxisAlignment:

            CrossAxisAlignment.start,


        children: [



          // Voice identity

          Text(

            "◇ ${vent.voiceMark}",

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 18,

              fontWeight: FontWeight.bold,

            ),

          ),



          const SizedBox(height: 18),



          // The moment expressed

          Text(

            vent.content,


            style: const TextStyle(

              color: Colors.white,

              fontSize: 18,

              height: 1.4,

            ),

          ),



          const SizedBox(height: 20),



          // Space created by the Vent

          Container(

            padding: const EdgeInsets.symmetric(

              horizontal: 14,

              vertical: 9,

            ),


            decoration: BoxDecoration(

              color: Colors.white12,

              borderRadius:

                  BorderRadius.circular(20),

            ),



            child: Text(

              spaceName(),


              style: const TextStyle(

                color: Colors.white70,

                fontSize: 13,

              ),

            ),

          ),



          const SizedBox(height: 22),



          const Divider(

            color: Colors.white12,

          ),



          const SizedBox(height: 14),



          // Future Resonance area

          const Text(

            "Resonance",

            style: TextStyle(

              color: Colors.white70,

              fontSize: 14,

              fontWeight: FontWeight.bold,

            ),

          ),



          const SizedBox(height: 10),



          const Row(

            children: [


              Text(

                "🌊 Waiting for Voices",

                style: TextStyle(

                  color: Colors.white70,

                ),

              ),


            ],

          ),



        ],

      ),

    );

  }

}
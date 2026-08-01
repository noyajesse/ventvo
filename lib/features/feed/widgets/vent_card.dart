import 'package:flutter/material.dart';

import '../../ventvo_voice/models/vent.dart';


class VentCard extends StatelessWidget {

  final Vent vent;


  const VentCard({

    super.key,

    required this.vent,

  });



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

Text(
  "◇ ${vent.voiceMark}",

            style: TextStyle(

              color: Colors.white70,

              fontSize: 15,

              fontWeight: FontWeight.bold,

            ),

          ),



          const SizedBox(height: 18),



          Text(

            vent.content,


            style: const TextStyle(

              color: Colors.white,

              fontSize: 18,

              height: 1.4,

            ),

          ),



          const SizedBox(height: 18),



          Container(

            padding: const EdgeInsets.symmetric(

              horizontal: 12,

              vertical: 8,

            ),


            decoration: BoxDecoration(

              color: Colors.white12,

              borderRadius:

                  BorderRadius.circular(20),

            ),


            child: Text(

              "🌊 ${vent.interactionType}",


              style: const TextStyle(

                color: Colors.white70,

                fontSize: 13,

              ),

            ),

          ),



          const SizedBox(height: 20),



          const Divider(

            color: Colors.white12,

          ),



          const SizedBox(height: 12),



          const Row(

            children: [


              Text(

                "🌊 Echo",

                style: TextStyle(

                  color: Colors.white70,

                ),

              ),



              SizedBox(width: 25),



              Text(

                "0 Resonating",

                style: TextStyle(

                  color: Colors.white54,

                ),

              ),


            ],

          ),


        ],

      ),

    );

  }

}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vent.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_provider.dart';


class CreateVentScreen extends ConsumerStatefulWidget {
  const CreateVentScreen({super.key});

  @override
  ConsumerState<CreateVentScreen> createState() =>
      _CreateVentScreenState();
}


class _CreateVentScreenState
    extends ConsumerState<CreateVentScreen> {

  final TextEditingController controller =
      TextEditingController();


  String? selectedSpace;



  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() {});
    });
  }



  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {


    final voice = ref.watch(ventvoVoiceProvider);



    final canRelease =
        selectedSpace != null &&
        controller.text.trim().length >= 3;



    return Scaffold(

      backgroundColor:
          const Color(0xFF111111),



      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.symmetric(

              horizontal: 32,

              vertical: 35,

            ),



            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [



                const Text(

                  "Release a Moment",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 32,

                    fontWeight: FontWeight.bold,

                  ),

                ),



                const SizedBox(height: 12),



                Text(

                  "◇ ${voice.mark ?? "Voice"}",

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 18,

                  ),

                ),



                const SizedBox(height: 30),



                TextField(

                  controller: controller,

                  maxLines: 5,


                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 17,

                  ),



                  decoration: InputDecoration(

                    hintText:
                        "What wants to be heard?",


                    hintStyle:
                        const TextStyle(

                      color: Colors.white38,

                    ),



                    filled: true,


                    fillColor:
                        Colors.white10,



                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(22),


                      borderSide:
                          BorderSide.none,

                    ),

                  ),

                ),



                const SizedBox(height: 35),



                const Text(

                  "Choose the space for this moment",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 19,

                    fontWeight: FontWeight.bold,

                  ),

                ),



                const SizedBox(height: 18),



                _spaceOption(

                  title: "Just Listen",

                  description:
                      "A space to be heard without needing answers.",

                ),



                const SizedBox(height: 15),



                _spaceOption(

                  title: "Open Discussion",

                  description:
                      "A space where different Voices can share perspectives.",

                ),



                const SizedBox(height: 40),



                SizedBox(

                  width: double.infinity,

                  height: 55,



                  child: ElevatedButton(


                    onPressed: canRelease

                        ? () {



                            final vent = Vent(


                              id: DateTime.now()

                                  .millisecondsSinceEpoch

                                  .toString(),


                              content:
                                  controller.text.trim(),



                              spaceType:
                                  selectedSpace!,



                              voiceMark:
                                  voice.mark ?? "◇",



                              createdAt:
                                  DateTime.now(),

                            );



                            ref

                                .read(

                                  ventProvider.notifier,

                                )

                                .addVent(vent);



                            Navigator.pop(context);



                          }

                        : null,



                    child: const Text(

                      "Release Moment",

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





  Widget _spaceOption({

    required String title,

    required String description,

  }) {



    final isSelected =
        selectedSpace == title;



    return GestureDetector(


      onTap: () {

        setState(() {

          selectedSpace = title;

        });

      },



      child: Container(

        width: double.infinity,


        padding:
            const EdgeInsets.all(18),



        decoration: BoxDecoration(


          color: isSelected

              ? Colors.white24

              : Colors.transparent,



          borderRadius:

              BorderRadius.circular(20),



          border: Border.all(

            color: isSelected

                ? Colors.white

                : Colors.white24,

          ),

        ),




        child: Column(


          crossAxisAlignment:

              CrossAxisAlignment.start,



          children: [



            Text(


              title,


              style: const TextStyle(


                color: Colors.white,


                fontSize: 18,


                fontWeight:
                    FontWeight.bold,


              ),

            ),




            const SizedBox(height: 6),




            Text(


              description,


              style: const TextStyle(


                color: Colors.white70,


                fontSize: 14,


              ),

            ),



          ],

        ),

      ),

    );

  }

}
import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/pages/call_screen.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:dating/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class CallRecieveScreen extends StatefulWidget {
  final String roomId;
  final String name;
  final String clientId;

  const CallRecieveScreen(
      {super.key,
      required this.roomId,
      required this.name,
      required this.clientId});

  @override
  State<CallRecieveScreen> createState() => _CallRecieveScreenState();
}

class _CallRecieveScreenState extends State<CallRecieveScreen>
    with TickerProviderStateMixin {
  final db = FirebaseFirestore.instance;
  late DocumentReference calleeCandidate;
  late StreamSubscription getUserSignals;
  late var _uid;
  late AudioPlayer player;
  bool endCallPressed = false;
  bool iAcceptedCall = false;
  late AnimationController _joinController;
  bool hostNavigatedToCall = false;
  bool ringingCall = false;

  @override
  void initState() {
    // TODO: implement initState
    _uid = FirebaseAuth.instance.currentUser!.uid;

    getStringFieldStream();
    _joinController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
    if (widget.roomId != "null") {
      player = AudioPlayer();
      //playAudio();
    }
    super.initState();
  }

  @override
  void dispose() {
    getUserSignals.cancel();
    _joinController.dispose();

    super.dispose();
  }

  // playAudio() async {
  //   //await player.setSource(AssetSource('/sounds/ringtone.mp3'));

  //   if (!ringingCall) {
  //     ringingCall = true;
  //     await player.play(AssetSource('sounds/ringtone.mp3')).then((value) async {
  //       await player.play(AssetSource('sounds/ringtone.mp3'));
  //     });
  //   }
  // }

  getStringFieldStream() {
    calleeCandidate = db.collection('rooms').doc('${widget.roomId}');
    getUserSignals =
        calleeCandidate.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('calleeConected') ?? "";
        callStatus = 'true';
        log(callStatus);

        if (callStatus.isNotEmpty) {
          if (callStatus == "done") {
            // connected = false;
            // Handle disconnection or completion logic if needed
          } else if (callStatus == "null") {
            if (widget.roomId == "null") {
              if (!hostNavigatedToCall) {
                getUserSignals?.cancel(); // Cancel the listener
                hostNavigatedToCall = true;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        CallScreen(userType: "V", roomId: widget.roomId),
                  ),
                );
              }
            } else {
              if (!iAcceptedCall) {
                if (widget.roomId != "null") {
                  player.stop();
                }
                Navigator.pop(context); // Close the current screen
              }
            }
          } else if (callStatus == "left") {
            if (widget.roomId != "null") {
              player.stop();
            }
            Navigator.pop(context);
          }
        }
      } else {
        print("Document does not exist");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text("Join a Call",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green)),
              const SizedBox(
                height: 40,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.green.withOpacity(0.2))),
                  ),
                  Container(
                    width: 245,
                    height: 245,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.green.withOpacity(0.15))),
                  ),
                  Container(
                    width: 290,
                    height: 290,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.green.withOpacity(0.1))),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Text(widget.name),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              if (widget.roomId != "null")
                GestureDetector(
                  onTap: () async {
                    print('join call');
                    await db.runTransaction((transaction) async {
                      final roomRef = await transaction.get(calleeCandidate);

                      if (roomRef.exists) {
                        final data = roomRef.data() as Map<String, dynamic>;
                        String calleeConnected = data["calleeConected"];

                        Map<String, dynamic> updateCalleeVal = {
                          'calleeConected': _uid,
                        };

                        print("step 2");

                        if (calleeConnected == "null") {
                          // Check for null instead of "null"
                          try {
                            print("step 3");
                            transaction.update(
                                calleeCandidate, updateCalleeVal);

                            print("step 4");
                          } catch (e) {
                            print("Error joining room: $e");
                            // Handle error, optionally rethrow or return a specific value
                          }
                        }
                      }
                    }).then((value) async {
                      iAcceptedCall = true;
                      //await db.collection("users").doc(clientID).update({"beingcalled": "false",});
                      player.stop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => CallScreen(
                                userType: "V",
                                roomId: widget.roomId!,
                                callerName: 'Aonymous',
                              )));
                    });
                  },
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.1).animate(
                      CurvedAnimation(
                        parent: _joinController,
                        curve: Curves.elasticIn,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.green,
                      radius: 45,
                      child: Icon(
                        Icons.phone,
                        size: 45.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      endCallPressed = true;
                      if (widget.roomId != null) {
                        getUserSignals.cancel();

                        db
                            .collection('rooms')
                            .doc('${widget.roomId}')
                            .update({"calleeConected": "left"}).then((value) {
                          if (widget.roomId != "null") {
                            player.stop();
                          }
                          Navigator.pop(context);
                        });
                      } else {
                        if (widget.roomId != "null") {
                          player.stop();
                        }
                        Navigator.pop(context);
                      }
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const ChatPage()));
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 40,
                      child: Icon(
                        Icons.call_end,
                        size: 40.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

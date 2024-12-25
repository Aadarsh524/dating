import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/pages/call_screen.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:dating/utils/colors.dart';
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
  late DocumentReference callRoomRef;
  late StreamSubscription getCallStatusStream;
  late AudioPlayer player;
  bool endCallPressed = false;
  bool iAcceptedCall = false;
  late AnimationController _joinController;
  bool hostNavigatedToCall = false;
  bool ringingCall = false;

  @override
  void initState() {
    getStringFieldStream();
    _joinController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    if (widget.roomId != "null") {
      player = AudioPlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    getCallStatusStream.cancel();
    _joinController.dispose();
    super.dispose();
  }

  getStringFieldStream() {
    callRoomRef = db.collection('rooms').doc(widget.roomId);

    getCallStatusStream =
        callRoomRef.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('callStatus') ?? "";

        log("Current call status: $callStatus");

        if (callStatus.isNotEmpty) {
          switch (callStatus) {
            case "pending":
              // Call is pending but not yet picked up
              log("Call pending, waiting for callee to respond.");
              break;

            case "connected":
              // Call is active; navigate to the call screen
              if (!hostNavigatedToCall) {
                getCallStatusStream.cancel(); // Cancel the listener
                hostNavigatedToCall = true;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        CallScreen(userType: "V", roomId: widget.roomId),
                  ),
                );
              }
              break;

            case "failed":
              // Call was not picked; close the current screen
              log("Call missed. Closing the screen.");
              if (mounted) {
                Navigator.pop(context);
              }
              break;

            case "ended":
              // Call was ended successfully; clean up and close the screen
              log("Call ended. Cleaning up.");
              if (mounted) {
                Navigator.pop(context);
              }
              break;

            default:
              log("Unhandled call status: $callStatus");
          }
        }
      } else {
        log("Call document does not exist.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text("Join a Call",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.2))),
                ),
                Container(
                  width: 245,
                  height: 245,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.15))),
                ),
                Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border:
                          Border.all(color: AppColors.green.withOpacity(0.1))),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
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
                    final roomRef = await transaction.get(callRoomRef);

                    if (roomRef.exists) {
                      final data = roomRef.data() as Map<String, dynamic>;
                      String currentCallStatus = data["callStatus"];

                      Map<String, dynamic> updateCallStatusVal = {
                        'callStatus': 'connected',
                      };

                      print("step 2");

                      if (currentCallStatus == "pending") {
                        try {
                          print("step 3");
                          transaction.update(callRoomRef, updateCallStatusVal);

                          print("step 4");
                        } catch (e) {
                          print("Error joining room: $e");
                        }
                      }
                    }
                  }).then((value) async {
                    iAcceptedCall = true;
                    player.stop();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => CallScreen(
                              userType: "V",
                              roomId: widget.roomId,
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
                    getCallStatusStream.cancel();

                    db
                        .collection('rooms')
                        .doc(widget.roomId)
                        .update({"callStatus": "ended"}).then((value) {
                      if (widget.roomId != "null") {
                        player.stop();
                      }
                      Navigator.pop(context);
                    });
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
    );
  }
}

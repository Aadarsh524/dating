import 'dart:async';
import 'package:dating/helpers/signaling.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dating/utils/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CallScreen extends StatefulWidget {
  final String userType;
  final String roomId;
  final String? callerName;
  const CallScreen(
      {Key? key, required this.userType, required this.roomId, this.callerName})
      : super(key: key);

  @override
  CallScreenState createState() => CallScreenState();
}

class CallScreenState extends State<CallScreen> {
  String? userType;
  bool loudspeaker = true;
  bool muted = false;
  bool videoClosed = false;
  bool endCallPressed = false;
  bool cameraPermissionGranted = true;

  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  bool isRemoteConnected = false;
  final db = FirebaseFirestore.instance;

  late StreamSubscription getUserSignals;

  @override
  void initState() {
    super.initState();
    userType = widget.userType;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    if (userType == 'H') {
      signaling
          .openUserMedia(_localRenderer, _remoteRenderer)
          .then((value) async {
        await signaling.createRoom(_localRenderer, widget.roomId);
      });
    } else if (userType == 'V') {
      signaling.openUserMedia(_localRenderer, _remoteRenderer);
      Future.delayed(const Duration(seconds: 7)).then((val) async {
        await signaling.joinRoom(widget.roomId, _remoteRenderer);
      });
    }

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {
        isRemoteConnected = true;
      });
    });

    roomId = widget.roomId;
    signaling.initializeBackgroundService();
    getStringFieldStream();
  }

  void endCall() async {
    if (!endCallPressed) {
      setState(() {
        endCallPressed = true;
      });
      await signaling.hangUp(_localRenderer);

      final batch = db.batch();
      final callDoc = db.collection('rooms').doc('$roomId');

      batch.update(callDoc, {"callStatus": "ended"});

      batch.commit().then((_) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ChatPage()),
            (Route<dynamic> route) => false);
      }).catchError((error) {
        print("Error during batch commit: $error");
      });
    } else {
      Fluttertoast.showToast(msg: "Please wait");
    }
  }

  // Stream listener to watch for changes in call status
  getStringFieldStream() {
    var callDoc = db.collection('rooms').doc('${widget.roomId}');
    getUserSignals =
        callDoc.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('callStatus');
        if (callStatus == "ended") {
          endCall();
          getUserSignals.cancel();
        } else if (callStatus == "failed") {
          Fluttertoast.showToast(msg: "Call failed, please try again.");
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                )),
            if (!videoClosed)
              Positioned(
                right: 5,
                top: 5,
                child: SizedBox(
                    height: 195,
                    width: 110,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitContain,
                        ))),
              ),
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          muted = !muted;
                        });
                        signaling.muteAudio(muted);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 25,
                        child: Icon(
                          muted ? Icons.mic_off : Icons.mic,
                          size: 30.0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          videoClosed = !videoClosed;
                        });
                        signaling.closeVideo(videoClosed);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 25,
                        child: Icon(
                          videoClosed
                              ? Icons.videocam_off_rounded
                              : Icons.videocam_rounded,
                          size: 38.0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        endCall();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 32,
                        child: Icon(
                          Icons.call_end_rounded,
                          size: 32.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          loudspeaker = !loudspeaker;
                        });
                        signaling.loudSpeaker(loudspeaker);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 25,
                        child: Icon(
                          loudspeaker ? Icons.volume_up : Icons.volume_off,
                          size: 25.0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!cameraPermissionGranted)
              const Positioned(
                top: 70,
                left: 10,
                child: Column(
                  children: [
                    Text(
                      "Camera Permission is not granted!",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            if (endCallPressed)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.black2,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    height: 180,
                    width: 180,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Closing Call..",
                          style: TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

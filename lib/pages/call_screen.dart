import 'dart:async';
import 'dart:typed_data';
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
  DateTime? compareDate;
  int i = 0;
  bool loudspeaker = true;
  bool muted = false;
  bool videoClosed = false;
  bool shareScreen = false;
  bool endCallPressed = false;
  bool messageTapped = false;
  int newMessagecount = 0;
  bool greenColorSelected = true;
  bool cameraPermissionGranted = true;

  //HomePageState(this.userType);
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  MediaStream? stream;
  bool? hangUpState;
  bool isRemoteConnected = false;
  //TextEditingController textEditingController = TextEditingController(text: '');
  final db = FirebaseFirestore.instance;

  // List<Files> receivedFiles = [];
  TextEditingController sendText = new TextEditingController();

// Initialize your RTCPeerConnection
  late RTCDataChannel messageChannel;
  late RTCDataChannel fileChannel;

  List<Offset?> points = [];
  double strokeWidth = 5;
  Color paintColor = AppColors.green;
  List<Uint8List> receivedFileData = [];
  bool sendingFile = false;
  bool receivingFile = false;
  bool imageReceived = false;
  late Uint8List currentImage;
  double receivingPercentage = 0;
  double sendingPercentage = 0;
  double totalFileSize = 0;
  String sendingFileUpdate = "";
  String receivedFileName = "";
  bool imagesTapped = false;
  bool viewImage = false;
  bool moveImage = false;
  late StreamSubscription getUserSignals;

  @override
  Future<void> initState() async {
    hangUpState = false;
    userType = widget.userType;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    if (userType == 'H') {
      signaling
          .openUserMedia(_localRenderer, _remoteRenderer)
          .then((value) async {
        await signaling.createRoom(_localRenderer, widget.roomId);

        // Set a timer to end the call after 20 seconds if not joined
        Future.delayed(const Duration(seconds: 20), () async {
          final roomSnapshot =
              await db.collection('rooms').doc(widget.roomId).get();
          if (roomSnapshot.exists &&
              roomSnapshot.get('callStatus') == 'initiated') {
            await db
                .collection('rooms')
                .doc(widget.roomId)
                .update({'callStatus': 'ended'});
            endCall();
          }
        });
      });
    } else if (userType == 'V') {
      signaling.openUserMedia(_localRenderer, _remoteRenderer);

      final roomSnapshot =
          await db.collection('rooms').doc(widget.roomId).get();
      if (roomSnapshot.exists && roomSnapshot.get('callStatus') == 'ended') {
        Fluttertoast.showToast(msg: "Call has already ended");
        Navigator.pop(context);
        return;
      }

      Future.delayed(const Duration(seconds: 7)).then((val) async {
        await signaling.joinRoom(widget.roomId, _remoteRenderer);
      });
    }

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {
        isRemoteConnected = (!isRemoteConnected);
      });
    });
    // final tsToMillis = DateTime.now().millisecond;
    // final compareDate = DateTime(tsToMillis - (24 * 60 * 60 * 1000));
    roomId = widget.roomId;
    signaling.initializeBackgroundService();
    getStringFieldStream();
    super.initState();
  }

  void endCall() async {
    // Close the current page
    Navigator.pop(context);

    // Prevent multiple calls to endCall if it's already in progress
    if (endCallPressed) {
      Fluttertoast.showToast(msg: "Please wait");
      return;
    }

    // Handle user type-specific actions (if required)
    if (userType == "H") {
      // Add any specific logic here for userType "H"
    }

    setState(() {
      endCallPressed = true;
    });

    try {
      // Hang up the call using signaling
      await signaling.hangUp(_localRenderer);

      // Update Firestore in a batch
      if (roomId != null) {
        final calleCandidate = db.collection('rooms').doc('$roomId');
        final batch = db.batch();
        batch.update(calleCandidate, {"calleeConected": "done"});

        await batch.commit(); // Commit the batch operation
      }

      // Navigate to the ChatPage
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ChatPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      // Log and display error messages
      print("Error during end call: $error");
      Fluttertoast.showToast(msg: "Error ending call: $error");
    } finally {
      // Reset the state if needed
      setState(() {
        endCallPressed = false;
      });
    }
  }

  //We are using this function to end call in remote users device.
  getStringFieldStream() {
    var calleeCandidate = db.collection('rooms').doc(widget.roomId);
    getUserSignals =
        calleeCandidate.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('calleeConected');
        if (callStatus == "done") {
          endCall();
          // getUserSignals.cancel();
        }
        if (callStatus == "ended") {
          Fluttertoast.showToast(msg: "Call has ended");
          endCall();
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
                        if (muted) {
                          muted = false;
                        } else {
                          muted = true;
                        }
                        setState(() {});
                        signaling.muteAudio(!muted);
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
                        if (videoClosed) {
                          videoClosed = false;
                        } else {
                          videoClosed = true;
                        }
                        setState(() {});
                        signaling.closeVideo(!videoClosed);
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
                      onTap: () async {
                        if (loudspeaker) {
                          loudspeaker = false;
                        } else {
                          loudspeaker = true;
                        }
                        setState(() {});
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
                  )),
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

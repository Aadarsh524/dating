import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/helpers/device_token.dart';
import 'package:dating/helpers/get_service_key.dart';
import 'package:dating/helpers/notification_services.dart';
import 'package:dating/pages/call_screen.dart';
import 'package:dating/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class RingScreen extends StatefulWidget {
  final String clientID;
  final String roomId;
  final String clientName;
  final EndUserDetails? endUserDetails;
  const RingScreen({
    super.key,
    this.clientID = "null",
    this.roomId = "null",
    this.endUserDetails,
    this.clientName = "unknown",
  });

  @override
  RingScreenState createState() => RingScreenState();
}

class RingScreenState extends State<RingScreen> with TickerProviderStateMixin {
  String? userType;
  bool userInitialized = false;
  int i = 0;
  bool iAcceptedCall = false;
  bool muted = false;
  bool connected = false;
  String clientID = "";

  late AnimationController _joinController;
  late AnimationController _controller;
  String hostUser = "";

  final _auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  late var _uid;
  late StreamSubscription callSubscription;
  late StreamSubscription getUserSignals;
  bool notificationSent = false;
  bool ringingCall = false;
  bool hostNavigatedToCall = false;
  NotificationServices notificationServices = NotificationServices();

  String? roomId;
  MediaStream? stream;
  bool? hangUpState;
  bool isRemoteConnected = false;
  bool endCallPressed = false;
  late DocumentReference calleeCandidate;

  bool userIsConnected = false;

  String? deviceToken;
  Timer? callTimeoutTimer;

  @override
  void initState() {
    _uid = _auth.currentUser?.uid;
    if (widget.roomId == "null") {
      hostUser = _uid;

      clientID = widget.clientID;

      // Create a new room
      calleeCandidate = db.collection('rooms').doc();
      roomId = calleeCandidate.id;

      calleeCandidate.set({"callStatus": "pending"}).then((value) async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          deviceToken = await getDeviceTokenFromDb(clientID);

          if (deviceToken != null) {
            print("FCM token ::::::> $deviceToken");
          } else {
            print("Failed to retrieve the device token.");
          }

          await sendNotificationToUser(
              "You have a Call from ${widget.clientName}",
              "Join Now",
              deviceToken!,
              roomId!,
              _uid,
              widget.endUserDetails!.name!);
        });

        getStringFieldStream();

        callTimeoutTimer = Timer(const Duration(seconds: 25), () async {
          if (!connected) {
            // Update call status to 'failed' only if call status is still 'pending'
            await calleeCandidate.update({'callStatus': 'failed'});

            // Close the RingScreen if still connected
            if (mounted) {
              Navigator.pop(context);
            }
          }
        });
      });
    }
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _joinController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _controller.forward();

    super.initState();
  }

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  @override
  void dispose() {
    if (callTimeoutTimer != null) {
      callTimeoutTimer!.cancel();
    }
    getUserSignals.cancel();
    _joinController.dispose();
    _controller.dispose();

    if (connected) {
      connected = false;
    }

    super.dispose();
  }

  getStringFieldStream() {
    calleeCandidate = db.collection('rooms').doc('$roomId');

    getUserSignals =
        calleeCandidate.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('callStatus') ?? "";
        log("this call status: $callStatus");

        if (callStatus.isNotEmpty) {
          if (callStatus == "ended" || callStatus == "failed") {
            connected = false;
            if (mounted) {
              Navigator.pop(context); // Exit the screen if call ends
            }
          } else if (callStatus == "connected") {
            connected = true;
            if (!hostNavigatedToCall) {
              hostNavigatedToCall = true;
              getUserSignals.cancel();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      CallScreen(userType: "H", roomId: roomId!),
                ),
              );
            }
          }
        }
      } else {
        print("Document does not exist");
      }
    });
  }

  Future<void> sendNotificationToUser(String title, String message,
      String userToken, String roomID, String hostUserID, String name) async {
    final data = {
      "roomid": roomID,
      "hostid": hostUserID, // Populate this field if needed
      "route": "/call",
      "name": name
    };

    try {
      GetServieKey server = GetServieKey();
      final String serverKey = await server.getServerKeyToken();
      print("This is server key: $serverKey");

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/dating-e74fa/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode({
          "message": {
            "token": userToken,
            "notification": {
              "title": title,
              "body": message,
            },
            "data": data,
          }
        }),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully");
      } else {
        print("Error sending notification: ${response.statusCode}");
        print(
            "Response body: ${response.body}"); // Print response body for debugging
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 25,
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.green.withOpacity(0.3))),
                  ),
                  Container(
                    width: 245,
                    height: 245,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: AppColors.green.withOpacity(0.2))),
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
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await calleeCandidate.update({'callStatus': 'failed'});
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppColors.grey2,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}

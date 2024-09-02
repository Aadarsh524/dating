import 'dart:async';
import 'dart:typed_data';
import 'package:dating/auth/loginScreen.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/helpers/mypainter.dart';
import 'package:dating/helpers/signaling.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dating/utils/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  final String userType;
  final String roomId;
  const CallScreen({Key? key, required this.userType, required this.roomId})
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
  List<Messages> chatMessages = [];
  // List<Files> receivedFiles = [];
  TextEditingController sendText = new TextEditingController();

// Initialize your RTCPeerConnection
  late RTCDataChannel messageChannel;
  late RTCDataChannel fileChannel;
  List<Uint8List> _receivedData = [];

  ScrollController _controller = ScrollController();

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
  void initState() {
    hangUpState = false;
    userType = widget.userType;
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    if (userType == 'H') {
      signaling
          .openUserMedia(_localRenderer, _remoteRenderer)
          .then((value) async {
        await signaling.createRoom(_localRenderer, widget.roomId!);
        // textEditingController.text = roomId!;

        //initializeDataTransfer();
      });
    } else if (userType == 'V') {
      signaling.openUserMedia(_localRenderer, _remoteRenderer);

      Future.delayed(const Duration(seconds: 7)).then((val) async {
        await signaling.joinRoom(widget.roomId, _remoteRenderer);
        // initializeDataTransfer();
      });
      //signaling.getData();
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
    Navigator.pop(context);
    if (!endCallPressed) {
      if (userType == "H") {}

      setState(() {
        endCallPressed = true;
      });

      await signaling.hangUp(_localRenderer);

      final batch = db.batch();
      String _uid = FirebaseAuth.instance.currentUser!.uid;
      final calleCandidate = db.collection('rooms').doc('$roomId');
      final userDoc = db.collection('users').doc(_uid);

      Map<String, dynamic> updateUserVal = {
        "callstatus": "",
        "beingcalled": "false",
        "roomid": "",
      };

      if (roomId != null) {
        batch.update(calleCandidate, {"calleeConected": "done"});
      }

      batch.update(userDoc, updateUserVal);

// Commit the batch
      batch.commit().then((_) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false);
      }).catchError((error) {
        // Commit failed with an error
        print("Error during batch commit: $error");
        // You can handle the error here, e.g., show a message to the user
      });
    } else {
      Fluttertoast.showToast(msg: "Please wait");
    }
  }

  //We are using this function to end call in remote users device.
  getStringFieldStream() {
    var calleeCandidate = db.collection('rooms').doc('${widget.roomId}');
    getUserSignals =
        calleeCandidate.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists) {
        String callStatus = snapshot.get('calleeConected');
        if (callStatus == "done") {
          endCall();
          // getUserSignals.cancel();
        }
      }
    });
  }

  //Transferring data. We are delaying the function for 6 seconds because I noticed it not working properly when the
  //function runs directly at load.
  // initializeDataTransfer()async{
  //  cameraPermissionGranted = await  Permission.camera.isGranted;

  //   Future.delayed(const Duration(seconds: 6)).then((val)async {
  //     if(!cameraPermissionGranted){
  //       setState(() {});
  //     }
  //     messageChannel = await signaling.messageDataChannel;
  //     fileChannel = await signaling.fileDataChannel;
  //     messageChannel.onMessage = (RTCDataChannelMessage data) {
  //       print("received a message");
  //       onReceiveTextMessage(data.binary);
  //       setState(() {});
  //     };

  //     _receivedData.clear();

  //       fileChannel.onMessage = (RTCDataChannelMessage message) {
  //         // Handle incoming data
  //         _receivedData.add(message.binary);

  //         receivingFile = true;
  //         // Calculate and print progress percentage
  //         if(totalFileSize != 0) {

  //           var currentfilesize = _receivedData.isEmpty ? 0 : (_receivedData
  //               .length.toDouble() * 16384);
  //           receivingPercentage =
  //             ((currentfilesize / totalFileSize) * 100);
  //        //   print("x&*% $receivingPercentage && $totalFileSize && $currentfilesize");
  //         }

  //         //The progress percentage is accessed from remote device and sent to the file sender.
  //         // This is because the sender device immediately shows the file sending completed.
  //         signaling.sendTextMessage("x&*% Sending ${receivingPercentage.toInt()}%");

  //         // Check if the file is fully received
  //         if (receivingPercentage > 100 || message.binary.length < 16384) {
  //           if (receivingFile) {
  //             signaling.sendTextMessage("x&*% File Sent");
  //             receivingFile = false;

  //             imageReceived = true;
  //             Uint8List currentImg = Uint8List.fromList(
  //                 _receivedData.expand((chunk) => chunk).toList());
  //             receivedFiles.add(Files(name: receivedFileName,
  //                 size: "${(totalFileSize) / 1000} kb",
  //                 image: currentImg));
  //             _receivedData.clear();
  //             totalFileSize = 0;
  //             Future.delayed(const Duration(seconds: 5)).then((val) async {
  //               setState(() {
  //                 imageReceived = false;
  //               });
  //             });
  //           }
  //         }

  //         setState(() {});
  //       };

  //   });

  // }

  //We are using special keys for example x&*S% to share valuable information like file size, etc through
  //text because receiver doesnot have all this details
  // void onReceiveTextMessage(Uint8List data) {
  //   String receivedMessage = String.fromCharCodes(data);
  //   if(receivedMessage.startsWith("x&*S%")){
  //     totalFileSize =  double.parse(receivedMessage.replaceAll("x&*S%", "").trim());
  //     print("Receingin files $totalFileSize");
  //   }else if(receivedMessage.startsWith("x&*%")){
  //     print("Sending files");
  //     sendingFile = true;
  //     sendingFileUpdate  = receivedMessage.replaceAll("x&*%", "").trim();
  //     if(sendingFileUpdate.contains("File Sent")){
  //       Future.delayed(const Duration(seconds: 5)).then((val)async {
  //         setState(() {
  //           sendingFile = false;
  //         });
  //       });
  //     }
  //   }else if(receivedMessage.startsWith("x&*N%")){
  //     receivedFileName =  receivedMessage.replaceAll("x&*N%", "").trim();
  //   }
  //   else{
  //     chatMessages.add(Messages(message: receivedMessage, sent: false));
  //     if (!messageTapped) {
  //       newMessagecount = newMessagecount + 1;
  //     }
  //   }
  //   setState(() {
  //   });
  // }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (chatMessages.length > 3)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
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
                child: Container(
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

            // if(imageReceived)
            //   Image.memory(image, width: MediaQuery.of(context).size.width-100,),

            Positioned(
              bottom: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
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
                      child: CircleAvatar(
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
                        if (shareScreen) {
                          shareScreen = false;
                          print("Screen sharing is false home");
                          signaling.stopScreenSharing(
                              _localRenderer, _remoteRenderer);
                        } else {
                          print("Screen sharing is true home");
                          shareScreen = true;
                          signaling.startScreenSharing(
                              _localRenderer, _remoteRenderer);
                        }
                        setState(() {});
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 25,
                        child: Icon(
                          !shareScreen
                              ? Icons.screen_share_rounded
                              : Icons.stop_screen_share_rounded,
                          size: 30.0,
                          color: AppColors.white,
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

            if (viewImage)
              Positioned(
                top: 70,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InteractiveViewer(
                        maxScale: 3,
                        child: Container(
                            height: MediaQuery.of(context).size.height - 190,
                            alignment: Alignment.topCenter,
                            child: Image.memory(
                              currentImage,
                              width: MediaQuery.of(context).size.width,
                            )),
                      ),
                    ],
                  ),
                ),
              ),

            if (shareScreen && !moveImage)
              GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    points = List.from(points)..add(details.globalPosition);
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    points = List.from(points)..add(details.globalPosition);
                  });
                },
                onPanEnd: (details) => points.add(null),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CustomPaint(
                    painter: MyPainter(points, paintColor, strokeWidth),
                  ),
                ),
              ),

            if (viewImage)
              Positioned(
                top: 70,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15)),
                  ),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (moveImage) {
                            moveImage = false;
                          } else {
                            moveImage = true;
                          }
                          points.clear();
                        });
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Icon(Icons.control_camera_rounded,
                                color: moveImage
                                    ? AppColors.green
                                    : AppColors.grey2),
                            Text(" Move",
                                style: TextStyle(
                                    color: moveImage
                                        ? AppColors.green
                                        : AppColors.grey2,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        viewImage = false;
                        setState(() {});
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Icon(Icons.close, color: AppColors.grey2),
                            Text(" Hide",
                                style: TextStyle(
                                    color: AppColors.grey2,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              ),

            // if(imagesTapped)
            //   Positioned(
            //     top:50,
            //     left: 10,
            //     child: Container(
            //       width: 250,
            //       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            //       decoration:BoxDecoration(
            //         color: AppColors.black2,
            //         borderRadius:
            //         BorderRadius.all(Radius.circular(15)),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text("Images", style: TextStyle(color:AppColors. white, fontSize: 19), ),
            //               GestureDetector(
            //                 onTap: ()async{
            //                   final ImagePicker picker = ImagePicker();
            //                   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            //                   Uint8List imagebyte = await image!.readAsBytes();
            //                   if(imagebyte.length.toDouble() < 4000000) {
            //                     signaling.sendTextMessage("x&*N% ${image!.name}");
            //                     sendFile(imagebyte);
            //                   }else{
            //                     Fluttertoast.showToast(msg: "Sorry, the file size is large. Please try an image below 4 MB.", toastLength: Toast.LENGTH_LONG);
            //                   }
            //                 },
            //                 child: Row(
            //                   children: [
            //                     Icon(Icons.cloud_upload_outlined, color:AppColors.white, size:18),
            //                     Text(" Send File   ", style: TextStyle(color: AppColors.white, fontSize: 12), ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),

            //           Container(
            //             child:
            //             receivedFiles.isNotEmpty?
            //             ListView.builder(
            //               shrinkWrap: true,
            //               itemCount: receivedFiles.length,
            //               itemBuilder: (context, i) {
            //                 return  GestureDetector(
            //                     onTap: (){
            //                       imagesTapped = false;
            //                       currentImage = receivedFiles[i].image;
            //                       viewImage = true;
            //                       setState(() {});
            //                     },
            //                     child: fileBubble(receivedFiles[i].name, receivedFiles[i].size));
            //               },
            //             ) : SizedBox(
            //               height: 100,
            //               width: 270,
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   Icon(Icons.file_download_off, color:AppColors.white),
            //                   Text("No Images Received", style: TextStyle(color: AppColors.white.withOpacity(0.5)),),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),

            // if(messageTapped)
            //   Positioned(
            //     top:50,
            //     left: 10,
            //     child: Container(
            //       width: 270,
            //       padding: EdgeInsets.all(8),
            //       constraints: BoxConstraints(maxHeight: 300),
            //       decoration:BoxDecoration(
            //         color: AppColors.black2,
            //         borderRadius:
            //         BorderRadius.all(Radius.circular(15)),
            //       ),
            //       child: Column(
            //         children: [
            //           Text("Chat Messages", style: TextStyle(color: AppColors.white.withOpacity(0.5), fontSize: 19), ),

            //           Container(
            //             height: 195,
            //             child: ListView.builder(
            //               shrinkWrap: true,
            //               controller: _controller,
            //               itemCount: chatMessages.length,
            //               itemBuilder: (context, i) {
            //                 return  ChatBubble(chatMessages[i].sent, chatMessages[i].message);
            //               },
            //             ),
            //           ),

            //           Row(
            //             children: [
            //               Expanded(
            //                 child: TextField(
            //                   maxLines: 2,
            //                   controller: sendText,
            //                   decoration: InputDecoration(
            //                     hintText: 'Type your message...',
            //                     filled: true,
            //                     fillColor: Colors.grey[300],
            //                     labelStyle: TextStyle(fontSize: 15),
            //                     hintStyle: TextStyle(fontSize: 15),
            //                     contentPadding: EdgeInsets.all(3),  // Remove padding around the border
            //                     border: OutlineInputBorder(
            //                       borderSide: BorderSide.none,
            //                       borderRadius: BorderRadius.circular(8.0),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               SizedBox(width: 4.0),
            //               Container(
            //                 padding:EdgeInsets.symmetric(vertical: 4),
            //                 decoration:BoxDecoration(
            //                   color: Colors.black.withOpacity(0.6),
            //                   borderRadius:
            //                   BorderRadius.all(Radius.circular(10)),
            //                 ),
            //                 child: IconButton(
            //                   color: Colors.white,
            //                   icon: Icon(Icons.send, size:29, ),
            //                   onPressed: () {
            //                     String textMessage = sendText.text;
            //                     if(textMessage != ""){
            //                       sendText.text = "";
            //                       chatMessages.add(Messages(message: textMessage, sent: true));
            //                       signaling.sendTextMessage(textMessage);
            //                       setState(() {
            //                       });
            //                     }
            //                   },
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),

            if (!cameraPermissionGranted)
              Positioned(
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

            if (shareScreen)
              Positioned(
                bottom: 0,
                child: Container(
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: greenColorSelected ? 1 : 0.6,
                            child: GestureDetector(
                              onTap: () {
                                greenColorSelected = true;
                                paintColor = AppColors.green;
                                points.clear();
                                moveImage = false;
                                setState(() {});
                              },
                              child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withOpacity(0.5),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: AppColors.green,
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Opacity(
                            opacity: !greenColorSelected ? 1 : 0.6,
                            child: GestureDetector(
                              onTap: () {
                                greenColorSelected = false;
                                paintColor = Colors.red;
                                points.clear();
                                moveImage = false;
                                setState(() {});
                              },
                              child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppColors.black.withOpacity(0.5),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: Slider(
                              activeColor: AppColors.grey3,
                              inactiveColor: AppColors.white.withOpacity(0.3),
                              min: 0,
                              max: 10,
                              value: strokeWidth,
                              onChanged: (val) {
                                moveImage = false;
                                setState(() => strokeWidth = val);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              moveImage = false;
                              setState(() {
                                points.clear();
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.remove_circle,
                                      color: AppColors.white, size: 22),
                                  SizedBox(width: 10),
                                  Text(
                                    "Clear",
                                    style: TextStyle(
                                        color: AppColors.white, fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          shareScreen = false;
                          print("Screen sharing is false home");
                          signaling.stopScreenSharing(
                              _localRenderer, _remoteRenderer);
                          setState(() {});
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width - 50,
                          decoration: BoxDecoration(
                            color: AppColors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close,
                                  color: AppColors.white, size: 28),
                              SizedBox(width: 10),
                              Text(
                                "Cancel Screen Sharing",
                                style: TextStyle(
                                    color: AppColors.white, fontSize: 17),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            if (endCallPressed)
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black2,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    height: 180,
                    width: 180,
                    child: Column(
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

  Widget ChatBubble(bool sent, String text) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Align(
        alignment: !sent ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: !sent ? AppColors.green : Colors.grey,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget fileBubble(String filename, String size) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        width: 220,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.image,
              color: AppColors.white,
              size: 44,
            ),
            SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    filename,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(color: AppColors.grey2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendFile(Uint8List img) async {
    Uint8List fileBytes = img;
    const chunkSize = 16384; // 16 KB chunks
    double totalSize = fileBytes.length.toDouble();
    double sentSize = 0.0;
    signaling.sendTextMessage("x&*S% $totalSize");
    for (var i = 0; i < fileBytes.length; i += chunkSize) {
      var end =
          (i + chunkSize < fileBytes.length) ? i + chunkSize : fileBytes.length;
      signaling.fileDataChannel
          .send(RTCDataChannelMessage.fromBinary(fileBytes.sublist(i, end)));
      sendingFile = true;
      sentSize += (end - i).toDouble();
      sendingPercentage = (sentSize / totalSize) * 100.0;
      if (end == fileBytes.length) {
        sendingFile = false;
      }
      setState(() {});
    }
  }
}

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

//Iceservers. I have also used a free turn server from metered.com
class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun3.l.google.com:19302',
          'stun:stun4.l.google.com:19302',
        ]
      },
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  bool? screenShared = false;
  StreamStateCallback? onAddRemoteStream;

  //Initializing data channels for chat and file transfers.
  late RTCDataChannel messageDataChannel;
  late RTCDataChannel fileDataChannel;

  //Creating a room
  Future<String> createRoom(
      RTCVideoRenderer remoteRenderer, String roomIdd) async {
    roomId = roomIdd;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);

    // print('Create PeerConnection with configuration: $configuration');

    peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
    // peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room

    messageDataChannel = await initDataChannel('data');
    fileDataChannel = await initDataChannel('file');
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.update(roomWithOffer);

    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    roomRef.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');

      if (snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (peerConnection?.getRemoteDescription() != null &&
            data['answer'] != null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );

          print("Someone tried to connect");
          await peerConnection?.setRemoteDescription(answer);
        }
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          //print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
    // Listen for remote ICE candidates above

    return roomId!;
  }

  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteVideo) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc('$roomId');
    var roomSnapshot = await roomRef.get();
    print('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      peerConnection?.onDataChannel = (channel) {
        if (channel.label == "data") {
          messageDataChannel = channel;
        } else if (channel.label == "file") {
          fileDataChannel = channel;
        }
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  //This function is used to provide access to camera/audio and screen
  Future<void> openUserMedia(
      RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo,
      {bool screenSharing = false}) async {
    MediaStream stream;

    try {
      if (screenSharing == true) {
        screenShared = true;
        print("Screen sharing is true");
        // Capture entire screen

        if (WebRTC.platformIsWeb) {
          print("Remove screen level web");
          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': {'cursor': 'always', 'mediaSource': 'screen'},
            'audio': true,
          });
        } else if (WebRTC.platformIsMacOS) {
          stream = await navigator.mediaDevices.getDisplayMedia({
            'audio': true,
            'video': {
              'mandatory': {
                'chromeMediaSource': 'desktop',
                'maxWidth': '1920',
                'maxHeight': '1080',
                'minWidth': '1024',
                'minHeight': '768',
              },
            },
          });
        } else {
          print("Remove screen level app");
          FlutterBackgroundService().invoke("setAsBackground");
          stream = await navigator.mediaDevices.getDisplayMedia({
            'video': {'mediaSource': 'screen'},
          });
        }

        MediaStreamTrack? newTrack = stream
            .getTracks()
            .where((element) => element.kind == 'video')
            .firstOrNull;
        if (newTrack != null) {
          List<RTCRtpSender>? senders = await peerConnection?.getSenders();
          if (senders != null) {
            senders.forEach((s) async {
              if (s.track != null && s.track?.kind == 'video') {
                await s.replaceTrack(newTrack);
              }
            });
          }
        }
      } else {
        if (WebRTC.platformIsAndroid) {
          if (screenShared == true) {
            print("Remove screen level 1");
            FlutterBackgroundService().invoke("stopService");
          }
        }

        var mediaConstraints;
        if (WebRTC.platformIsMacOS) {
          mediaConstraints = <String, dynamic>{
            'audio': true,
            'video': {
              'mandatory': {
                'minWidth':
                    '640', // Provide your own width, height, and frame rate here
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          };
        } else {
          mediaConstraints = <String, dynamic>{'audio': true, 'video': true};
        }
        // Capture camera
        stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
        print(await navigator.mediaDevices.enumerateDevices());
        MediaStreamTrack? newTrack = stream
            .getTracks()
            .where((element) => element.kind == 'video')
            .firstOrNull;
        if (newTrack != null) {
          List<RTCRtpSender>? senders = await peerConnection?.getSenders();
          if (senders != null) {
            senders.forEach((s) async {
              if (s.track != null && s.track?.kind == 'video') {
                await s.replaceTrack(newTrack);
              }
            });
          }
        }
      }

      if (screenSharing == false && screenShared == false) {
        remoteVideo.srcObject = await createLocalMediaStream('key');
      }
      localVideo.srcObject = stream;
      localStream = stream;
    } catch (e) {
      print('Error opening user media: $e');
    }
  }

  Future<RTCDataChannel> initDataChannel(String channelname) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel =
        await peerConnection!.createDataChannel(channelname, dataChannelDict);

    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        // The data channel is now open, and you can send messages
        print('Data channel is open');
      } else {
        // Handle other states if needed
        print('Data channel state: $state');
      }
    };
    return channel;
  }

  void sendTextMessage(String message) {
    Uint8List messageBytes = Uint8List.fromList(message.codeUnits);
    RTCDataChannelMessage rtcMessage =
        RTCDataChannelMessage.fromBinary(messageBytes);
    messageDataChannel.send(rtcMessage);
  }

  void sendFile(Uint8List img) async {
    Uint8List fileBytes = img;

    const chunkSize = 16384; // 16 KB chunks
    for (var i = 0; i < fileBytes.length; i += chunkSize) {
      var end =
          (i + chunkSize < fileBytes.length) ? i + chunkSize : fileBytes.length;
      fileDataChannel
          .send(RTCDataChannelMessage.fromBinary(fileBytes.sublist(i, end)));

      if (end == fileBytes.length) {}
    }
  }

  Future<void> startScreenSharing(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    await openUserMedia(localVideo, remoteVideo, screenSharing: true);
  }

  // Call this method for stopping screen sharing
  Future<void> stopScreenSharing(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    await openUserMedia(localVideo, remoteVideo, screenSharing: false);
  }

  Future<void> muteAudio(bool mute) async {
    if (WebRTC.platformIsMacOS || WebRTC.platformIsWindows) {
      localStream!.getAudioTracks().first.enabled = mute;
    } else {
      localStream!.getAudioTracks()[0].enabled = mute;
    }
  }

  Future<void> closeVideo(bool val) async {
    localStream!.getVideoTracks()[0].enabled = val;
  }

  Future<void> loudSpeaker(bool speaker) async {
    if (WebRTC.platformIsWeb || WebRTC.platformIsMacOS) {
      remoteStream!.getAudioTracks().first.enabled = speaker;
      // localStream!.getAudioTracks().forEach((track) {
      //   track.enabled = speaker;
      // });
    } else {
      localStream!.getAudioTracks()[0].enableSpeakerphone(speaker);
    }
  }

  Future<bool> hangUp(RTCVideoRenderer localVideo) async {
    if (localStream != null) {
      if (!WebRTC.platformIsWeb) {
        localStream!.getAudioTracks()[0].enabled = true;
        localStream!.getAudioTracks()[0].enableSpeakerphone(true);
      }
      // Stop camera track
      localStream!.getVideoTracks().forEach((track) => track.stop());

      List<MediaStreamTrack> audioTracks = localStream!.getAudioTracks();
      audioTracks.forEach((track) {
        track.stop();
      });

      await Future.delayed(Duration(seconds: 1));

      if (remoteStream != null) {
        remoteStream!.getTracks().forEach((track) => track.stop());
      }

      if (peerConnection != null) {
        peerConnection!.close();
      }

      messageDataChannel.close();
      fileDataChannel.close();
      localStream!.dispose();
      remoteStream?.dispose();
    }
    return true;
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }

  Future<void> initializeBackgroundService() async {
    if (WebRTC.platformIsAndroid) {
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Webrtc App",
        notificationText: "Tap to go back",
        notificationImportance: AndroidNotificationImportance.Default,
      );

      await FlutterBackground.initialize(androidConfig: androidConfig).then(
          (value) async {
        // value is false
        if (value) {
          await FlutterBackground.enableBackgroundExecution();
        }
        return value;
      }, onError: (e) {
        print('error>>>> $e');
      });

      final service = FlutterBackgroundService();

      await service.configure(
        androidConfiguration: AndroidConfiguration(
            // this will be executed when app is in foreground or background in separated isolate
            onStart: onStart,

            // auto start service
            autoStart: true,
            isForegroundMode: true,
            foregroundServiceNotificationId: 888),
        iosConfiguration: IosConfiguration(
          // auto start service
          autoStart: true,

          // this will be executed when app is in foreground in separated isolate
          onForeground: onStart,

          // you have to enable background fetch capability on xcode project
          onBackground: onIosBackground,
        ),
      );
    }
  }

  @pragma('vm:entry-point')
  Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    return true;
  }

  @pragma('vm:entry-point')
  void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }
}

class CameraPlugin {
  static const MethodChannel _channel = MethodChannel('camera_plugin');

  static Future<void> startCamera() async {
    await _channel.invokeMethod('startCamera');
  }

  static Future<void> stopCamera() async {
    await _channel.invokeMethod('stopCamera');
  }
}

class PermissionsHandler {
  static const MethodChannel _channel = MethodChannel('your_channel_name');

  static Future<bool> requestCameraPermission() async {
    try {
      final bool result =
          await _channel.invokeMethod('requestCameraPermission');
      return result;
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:dating/platform/platform.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background/flutter_background.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
          'stun:stun.relay.metered.ca:80',
        ]
      },
      {
        'urls': 'turn:turn.anyfirewall.com:443?transport=tcp',
        'credential': 'webrtc',
        'username': 'webrtc',
      },
      {
        'urls': 'turn:freeturn.net:3478',
        'credential': 'free',
        'username': 'free',
      },
      {
        "urls": "turn:global.relay.metered.ca:80",
        "username": "cbe44f80252683657daa1fe9",
        "credential": "S9W+VClSnYV3Ykmy",
      },
      {
        "urls": "turn:global.relay.metered.ca:80?transport=tcp",
        "username": "cbe44f80252683657daa1fe9",
        "credential": "S9W+VClSnYV3Ykmy",
      },
      {
        "urls": "turn:global.relay.metered.ca:443",
        "username": "cbe44f80252683657daa1fe9",
        "credential": "S9W+VClSnYV3Ykmy",
      },
      {
        "urls": "turns:global.relay.metered.ca:443?transport=tcp",
        "username": "cbe44f80252683657daa1fe9",
        "credential": "S9W+VClSnYV3Ykmy",
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

  // Initializing data channels for chat and file transfers.
  late RTCDataChannel messageDataChannel;
  late RTCDataChannel fileDataChannel;

  // Base URL of your API server

  final String baseUrl = getApiEndpoint();

  String generateUniqueRoomId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    roomId = generateUniqueRoomId();
    peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    messageDataChannel = await initDataChannel('data');
    fileDataChannel = await initDataChannel('file');
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    // Create a room in the API server
    final response = await http.post(
      Uri.parse('$baseUrl/call/createRoom'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'roomId': roomId,
        'offer': offer.toMap(),
      }),
    );

    if (response.statusCode == 200) {
      print('New room created with SDK offer. Room ID: $roomId');
      currentRoomText = 'Current room is $roomId - You are the caller!';

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream $track');
          remoteStream?.addTrack(track);
        });
      };

      // Listen for remote session description and ICE candidates
      listenForRoomUpdates(roomId!);
      //room id
      log('this is roomID=$roomId');

      return roomId!;
    } else {
      throw Exception('Failed to create room');
    }
  }

  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteVideo) async {
    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Retrieve the room information from the API server
    final response = await http.get(Uri.parse('$baseUrl/call/room/$roomId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Got room $data');

      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');
      await peerConnection!.setLocalDescription(answer);

      // Send answer to the API server
      await http.post(
        Uri.parse('$baseUrl/joinRoom'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'roomId': roomId,
          'answer': answer.toMap(),
        }),
      );

      peerConnection?.onDataChannel = (channel) {
        if (channel.label == "data") {
          messageDataChannel = channel;
        } else if (channel.label == "file") {
          fileDataChannel = channel;
        }
      };

      // Listen for remote ICE candidates
      listenForRoomUpdates(roomId);
    } else {
      throw Exception('Room not found');
    }
  }

  Future<void> addIceCandidate(
      String roomId, RTCIceCandidate candidate, bool isCaller) async {
    await http.post(
      Uri.parse('$baseUrl/call/addIceCandidate'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'roomId': roomId,
        'candidate': candidate.toMap(),
        'isCaller': isCaller,
      }),
    );
  }

  void listenForRoomUpdates(String roomId) async {
    final roomRef = Uri.parse('$baseUrl/room/$roomId');
    while (true) {
      final response = await http.get(roomRef);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['answer'] != null &&
            peerConnection?.getRemoteDescription() == null) {
          var answer = RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
          await peerConnection?.setRemoteDescription(answer);
        }

        if (data['callerCandidates'] != null) {
          for (var candidate in data['callerCandidates']) {
            peerConnection!.addCandidate(
              RTCIceCandidate(
                candidate['candidate'],
                candidate['sdpMid'],
                candidate['sdpMLineIndex'],
              ),
            );
          }
        }

        if (data['calleeCandidates'] != null) {
          for (var candidate in data['calleeCandidates']) {
            peerConnection!.addCandidate(
              RTCIceCandidate(
                candidate['candidate'],
                candidate['sdpMid'],
                candidate['sdpMLineIndex'],
              ),
            );
          }
        }
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> openUserMedia(
      RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo,
      {bool screenSharing = false}) async {
    MediaStream stream;

    try {
      if (screenSharing == true) {
        screenShared = true;
        print("Screen sharing is true");
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
          if (senders != null && senders.isNotEmpty) {
            await senders[1].replaceTrack(newTrack);
          }
        }
      } else {
        print("User media level");
        stream = await navigator.mediaDevices.getUserMedia({
          'video': {'facingMode': 'user'},
          'audio': true,
        });
        screenShared = false;
      }

      localVideo.srcObject = stream;
      localStream = stream;
    } catch (e) {
      print(e);
    }

    remoteStream = await createLocalMediaStream('key');
    remoteVideo.srcObject = remoteStream;
  }

  Future<RTCDataChannel> initDataChannel(String channel) async {
    final dataChannelDict = RTCDataChannelInit()
      ..ordered = true
      ..maxRetransmitTime = -1
      ..maxRetransmits = -1;

    return await peerConnection!.createDataChannel(channel, dataChannelDict);
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state changed: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state changed: $state');
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('ICE connection state changed: $state');
    };

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      addIceCandidate(roomId!, candidate, true);
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };
  }

  void closeVideoCall() {
    if (peerConnection != null) {
      peerConnection!.close();
      peerConnection = null;
    }

    if (localStream != null) {
      localStream!.dispose();
      localStream = null;
    }

    if (remoteStream != null) {
      remoteStream!.dispose();
      remoteStream = null;
    }
  }
}

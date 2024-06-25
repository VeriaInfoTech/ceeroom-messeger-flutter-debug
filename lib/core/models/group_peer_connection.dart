import 'package:CeeRoom/core/models/call_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class GroupPeerConnection {
  final int? userId;
  final RTCPeerConnection? pc;
  final MediaStream? stream;
  final List<Candidate>? candidates;
  bool answerSet = false;
  int remoteCandidateLength = 0;

  GroupPeerConnection({this.userId, this.pc, this.stream, this.candidates});
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({
    super.key,
    required this.name,
    required this.uid,
    required this.isVideo,
  });

  final String name;
  final String uid;
  final bool isVideo;

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isConnected = false;
  int _seconds = 0;
  Timer? _timer;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Simulate call connecting after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    final durationText = _isConnected ? _formatDuration(_seconds) : "00:00";
    
    try {
      final currentUser = Auth().currentUser;
      if (currentUser != null) {
        // Log this call in Firestore calls collection
        await FirebaseFirestore.instance.collection("calls").add({
          "callerUid": currentUser.uid,
          "callerName": currentUser.email!.split('@')[0],
          "receiverUid": widget.uid,
          "receiverName": widget.name,
          "timestamp": Timestamp.now(),
          "isVideo": widget.isVideo,
          "duration": durationText,
          "status": _isConnected ? "completed" : "no_answer",
        });
      }
    } catch (e) {
      print("Error logging call: $e");
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String partnerInitials = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "U";

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: SafeArea(
        child: Stack(
          children: [
            // Video Background Placeholder if it's a Video Call
            if (widget.isVideo && _isConnected)
              Positioned.fill(
                child: Container(
                  color: Colors.grey[900],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.videocam, color: Colors.white24, size: 100),
                      Positioned(
                        right: 20,
                        top: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 150,
                            width: 100,
                            color: Colors.black,
                            child: const Center(
                              child: Text(
                                "Moi",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            // Dim Overlay for Info Content
            if (widget.isVideo && _isConnected)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

            // Call Information
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isConnected
                          ? "En ligne · ${_formatDuration(_seconds)}"
                          : "Appel ${widget.isVideo ? 'vidéo' : 'audio'} en cours...",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    if (!widget.isVideo || !_isConnected) ...[
                      const SizedBox(height: 50),
                      // Large Avatar with animated waves
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE50914).withOpacity(0.15),
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFE50914),
                            child: Text(
                              partnerInitials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // Calling Actions Footer
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Button
                    _buildActionButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.white : const Color(0xFF1E1E1E),
                      iconColor: _isMuted ? Colors.black : Colors.white,
                      onTap: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),

                    // Red End Call Button
                    _buildActionButton(
                      icon: Icons.call_end,
                      color: const Color(0xFFE50914),
                      iconColor: Colors.white,
                      onTap: _endCall,
                      size: 64,
                      iconSize: 28,
                    ),

                    // Speaker Button
                    _buildActionButton(
                      icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                      color: _isSpeaker ? Colors.white : const Color(0xFF1E1E1E),
                      iconColor: _isSpeaker ? Colors.black : Colors.white,
                      onTap: () {
                        setState(() {
                          _isSpeaker = !_isSpeaker;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 52,
    double iconSize = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}

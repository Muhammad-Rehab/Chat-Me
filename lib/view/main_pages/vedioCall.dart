import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final AgoraClient _client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
        appId: 'f15ec279952a486c9d3522ad80f4662d',
        channelName: 'fluttering',
        tempToken:
            '006f15ec279952a486c9d3522ad80f4662dIABzu8KVC/LFMNzISxNOaCY5KoHS9KKJW6DvFdNW7+l7or2YShYAAAAAEABCwUE+kyWKYgEAAQCQJYpi'),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  void _initAgora() async {
    await _client.initialize();
  }

  @override
  void initState() {
    _initAgora();
    super.initState();
  }

  @override
  void dispose() {
    _client.sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Call'),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: _client,
                layoutType: Layout.floating,
                showNumberOfUsers: true,
              ),
              AgoraVideoButtons(
                client: _client,
                disconnectButtonChild: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      // _client.sessionController.dispose();
                      Navigator.of(context).pop();
                    },
                    color: Colors.red,
                    icon: const Icon(Icons.call_end),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

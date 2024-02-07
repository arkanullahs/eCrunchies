import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'user_type_selection.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<void> _initializeVideoPlayerFuture;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoPlayerController = VideoPlayerController.asset('assets/welcome_video.mp4');
    await videoPlayerController.initialize();

    // Mute the video's audio
    await videoPlayerController.setVolume(0.0);

    // Calculate the aspect ratio of the screen
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenAspectRatio = screenWidth / screenHeight;

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        allowPlaybackSpeedChanging: false,
        allowMuting: false,
        showControls: false,
        aspectRatio: screenAspectRatio,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _buildVideoBackground();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Center(
            child: Image.asset(
              'assets/login-icon/logo_for_welcome.png', // Replace 'assets/app_logo.png' with your logo image path
              width: 500,
              height: 500,
            ),
          ),
          _buildGetStartedButton(),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return _chewieController != null && _chewieController.videoPlayerController.value.isInitialized
        ? SizedBox.expand(
      child: AspectRatio(
        aspectRatio: _chewieController.videoPlayerController.value.aspectRatio,
        child: Stack(
          children: [
            Opacity(
              opacity: 0.9, // Adjust the opacity as needed
              child: Chewie(
                controller: _chewieController,
              ),
            ),
            // You can add other widgets on top of the video here
          ],
        ),
      ),
    )
        : Center(
      child: CircularProgressIndicator(), // Placeholder until video is loaded
    );
  }

  Widget _buildGetStartedButton() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserTypeSelection()),
            );
          },
          icon: Icon(Icons.arrow_forward),
          label: Text(
            'Get Started',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }
}

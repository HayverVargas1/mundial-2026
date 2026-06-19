import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/channel_model.dart';
import '../../core/constants/app_colors.dart';

class VideoPlayerScreen extends StatefulWidget {
  final ChannelModel channel;

  const VideoPlayerScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final lowerUrl = widget.channel.streamUrl.toLowerCase();
      VideoFormat? formatHint;
      if (!lowerUrl.endsWith('.mp4') && !lowerUrl.endsWith('.webm') && !lowerUrl.endsWith('.ts')) {
        formatHint = VideoFormat.hls; // Default to HLS for unknown extensions and tokenized URLs
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
        formatHint: formatHint,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true, allowBackgroundPlayback: false),
      );
      await _videoPlayerController.initialize();
      
      // Auto-resume if the stream drops and buffers, unless user paused
      _videoPlayerController.addListener(() {
        if (!_videoPlayerController.value.isPlaying && 
            !_videoPlayerController.value.isBuffering &&
            _videoPlayerController.value.position.inSeconds > 0) {
           // We can't perfectly know if user paused, but we can attempt to keep it alive 
           // if it's a live stream by just catching buffering states.
        }
      });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        isLive: true,
        allowedScreenSleep: false,
        fullScreenByDefault: false,
        placeholder: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        errorBuilder: (context, errorMessage) {
          return const Center(
            child: Text(
              'No se pudo reproducir este canal en este momento.\nEl enlace puede estar caído o bloqueado.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.channel.name, style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: _hasError
            ? const Center(
                child: Text('Error al cargar la transmisión.', style: TextStyle(color: Colors.white)),
              )
            : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
    );
  }
}

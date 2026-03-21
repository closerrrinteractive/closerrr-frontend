import 'package:closerrr/core/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // for height & width like 40.w
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoBubbleLoader extends StatefulWidget {
  final String mediaUrl;
  final bool isSender;

  const VideoBubbleLoader({
    super.key,
    required this.mediaUrl,
    required this.isSender,
  });

  @override
  State<VideoBubbleLoader> createState() => _VideoBubbleLoaderState();
}

class _VideoBubbleLoaderState extends State<VideoBubbleLoader> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      )..addListener(() {
          if (mounted) setState(() {});
        });

      await _videoController.initialize();
      _videoController.setLooping(true);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load video';
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.pause();
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorContainer();
    }

    if (!_isInitialized) {
      return _buildLoadingContainer();
    }

    return _buildVideoBubble();
  }

  Widget _buildErrorContainer() {
    return Container(
      height: 40.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: widget.isSender
            ? Colors.black.withOpacity(0.2)
            : Colors.blue.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return SizedBox(
      height: 40.w,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildVideoBubble() {
    return VisibilityDetector(
      key: Key(widget.mediaUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0 &&
            _videoController.value.isPlaying) {
          _videoController.pause();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.isSender
              ? Colors.black.withOpacity(0.2)
              : primaryColor.withOpacity(0.1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            ),

            // Play / Pause button
            Positioned(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  child: Icon(
                    _videoController.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: whiteColor,
                  bufferedColor: primaryColor.withAlpha(10),
                  backgroundColor: Colors.black26,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 0.5.h,
                  horizontal: 2.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

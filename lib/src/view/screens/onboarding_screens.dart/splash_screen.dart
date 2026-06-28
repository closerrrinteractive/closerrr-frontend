import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sizer/sizer.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onInit;
  const SplashScreen({super.key, this.onInit});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showToYou = false;

  @override
  void initState() {
    super.initState();
    _playLaunchSound();
    widget.onInit?.call();
  }

  Future<void> _playLaunchSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/launch_sound.wav');
      _audioPlayer.play();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showToYou = true;
          });
        }
      });
    } catch (e) {
      debugPrint("Error playing launch sound: $e");
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showToYou = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backScreenColor,
      body: Container(
        padding: EdgeInsets.all(2.h),
        height: 100.h,
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                mainLogo,
                scale: 2.9,
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOutCubic)
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(delay: 200.ms, duration: 1200.ms)
                  .then()
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            SizedBox(height: 1.0.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Closerrr",
                  style: CustomTextStyle.styledTextWidget.titleLarge!.copyWith(
                    color: primaryColor,
                    fontFamily: 'FredokaOne',
                    fontSize: 36,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(
                      begin: 0.4,
                      end: 0.0,
                      duration: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),
                const SizedBox(width: 2.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCubic,
                  width: _showToYou ? 112.0 : 0.0,
                  height: 55.0,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(),
                  alignment: Alignment.centerLeft,
                  child: AnimatedOpacity(
                    opacity: _showToYou ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeIn,
                    child: Transform.translate(
                      offset: const Offset(0, -2.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          width: 112.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "to",
                                style: TextStyle(
                                  fontFamily: 'AnnieUseYourTelescope',
                                  fontSize: 42,
                                  fontWeight: FontWeight.w500,
                                  color: peachColor,
                                  shadows: [
                                    Shadow(color: peachColor, offset: const Offset(-0.9, -0.9)),
                                    Shadow(color: peachColor, offset: const Offset(0.9, -0.9)),
                                    Shadow(color: peachColor, offset: const Offset(0.9, 0.9)),
                                    Shadow(color: peachColor, offset: const Offset(-0.9, 0.9)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                "you!",
                                style: TextStyle(
                                  fontFamily: 'AnnieUseYourTelescope',
                                  fontSize: 42,
                                  fontWeight: FontWeight.w500,
                                  color: peachColor,
                                  shadows: [
                                    Shadow(color: peachColor, offset: const Offset(-0.9, -0.9)),
                                    Shadow(color: peachColor, offset: const Offset(0.9, -0.9)),
                                    Shadow(color: peachColor, offset: const Offset(0.9, 0.9)),
                                    Shadow(color: peachColor, offset: const Offset(-0.9, 0.9)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

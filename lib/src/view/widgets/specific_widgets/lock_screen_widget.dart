import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/settings_controller/preferences_controller.dart';

class LockScreenWidget extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const LockScreenWidget({super.key, required this.onAuthenticated});

  @override
  State<LockScreenWidget> createState() => _LockScreenWidgetState();
}

class _LockScreenWidgetState extends State<LockScreenWidget>
    with SingleTickerProviderStateMixin {
  final PreferencesController preferencesController =
      Get.find<PreferencesController>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showToYou = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() {
          _showToYou = true;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final success = await preferencesController.authenticateUser(
      reason: 'Unlock Closerrr',
    );
    if (success) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backScreenColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  mainLogo,
                  scale: 3,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Closerrr ',
                    style: TextStyle(
                      fontFamily: 'FredokaOne',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: primaryColor,
                    ),
                  ),
                   AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    width: _showToYou ? 80.0 : 0.0,
                    height: 45.0,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(),
                    alignment: Alignment.centerLeft,
                    child: AnimatedOpacity(
                      opacity: _showToYou ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeIn,
                      child: Transform.translate(
                        offset: const Offset(0, 1.5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            width: 80.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'to',
                                  style: TextStyle(
                                    fontFamily: 'AnnieUseYourTelescope',
                                    fontSize: 28,
                                    color: peachColor,
                                    shadows: [
                                      Shadow(color: peachColor, offset: const Offset(-0.6, -0.6)),
                                      Shadow(color: peachColor, offset: const Offset(0.6, -0.6)),
                                      Shadow(color: peachColor, offset: const Offset(0.6, 0.6)),
                                      Shadow(color: peachColor, offset: const Offset(-0.6, 0.6)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 3.0),
                                Text(
                                  'you!',
                                  style: TextStyle(
                                    fontFamily: 'AnnieUseYourTelescope',
                                    fontSize: 28,
                                    color: peachColor,
                                    shadows: [
                                      Shadow(color: peachColor, offset: const Offset(-0.6, -0.6)),
                                      Shadow(color: peachColor, offset: const Offset(0.6, -0.6)),
                                      Shadow(color: peachColor, offset: const Offset(0.6, 0.6)),
                                      Shadow(color: peachColor, offset: const Offset(-0.6, 0.6)),
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
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.lock_open, color: whiteColor, size: 20),
                label: const Text(
                  'Unlock App',
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Hellix',
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CurtainAnimation extends StatefulWidget {
  final int mode;     // 0=tutup,1=sedang,2=buka
  final bool isDark;
  final bool sideView;
  const CurtainAnimation({
    super.key,
    required this.mode,
    required this.isDark,
    required this.sideView,
  });

  @override
  State<CurtainAnimation> createState() => _CurtainAnimationState();
}

class _CurtainAnimationState extends State<CurtainAnimation>
    with SingleTickerProviderStateMixin {

  late final AnimationController controller;
  int oldMode = 1;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(CurtainAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldMode != widget.mode) {
      double targetFrame = widget.mode == 0 ? 0 : widget.mode == 1 ? 45 : 90;

      if (controller.duration != null) {
        controller.value = (targetFrame / 90).clamp(0.0, 1.0);
      }

      oldMode = widget.mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.sideView
        ? "assets/sidecurt.json"
        : "assets/frontcurt.json";

    return SizedBox(
      width: 260,
      height: 200,
      child: Card(
        color: widget.isDark ? Color(0xFF23232B) : Color(0xFFF3FBFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Lottie.asset(
            file,
            controller: controller,
            fit: BoxFit.contain,
            animate: false,
            repeat: false,
            onLoaded: (comp) {
              controller.duration = comp.duration;
              controller.value =
                  (widget.mode == 0 ? 0 : widget.mode == 1 ? 45 : 90) / 90;
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// A stylized phone shell used to frame feed previews ("mobile feed
/// simulation"). Renders a dark bezel with a top notch around [child].
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({super.key, required this.child, this.bezelColor});

  final Widget child;
  final Color? bezelColor;

  @override
  Widget build(BuildContext context) {
    final Color bezel = bezelColor ?? const Color(0xFF26263C);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bezel,
        borderRadius: BorderRadius.circular(40),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: <Widget>[
            ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: child,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 116,
                height: 22,
                decoration: BoxDecoration(
                  color: bezel,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

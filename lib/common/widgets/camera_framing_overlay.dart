import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';

class CameraFramingOverlay extends StatelessWidget {
  const CameraFramingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth * 0.78;
        final frameHeight = constraints.maxHeight * 0.52;
        final left = (constraints.maxWidth - frameWidth) / 2;
        final top = (constraints.maxHeight - frameHeight) / 2;

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _DimmedFramePainter(
                frameRect: Rect.fromLTWH(left, top, frameWidth, frameHeight),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: frameWidth,
              height: frameHeight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.9),
                    width: 2.5,
                  ),
                ),
                child: Stack(
                  children: [
                    _corner(Alignment.topLeft),
                    _corner(Alignment.topRight),
                    _corner(Alignment.bottomLeft),
                    _corner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
            Positioned(
              top: top - 44,
              left: 0,
              right: 0,
              child: Text(
                'Position your food within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: AppSizes.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(blurRadius: 6, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _corner(Alignment alignment) {
    const size = 28.0;
    const thickness = 3.0;
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: alignment.y < 0
                  ? BorderSide(color: AppColors.primary, width: thickness)
                  : BorderSide.none,
              bottom: alignment.y > 0
                  ? BorderSide(color: AppColors.primary, width: thickness)
                  : BorderSide.none,
              left: alignment.x < 0
                  ? BorderSide(color: AppColors.primary, width: thickness)
                  : BorderSide.none,
              right: alignment.x > 0
                  ? BorderSide(color: AppColors.primary, width: thickness)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _DimmedFramePainter extends CustomPainter {
  _DimmedFramePainter({required this.frameRect});

  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.45);
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          frameRect,
          const Radius.circular(AppSizes.cardRadiusLg),
        ),
      );
    final dimmed = Path.combine(PathOperation.difference, full, hole);
    canvas.drawPath(dimmed, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _DimmedFramePainter oldDelegate) {
    return oldDelegate.frameRect != frameRect;
  }
}

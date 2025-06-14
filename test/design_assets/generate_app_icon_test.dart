import 'package:app_store_screenshots/app_store_screenshots.dart';
import 'package:download_manager/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  generateAppIcon(
    onBuildIcon: (size) => Theme(
      data: lightTheme,
      child: AppIcon(
        size: size,
      ),
    ),
  );

  generateAppIconAndroidForeground(
    onBuildIcon: (size) => Theme(
      data: lightTheme,
      child: AppIcon(
        size: size,
        hasTransparentBackground: true,
      ),
    ),
  );
}

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.size,
    this.hasTransparentBackground = false,
  });

  final double size;
  final bool hasTransparentBackground;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        color: hasTransparentBackground ? Colors.transparent : context.colorScheme.primary,
        child: Center(
          child: Icon(
            Icons.download,
            size: size * 0.8,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

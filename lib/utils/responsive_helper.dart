import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth > 1200) {
      return baseFontSize * 1.2;
    } else if (screenWidth > 600) {
      return baseFontSize * 1.1;
    }
    return baseFontSize;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 900) {
      return 3;
    } else if (screenWidth > 600) {
      return 2;
    } else {
      return 2;
    }
  }

  static double getGridChildAspectRatio(BuildContext context) {
    if (isDesktop(context)) {
      return 0.8;
    } else if (isTablet(context)) {
      return 0.75;
    } else {
      return 0.7;
    }
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) {
      return baseSpacing * 1.5;
    } else if (isTablet(context)) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    }
    return double.infinity;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.3;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 56;
    } else if (isTablet(context)) {
      return 52;
    }
    return 48;
  }

  static double getResponsiveFABSize(BuildContext context) {
    if (isDesktop(context)) {
      return 70;
    } else if (isTablet(context)) {
      return 65;
    }
    return 60;
  }
}

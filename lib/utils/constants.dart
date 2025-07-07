import 'dart:io';

import 'package:flutter/material.dart';

class AppConstants {
  // 앱 정보
  static const String appTitle = 'Single Instance App';
  static const String appDescription = 'System Tray에서 앱을 관리하세요';

  // 윈도우 설정
  static const Size defaultWindowSize = Size(800, 600);
  static const double titleBarHeight = 60.0;
  static const double buttonSize = 30.0;

  // 파일 관련
  static const String lockFileName = '.lockfile';

  // UI 색상
  static const Color hideButtonColor = Colors.orange;
  static const Color closeButtonColor = Colors.red;
  static const Color createLockColor = Colors.green;
  static const Color removeLockColor = Colors.purple;
  static const Color checkStatusColor = Colors.blue;

  // UI 간격
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );
  static const EdgeInsets smallButtonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  // 시스템 트레이
  static final String trayIconPath = Platform.isWindows
      ? 'assets/images/app_icon.ico'
      : 'assets/images/app_icon.png';
  static const String trayShowLabel = 'Show Window';
  static const String trayHideLabel = 'Hide Window';
  static const String trayExitLabel = 'Exit';
}

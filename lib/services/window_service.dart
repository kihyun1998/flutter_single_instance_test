import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService with WindowListener {
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  void initialize() {
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }

  // 윈도우 표시
  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  // 윈도우 숨기기
  Future<void> hideWindow() async {
    await windowManager.hide();
  }

  // 윈도우 토글 (보이기/숨기기)
  Future<void> toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await hideWindow();
    } else {
      await showWindow();
    }
  }

  // 윈도우 파괴 (앱 종료)
  Future<void> destroyWindow() async {
    await windowManager.destroy();
  }

  // 윈도우 닫기 방지 설정
  Future<void> setPreventClose(bool prevent) async {
    await windowManager.setPreventClose(prevent);
  }

  // WindowListener 구현
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await hideWindow();
    }
  }

  @override
  void onWindowFocus() {
    debugPrint('Window focused');
  }

  @override
  void onWindowBlur() {
    debugPrint('Window blurred');
  }

  @override
  void onWindowMinimize() {
    debugPrint('Window minimized');
  }

  @override
  void onWindowRestore() {
    debugPrint('Window restored');
  }
}

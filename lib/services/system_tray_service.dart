import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';

import '../utils/constants.dart';

class SystemTrayService {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  final SystemTray _systemTray = SystemTray();

  VoidCallback? onShowWindow;
  VoidCallback? onHideWindow;
  VoidCallback? onToggleWindow;
  VoidCallback? onExit;

  // System Tray 초기화
  Future<void> initialize() async {
    await _systemTray.initSystemTray(
      title: AppConstants.appTitle,
      iconPath: AppConstants.trayIconPath,
    );

    await _setupContextMenu();
    _setupEventHandlers();
  }

  // 컨텍스트 메뉴 설정
  Future<void> _setupContextMenu() async {
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: AppConstants.trayShowLabel,
        onClicked: (menuItem) => onShowWindow?.call(),
      ),
      MenuItemLabel(
        label: AppConstants.trayHideLabel,
        onClicked: (menuItem) => onHideWindow?.call(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: AppConstants.trayExitLabel,
        onClicked: (menuItem) => onExit?.call(),
      ),
    ]);

    await _systemTray.setContextMenu(menu);
  }

  // 이벤트 핸들러 설정
  void _setupEventHandlers() {
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("System tray event: $eventName");
      if (eventName == kSystemTrayEventClick) {
        onToggleWindow?.call();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  // 트레이 타이틀 업데이트
  Future<void> updateTitle(String title) async {
    await _systemTray.setTitle(title);
  }

  // 트레이 아이콘 업데이트 (선택사항)
  Future<void> updateIcon(String iconPath) async {
    await _systemTray.setImage(iconPath);
  }

  // System Tray 정리
  Future<void> destroy() async {
    await _systemTray.destroy();
  }
}

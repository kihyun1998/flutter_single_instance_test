import 'package:flutter/material.dart';

import '../services/lock_file_service.dart';
import '../services/system_tray_service.dart';
import '../services/window_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/lock_file_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late 대신 nullable로 변경
  WindowService? _windowService;
  SystemTrayService? _systemTrayService;
  LockFileService? _lockFileService;

  String _lockFileStatus = "Initializing...";
  bool _isInitialized = false; // 초기화 상태 추적

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _windowService?.dispose();
    super.dispose();
  }

  // 서비스들 초기화
  Future<void> _initializeServices() async {
    try {
      // Window Service 초기화
      _windowService = WindowService();
      _windowService!.initialize();

      // System Tray Service 초기화
      _systemTrayService = SystemTrayService();
      _systemTrayService!.onShowWindow = _windowService!.showWindow;
      _systemTrayService!.onHideWindow = _windowService!.hideWindow;
      _systemTrayService!.onToggleWindow = _windowService!.toggleWindow;
      _systemTrayService!.onExit = _exitApp;
      await _systemTrayService!.initialize();

      // Lock File Service 초기화
      _lockFileService = LockFileService();
      await _lockFileService!.initialize();
      await _updateLockFileStatus();

      // 초기화 완료 상태로 변경
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Service initialization error: $e');
      if (mounted) {
        setState(() {
          _lockFileStatus = "Initialization failed: $e";
        });
      }
    }
  }

  // Lock file 상태 업데이트
  Future<void> _updateLockFileStatus() async {
    if (_lockFileService != null) {
      final status = await _lockFileService!.checkStatus();
      if (mounted) {
        setState(() {
          _lockFileStatus = status;
        });
      }
    }
  }

  // Lock file 생성
  Future<void> _createLockFile() async {
    if (_lockFileService != null) {
      final status = await _lockFileService!.createLockFile();
      if (mounted) {
        setState(() {
          _lockFileStatus = status;
        });
      }
    }
  }

  // Lock file 삭제
  Future<void> _removeLockFile() async {
    if (_lockFileService != null) {
      final status = await _lockFileService!.removeLockFile();
      if (mounted) {
        setState(() {
          _lockFileStatus = status;
        });
      }
    }
  }

  // Lock file 상태 확인
  Future<void> _checkLockFileStatus() async {
    await _updateLockFileStatus();
  }

  // 윈도우 숨기기
  Future<void> _hideWindow() async {
    await _windowService?.hideWindow();
  }

  // 윈도우 닫기 (트레이로)
  Future<void> _closeToTray() async {
    if (_windowService != null) {
      await _windowService!.setPreventClose(true);
      await _windowService!.hideWindow();
    }
  }

  // 앱 종료
  Future<void> _exitApp() async {
    await _lockFileService?.cleanup();
    await _systemTrayService?.destroy();
    await _windowService?.destroyWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 커스텀 타이틀 바
          CustomTitleBar(
            onHide: _hideWindow,
            onClose: _closeToTray,
          ),

          // 메인 컨텐츠
          Expanded(
            child: Center(
              child: _isInitialized
                  ? _buildMainContent() // 초기화 완료 후 메인 컨텐츠
                  : _buildLoadingContent(), // 로딩 중 컨텐츠
            ),
          ),
        ],
      ),
    );
  }

  // 로딩 중 컨텐츠
  Widget _buildLoadingContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          'Initializing services...',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // 메인 컨텐츠
  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 앱 아이콘과 제목
        const Icon(
          Icons.desktop_mac,
          size: 80,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        const Text(
          'Single Instance macOS App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppConstants.appDescription,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),

        // Lock File 패널 (초기화 완료 후에만 표시)
        if (_lockFileService != null)
          LockFilePanel(
            status: _lockFileStatus,
            filePath: _lockFileService!.lockFilePath,
            onCreateLockFile: _createLockFile,
            onRemoveLockFile: _removeLockFile,
            onCheckStatus: _checkLockFileStatus,
          ),

        const SizedBox(height: 30),

        // 기본 제어 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _hideWindow,
              icon: const Icon(Icons.visibility_off),
              label: const Text('Hide Window'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.hideButtonColor,
                foregroundColor: Colors.white,
                padding: AppConstants.buttonPadding,
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: _exitApp,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.closeButtonColor,
                foregroundColor: Colors.white,
                padding: AppConstants.buttonPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

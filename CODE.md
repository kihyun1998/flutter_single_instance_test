# flutter_single_instance_test
## Project Structure

```
flutter_single_instance_test/
└── lib/
    ├── screens/
        └── home_screen.dart
    ├── services/
        ├── lock_file_service.dart
        ├── system_tray_service.dart
        └── window_service.dart
    ├── utils/
        └── constants.dart
    ├── widgets/
        ├── custom_title_bar.dart
        └── lock_file_panel.dart
    └── main.dart
```

## lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window Manager 초기화
  await windowManager.ensureInitialized();

  // 윈도우 옵션 설정
  WindowOptions windowOptions = const WindowOptions(
    size: AppConstants.defaultWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

```
## lib/screens/home_screen.dart
```dart
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
  late final WindowService _windowService;
  late final SystemTrayService _systemTrayService;
  late final LockFileService _lockFileService;

  String _lockFileStatus = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _windowService.dispose();
    super.dispose();
  }

  // 서비스들 초기화
  Future<void> _initializeServices() async {
    // Window Service 초기화
    _windowService = WindowService();
    _windowService.initialize();

    // System Tray Service 초기화
    _systemTrayService = SystemTrayService();
    _systemTrayService.onShowWindow = _windowService.showWindow;
    _systemTrayService.onHideWindow = _windowService.hideWindow;
    _systemTrayService.onToggleWindow = _windowService.toggleWindow;
    _systemTrayService.onExit = _exitApp;
    await _systemTrayService.initialize();

    // Lock File Service 초기화
    _lockFileService = LockFileService();
    await _lockFileService.initialize();
    await _updateLockFileStatus();
  }

  // Lock file 상태 업데이트
  Future<void> _updateLockFileStatus() async {
    final status = await _lockFileService.checkStatus();
    setState(() {
      _lockFileStatus = status;
    });
  }

  // Lock file 생성
  Future<void> _createLockFile() async {
    final status = await _lockFileService.createLockFile();
    setState(() {
      _lockFileStatus = status;
    });
  }

  // Lock file 삭제
  Future<void> _removeLockFile() async {
    final status = await _lockFileService.removeLockFile();
    setState(() {
      _lockFileStatus = status;
    });
  }

  // Lock file 상태 확인
  Future<void> _checkLockFileStatus() async {
    await _updateLockFileStatus();
  }

  // 윈도우 숨기기
  Future<void> _hideWindow() async {
    await _windowService.hideWindow();
  }

  // 윈도우 닫기 (트레이로)
  Future<void> _closeToTray() async {
    await _windowService.setPreventClose(true);
    await _windowService.hideWindow();
  }

  // 앱 종료
  Future<void> _exitApp() async {
    await _lockFileService.cleanup();
    await _systemTrayService.destroy();
    await _windowService.destroyWindow();
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
              child: Column(
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

                  // Lock File 패널
                  LockFilePanel(
                    status: _lockFileStatus,
                    filePath: _lockFileService.lockFilePath,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```
## lib/services/lock_file_service.dart
```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';

class LockFileService {
  static final LockFileService _instance = LockFileService._internal();
  factory LockFileService() => _instance;
  LockFileService._internal();

  String _lockFilePath = "";
  String _status = "Initializing...";

  String get lockFilePath => _lockFilePath;
  String get status => _status;

  // 초기화
  Future<void> initialize() async {
    try {
      final Directory appSupportDir = await getApplicationSupportDirectory();
      _lockFilePath = '${appSupportDir.path}/${AppConstants.lockFileName}';
      await checkStatus();
    } catch (e) {
      _status = "Error getting app support directory: $e";
      debugPrint(_status);
    }
  }

  // Lock file 생성 (현재 PID 기록)
  Future<String> createLockFile() async {
    try {
      final File lockFile = File(_lockFilePath);
      final int currentPid = pid; // 현재 프로세스 PID

      // PID와 타임스탬프 기록
      final String content = '''PID: $currentPid
Created: ${DateTime.now().toIso8601String()}
App: ${AppConstants.appTitle}''';

      await lockFile.writeAsString(content);

      _status = "Lock file created with PID: $currentPid";
      debugPrint("Lock file created at: $_lockFilePath");
      debugPrint("Current PID: $currentPid");

      return _status;
    } catch (e) {
      _status = "Error creating lock file: $e";
      debugPrint(_status);
      return _status;
    }
  }

  // Lock file 삭제
  Future<String> removeLockFile() async {
    try {
      final File lockFile = File(_lockFilePath);
      if (await lockFile.exists()) {
        await lockFile.delete();
        _status = "Lock file removed";
        debugPrint("Lock file removed");
      } else {
        _status = "Lock file does not exist";
      }
      return _status;
    } catch (e) {
      _status = "Error removing lock file: $e";
      debugPrint(_status);
      return _status;
    }
  }

  // Lock file 상태 확인
  Future<String> checkStatus() async {
    try {
      final File lockFile = File(_lockFilePath);
      if (await lockFile.exists()) {
        final String content = await lockFile.readAsString();
        _status = "Lock file exists:\n$content";
      } else {
        _status = "Lock file does not exist";
      }
      return _status;
    } catch (e) {
      _status = "Error checking lock file: $e";
      return _status;
    }
  }

  // Lock file이 가리키는 프로세스가 실제로 실행 중인지 확인
  Future<bool> isProcessRunning(int pid) async {
    try {
      // macOS에서 프로세스 존재 여부 확인
      final ProcessResult result =
          await Process.run('ps', ['-p', pid.toString()]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint("Error checking process: $e");
      return false;
    }
  }

  // Lock file에서 PID 추출
  Future<int?> getLockFilePid() async {
    try {
      final File lockFile = File(_lockFilePath);
      if (await lockFile.exists()) {
        final String content = await lockFile.readAsString();
        final RegExp pidRegex = RegExp(r'PID: (\d+)');
        final Match? match = pidRegex.firstMatch(content);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error getting PID from lock file: $e");
      return null;
    }
  }

  // 앱 종료 시 정리
  Future<void> cleanup() async {
    await removeLockFile();
  }
}

```
## lib/services/system_tray_service.dart
```dart
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

```
## lib/services/window_service.dart
```dart
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

```
## lib/utils/constants.dart
```dart
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

```
## lib/widgets/custom_title_bar.dart
```dart
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CustomTitleBar extends StatelessWidget {
  final VoidCallback onHide;
  final VoidCallback onClose;

  const CustomTitleBar({
    super.key,
    required this.onHide,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.titleBarHeight,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Text(
            AppConstants.appTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Hide Window 버튼 (가운데)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              onPressed: onHide,
              icon: const Icon(Icons.remove),
              tooltip: 'Hide Window',
              style: IconButton.styleFrom(
                backgroundColor: AppConstants.hideButtonColor,
                foregroundColor: Colors.white,
                fixedSize: const Size(
                  AppConstants.buttonSize,
                  AppConstants.buttonSize,
                ),
              ),
            ),
          ),
          // Close 버튼
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Close to Tray',
              style: IconButton.styleFrom(
                backgroundColor: AppConstants.closeButtonColor,
                foregroundColor: Colors.white,
                fixedSize: const Size(
                  AppConstants.buttonSize,
                  AppConstants.buttonSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```
## lib/widgets/lock_file_panel.dart
```dart
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class LockFilePanel extends StatelessWidget {
  final String status;
  final String filePath;
  final VoidCallback onCreateLockFile;
  final VoidCallback onRemoveLockFile;
  final VoidCallback onCheckStatus;

  const LockFilePanel({
    super.key,
    required this.status,
    required this.filePath,
    required this.onCreateLockFile,
    required this.onRemoveLockFile,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lock File 상태 표시
        Container(
          padding: AppConstants.defaultPadding,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lock File Status:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: $filePath',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Lock File 제어 버튼들
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: onCreateLockFile,
              icon: const Icon(Icons.lock),
              label: const Text('Create Lock File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.createLockColor,
                foregroundColor: Colors.white,
                padding: AppConstants.smallButtonPadding,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onRemoveLockFile,
              icon: const Icon(Icons.lock_open),
              label: const Text('Remove Lock File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.removeLockColor,
                foregroundColor: Colors.white,
                padding: AppConstants.smallButtonPadding,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onCheckStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.checkStatusColor,
                foregroundColor: Colors.white,
                padding: AppConstants.smallButtonPadding,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

```

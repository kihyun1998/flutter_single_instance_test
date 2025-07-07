import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window Manager 초기화
  await windowManager.ensureInitialized();

  // 윈도우 옵션 설정
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: false, // 기본 윈도우 버튼 숨김
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
      title: 'Single Instance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // _initSystemTray();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // System Tray 초기화
  Future<void> _initSystemTray() async {
    String path = 'assets/images/app_icon.png'; // 아이콘 파일 경로

    await _systemTray.initSystemTray(
      title: "Single Instance App",
      iconPath: path,
    );

    // 시스템 트레이 메뉴 설정
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Window',
        onClicked: (menuItem) => _showWindow(),
      ),
      MenuItemLabel(
        label: 'Hide Window',
        onClicked: (menuItem) => _hideWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) => _exitApp(),
      ),
    ]);

    await _systemTray.setContextMenu(menu);

    // 시스템 트레이 아이콘 클릭 이벤트
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        _toggleWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  // 윈도우 표시
  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  // 윈도우 숨기기
  Future<void> _hideWindow() async {
    await windowManager.hide();
  }

  // 윈도우 토글 (보이기/숨기기)
  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await _hideWindow();
    } else {
      await _showWindow();
    }
  }

  // 앱 종료
  Future<void> _exitApp() async {
    await _systemTray.destroy();
    await windowManager.destroy();
  }

  // 윈도우 닫기 버튼 클릭 시 숨기기 (종료하지 않고)
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await _hideWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 커스텀 타이틀 바
          Container(
            height: 60,
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
                  'Single Instance App',
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
                    onPressed: _hideWindow,
                    icon: const Icon(Icons.remove),
                    tooltip: 'Hide Window',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(30, 30),
                    ),
                  ),
                ),
                // Close 버튼
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    onPressed: () async {
                      await windowManager.setPreventClose(true);
                      await _hideWindow();
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Close to Tray',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(30, 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 메인 컨텐츠
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    'System Tray에서 앱을 관리하세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _hideWindow,
                        icon: const Icon(Icons.visibility_off),
                        label: const Text('Hide Window'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: _exitApp,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Exit App'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
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

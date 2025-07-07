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

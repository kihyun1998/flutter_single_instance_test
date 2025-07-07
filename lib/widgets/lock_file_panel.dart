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

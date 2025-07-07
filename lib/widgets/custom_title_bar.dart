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

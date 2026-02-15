import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCheckPage extends ConsumerStatefulWidget {
  final Widget child;

  const PermissionCheckPage({super.key, required this.child});

  @override
  ConsumerState<PermissionCheckPage> createState() =>
      _PermissionCheckPageState();
}

class _PermissionCheckPageState extends ConsumerState<PermissionCheckPage> {
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // 1. Check Exact Alarm Permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      if (mounted) {
        _showDialog(
          title: 'Alarm Permission Required',
          content:
              'StepWake needs permission to schedule exact alarms so you wake up on time.',
          onGrant: () async {
            final status = await Permission.scheduleExactAlarm.request();
            if (status.isGranted) {
              _checkPermissions(); // Recursively check next permission
            } else if (mounted) {
              _showDeniedSnackBar('Alarm permission is required.');
            }
          },
        );
      }
      return;
    }

    // 2. Check Notification Permission (Android 13+)
    if (await Permission.notification.isDenied) {
      if (mounted) {
        _showDialog(
          title: 'Notification Permission Required',
          content: 'StepWake needs permission to send alarm notifications.',
          onGrant: () async {
            final status = await Permission.notification.request();
            if (status.isGranted) {
              _checkPermissions(); // Check next (or finish)
            } else if (mounted) {
              // Proceed anyway if notification is denied, but warn?
              // Or force it? User asked to "Ask notification permission", usually implies strictly required or at least heavily requested.
              // Let's assume we want to guide them back.
              _showDeniedSnackBar('Notifications are recommended for alarms.');
              // Even if denied, we might want to let them in, or loop.
              // For now, let's re-check which will just show dialog again if strictly required,
              // OR we can choose to proceed.
              // If I call _checkPermissions() again, it creates a loop if they keep denying.
              // Let's allow them to proceed but show the snackbar.
              setState(() {
                _permissionChecked = true;
              });
            }
          },
        );
      }
      return;
    }

    setState(() {
      _permissionChecked = true;
    });
  }

  void _showDeniedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required VoidCallback onGrant,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // If they cancel, we can't proceed really if it's strictly required (like Alarm).
              // For now, let's just do nothing, effectively blocking them on the loading screen
              // or we could let them in with limited functionality.
              // Given the wrapper structure, they are blocked.
              // Let's add a "Skip" for notifications perhaps?
              // The user request was "Ask... if app not have".
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGrant();
            },
            child: const Text(
              'Grant Permission',
              style: TextStyle(
                color: Colors.indigoAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF020617),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigoAccent),
              SizedBox(height: 16),
              Text(
                'Checking permissions...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}

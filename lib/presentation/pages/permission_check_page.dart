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
    // On Android 12+, we need to request SCHEDULE_EXACT_ALARM permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    } else {
      setState(() {
        _permissionChecked = true;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Alarm Permission Required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'StepWake needs permission to schedule exact alarms to wake you up on time. '
          'This is required for the alarm to work reliably.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final status = await Permission.scheduleExactAlarm.request();
              setState(() {
                _permissionChecked = true;
              });

              if (status.isDenied && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Alarm permission is required for the app to work',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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

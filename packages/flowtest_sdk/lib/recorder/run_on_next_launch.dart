import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Schedule a flow to be replayed on the next app launch
Future<void> scheduleReplayOnNextLaunch({
  required String flowJson,
  double speed = 1.0,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('flowtest.replay_speed', speed);
  await prefs.setString('flowtest.pending_replay_json', flowJson);
}

/// Close the app for restart (platform-specific)
Future<void> closeAppForRestart() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    if (kDebugMode) exit(0); // dev-only
  }
}

/// Check if there's a pending replay and return the data
/// Returns null if no pending replay
Future<Map<String, dynamic>?> getPendingReplay() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('flowtest.pending_replay_json');
  if (json == null) return null;
  
  final speed = prefs.getDouble('flowtest.replay_speed') ?? 1.0;
  
  // Clear the pending replay
  await prefs.remove('flowtest.pending_replay_json');
  await prefs.remove('flowtest.replay_speed');
  
  return {
    'json': json,
    'speed': speed,
  };
}

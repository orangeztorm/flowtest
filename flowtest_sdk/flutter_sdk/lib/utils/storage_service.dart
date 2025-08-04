import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/test_flow.dart';

/// Professional storage service for saving and loading test flows
/// Handles cross-platform file operations safely
class StorageService {
  static const String _flowsDirectoryName = 'test_flows';

  /// Safe directory getter that works in all Flutter test environments
  /// Falls back to temp directory when platform channels are unavailable
  static Future<Directory> _safeDocsDir() async {
    try {
      return await getApplicationDocumentsDirectory(); // Real device / integration-test
    } catch (_) {
      // Widget-test or any env without platform channels
      return Directory.systemTemp.createTempSync('flowtest_');
    }
  }

  /// Save a test flow to device storage
  /// Uses platform-appropriate directories via path_provider
  static Future<String> saveFlow(TestFlow flow) async {
    try {
      // Get a safe directory that works in all test environments
      final directory = await _safeDocsDir();
      final flowsDir = Directory('${directory.path}/$_flowsDirectoryName');

      // Create the subdirectory if it doesn't exist
      if (!await flowsDir.exists()) {
        await flowsDir.create(recursive: true);
      }

      // Generate a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFlowId = flow.flowId.isNotEmpty
          ? Uri.encodeComponent(flow.flowId)
          : 'flow';
      final fileName = flow.flowId.isNotEmpty
          ? '${safeFlowId}_$timestamp.json'
          : 'flow_$timestamp.json';

      // Save the file
      final file = File('${flowsDir.path}/$fileName');
      final jsonString = json.encode(flow.toJson());
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw StorageException('Failed to save flow: $e');
    }
  }

  /// Save a test flow with a specific filename
  static Future<String> saveFlowWithName(TestFlow flow, String fileName) async {
    try {
      final directory = await _safeDocsDir();
      final flowsDir = Directory('${directory.path}/$_flowsDirectoryName');

      if (!await flowsDir.exists()) {
        await flowsDir.create(recursive: true);
      }

      // Ensure .json extension
      final safeName = fileName.endsWith('.json') ? fileName : '$fileName.json';
      final file = File('${flowsDir.path}/$safeName');

      // Handle file overwrite by deleting existing file
      if (await file.exists()) {
        await file.delete();
      }

      final jsonString = json.encode(flow.toJson());
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw StorageException('Failed to save flow with name $fileName: $e');
    }
  }

  /// Load a test flow from device storage by filename
  static Future<TestFlow> loadFlow(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_flowsDirectoryName/$fileName');

      if (!await file.exists()) {
        throw StorageException('Flow file not found: $fileName');
      }

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return TestFlow.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to load flow $fileName: $e');
    }
  }

  /// Load a test flow from app assets (for integration tests)
  /// This is the most reliable method for bundled test flows
  static Future<TestFlow> loadFlowFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return TestFlow.fromJson(data);
    } catch (e) {
      throw StorageException('Failed to load flow from asset $assetPath: $e');
    }
  }

  /// List all saved flow files in device storage
  static Future<List<String>> listSavedFlows() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final flowsDir = Directory('${directory.path}/$_flowsDirectoryName');

      if (!await flowsDir.exists()) {
        return [];
      }

      final files = await flowsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      return files.map((file) => file.path.split('/').last).toList();
    } catch (e) {
      throw StorageException('Failed to list flows: $e');
    }
  }

  /// Get the full path to the flows directory
  static Future<String> getFlowsDirectoryPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$_flowsDirectoryName';
    } catch (e) {
      throw StorageException('Failed to get flows directory path: $e');
    }
  }

  /// Delete a saved flow file
  static Future<bool> deleteFlow(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_flowsDirectoryName/$fileName');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw StorageException('Failed to delete flow $fileName: $e');
    }
  }
}

/// Custom exception for storage operations
class StorageException implements Exception {
  final String message;

  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

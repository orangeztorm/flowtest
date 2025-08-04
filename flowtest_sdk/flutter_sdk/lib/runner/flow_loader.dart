import 'dart:convert';
import 'dart:io';
import '../models/test_flow.dart';

/// Loads TestFlow objects from JSON files
class FlowLoader {
  const FlowLoader._();

  /// Load a TestFlow from a JSON file
  static Future<TestFlow> fromFile(String path) async {
    try {
      final jsonString = await File(path).readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return TestFlow.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load flow from $path: $e');
    }
  }

  /// Load a TestFlow from a JSON string
  static TestFlow fromJsonString(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return TestFlow.fromJson(data);
    } catch (e) {
      throw Exception('Failed to parse flow JSON: $e');
    }
  }

  /// Load multiple TestFlow objects from a directory
  static Future<List<TestFlow>> fromDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception('Directory does not exist: $directoryPath');
    }

    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    final flows = <TestFlow>[];
    for (final file in files) {
      try {
        final flow = await fromFile(file.path);
        flows.add(flow);
      } catch (e) {
        print('Warning: Failed to load ${file.path}: $e');
      }
    }

    return flows;
  }
}

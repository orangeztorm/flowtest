import 'package:flutter/material.dart';
import 'recorder_controller.dart';
import '../models/test_flow.dart';
import '../utils/storage_service.dart';

class RecorderToggle extends StatefulWidget {
  const RecorderToggle({super.key});

  @override
  State<RecorderToggle> createState() => _RecorderToggleState();
}

class _RecorderToggleState extends State<RecorderToggle> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Export button
          if (RecorderController.instance.steps.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                heroTag: 'export',
                onPressed: _exportFlow,
                backgroundColor: Colors.green,
                child: const Icon(Icons.download, color: Colors.white),
              ),
            ),
          // Record toggle button
          FloatingActionButton(
            heroTag: 'record',
            onPressed: _toggleRecording,
            backgroundColor: RecorderController.instance.isRecording
                ? Colors.red
                : Colors.blue,
            child: Icon(
              RecorderController.instance.isRecording
                  ? Icons.stop
                  : Icons.fiber_manual_record,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      if (RecorderController.instance.isRecording) {
        RecorderController.instance.stopRecording();
        _showSnackBar('Recording stopped');
      } else {
        RecorderController.instance.startRecording();
        _showSnackBar('Recording started');
      }
    });
  }

  void _exportFlow() async {
    try {
      final flowData = RecorderController.instance.exportToJson();
      final testFlow = TestFlow.fromJson(flowData);

      // Use StorageService for professional, cross-platform storage
      final filePath = await StorageService.saveFlow(testFlow);

      _showSnackBar('Flow exported to: ${filePath.split('/').last}');
      print('Flow exported to: $filePath'); // Log full path for easy access
    } catch (e) {
      _showSnackBar('Failed to export flow: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

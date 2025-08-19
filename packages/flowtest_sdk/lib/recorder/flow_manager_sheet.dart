import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/storage_service.dart';
import '../runner/flow_replayer.dart';
import '../models/test_flow.dart';
import 'run_on_next_launch.dart';
import 'bloc/flow_manager_bloc.dart';

class FlowManagerSheet extends StatefulWidget {
  const FlowManagerSheet({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  State<FlowManagerSheet> createState() => _FlowManagerSheetState();
}

class _FlowManagerSheetState extends State<FlowManagerSheet> {
  double _speed = 1.0;
  bool _restartApp = false;
  final TextEditingController _renameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load flows when the sheet opens
    context.read<FlowManagerBloc>().add(LoadFlows());
  }

  void _refresh() {
    context.read<FlowManagerBloc>().add(RefreshFlows());
  }

  Future<void> _rename(FlowFile f) async {
    _renameCtrl.text = f.name;
    final res = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Rename flow',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: TextField(
          controller: _renameCtrl,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'New name',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _renameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (res == null || res.isEmpty || res == f.name) return;

    // Use BLoC to handle the rename
    context.read<FlowManagerBloc>().add(RenameFlow(f.path, res));
  }

  Future<void> _delete(FlowFile f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete flow?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'This will delete "${f.name}".',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // Use BLoC to handle the delete
    context.read<FlowManagerBloc>().add(DeleteFlow(f.path));
  }

  Future<void> _playNow(BuildContext ctx, FlowFile f) async {
    try {
      final raw = await StorageService.readFlowJson(f.path);
      final flow = TestFlow.fromJson(jsonDecode(raw));

      // Close the bottom sheet first
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Get the root context before async operations
      final navCtx = Navigator.of(context).context; // root-ish

      // Show a snackbar to indicate playback is starting
      if (navCtx.mounted) {
        ScaffoldMessenger.of(navCtx).showSnackBar(
          SnackBar(
            content: Text('Playing flow: ${f.name}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      }

      await FlowReplayer(rootContext: navCtx, speed: _speed).replay(flow);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play flow: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restartAndPlay(FlowFile f) async {
    try {
      final raw = await StorageService.readFlowJson(f.path);
      await scheduleReplayOnNextLaunch(flowJson: raw, speed: _speed);
      await closeAppForRestart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule restart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Material(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Text('Flows', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Text('Speed'),
                    Expanded(
                      child: Slider(
                        value: _speed,
                        min: 0.25,
                        max: 2.0,
                        divisions: 7,
                        label: '${_speed.toStringAsFixed(2)}x',
                        onChanged: (v) => setState(() => _speed = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Restart & play'),
                      selected: _restartApp,
                      onSelected: (v) => setState(() => _restartApp = v),
                      avatar: const Icon(Icons.restart_alt),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: BlocBuilder<FlowManagerBloc, FlowManagerState>(
                  builder: (context, state) {
                    if (state is FlowManagerLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is FlowManagerError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading flows',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is FlowManagerLoaded) {
                      final files = state.flows;

                      // Show error message if there's an error
                      if (state.error != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      }

                      if (files.isEmpty) {
                        return const Center(child: Text('No flows saved yet.'));
                      }

                      return ListView.builder(
                        controller: controller,
                        itemCount: files.length,
                        itemBuilder: (_, i) {
                          final f = files[i];
                          return ListTile(
                            leading: const Icon(Icons.route),
                            title: Text(
                              f.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_fmtDate(f.modified)} • ${_fmtSize(f.size)}',
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Rename',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _rename(f),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(f),
                                ),
                                FilledButton.icon(
                                  icon: Icon(
                                    _restartApp
                                        ? Icons.restart_alt
                                        : Icons.play_arrow_rounded,
                                  ),
                                  label: Text(
                                    _restartApp ? 'Restart & play' : 'Play',
                                  ),
                                  onPressed: () => _restartApp
                                      ? _restartAndPlay(f)
                                      : _playNow(context, f),
                                ),
                              ],
                            ),
                            onTap: () => _restartApp
                                ? _restartAndPlay(f)
                                : _playNow(context, f),
                          );
                        },
                      );
                    }

                    return const Center(child: Text('No flows available'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _fmtDate(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

String _fmtSize(int b) {
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
  return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
}

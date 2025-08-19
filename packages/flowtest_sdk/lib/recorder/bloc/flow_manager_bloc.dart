import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../utils/storage_service.dart';

// Events
abstract class FlowManagerEvent extends Equatable {
  const FlowManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlows extends FlowManagerEvent {}

class RefreshFlows extends FlowManagerEvent {}

class DeleteFlow extends FlowManagerEvent {
  final String flowPath;

  const DeleteFlow(this.flowPath);

  @override
  List<Object?> get props => [flowPath];
}

class RenameFlow extends FlowManagerEvent {
  final String oldPath;
  final String newName;

  const RenameFlow(this.oldPath, this.newName);

  @override
  List<Object?> get props => [oldPath, newName];
}

// States
abstract class FlowManagerState extends Equatable {
  const FlowManagerState();

  @override
  List<Object?> get props => [];
}

class FlowManagerInitial extends FlowManagerState {}

class FlowManagerLoading extends FlowManagerState {}

class FlowManagerLoaded extends FlowManagerState {
  final List<FlowFile> flows;
  final String? error;

  const FlowManagerLoaded({required this.flows, this.error});

  @override
  List<Object?> get props => [flows, error];

  FlowManagerLoaded copyWith({List<FlowFile>? flows, String? error}) {
    return FlowManagerLoaded(
      flows: flows ?? this.flows,
      error: error ?? this.error,
    );
  }
}

class FlowManagerError extends FlowManagerState {
  final String message;

  const FlowManagerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FlowManagerBloc extends Bloc<FlowManagerEvent, FlowManagerState> {
  FlowManagerBloc() : super(FlowManagerInitial()) {
    on<LoadFlows>(_onLoadFlows);
    on<RefreshFlows>(_onRefreshFlows);
    on<DeleteFlow>(_onDeleteFlow);
    on<RenameFlow>(_onRenameFlow);
  }

  Future<void> _onLoadFlows(
    LoadFlows event,
    Emitter<FlowManagerState> emit,
  ) async {
    emit(FlowManagerLoading());
    try {
      final flows = await StorageService.listFlows();
      emit(FlowManagerLoaded(flows: flows));
    } catch (e) {
      emit(FlowManagerError(e.toString()));
    }
  }

  Future<void> _onRefreshFlows(
    RefreshFlows event,
    Emitter<FlowManagerState> emit,
  ) async {
    if (state is FlowManagerLoaded) {
      final currentState = state as FlowManagerLoaded;
      emit(currentState.copyWith(error: null));
    }

    try {
      final flows = await StorageService.listFlows();
      emit(FlowManagerLoaded(flows: flows));
    } catch (e) {
      emit(FlowManagerError(e.toString()));
    }
  }

  Future<void> _onDeleteFlow(
    DeleteFlow event,
    Emitter<FlowManagerState> emit,
  ) async {
    if (state is FlowManagerLoaded) {
      final currentState = state as FlowManagerLoaded;

      try {
        await StorageService.deleteFlow(event.flowPath);
        final updatedFlows = await StorageService.listFlows();
        emit(FlowManagerLoaded(flows: updatedFlows));
      } catch (e) {
        emit(currentState.copyWith(error: e.toString()));
      }
    }
  }

  Future<void> _onRenameFlow(
    RenameFlow event,
    Emitter<FlowManagerState> emit,
  ) async {
    if (state is FlowManagerLoaded) {
      final currentState = state as FlowManagerLoaded;

      try {
        await StorageService.renameFlow(event.oldPath, event.newName);
        final updatedFlows = await StorageService.listFlows();
        emit(FlowManagerLoaded(flows: updatedFlows));
      } catch (e) {
        emit(currentState.copyWith(error: e.toString()));
      }
    }
  }
}

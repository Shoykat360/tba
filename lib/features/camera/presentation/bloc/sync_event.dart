import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingUploadsEvent extends SyncEvent {
  const LoadPendingUploadsEvent();
}

class TriggerUploadEvent extends SyncEvent {
  const TriggerUploadEvent();
}

class StartConnectivityMonitorEvent extends SyncEvent {
  const StartConnectivityMonitorEvent();
}

class ConnectivityStatusChangedEvent extends SyncEvent {
  final bool isConnected;
  const ConnectivityStatusChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

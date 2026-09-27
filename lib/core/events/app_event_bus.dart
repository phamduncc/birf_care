import 'dart:async';

enum AppDataChangeEvent {
  birds,
  healthLogs,
  diary,
  reminders,
  breeding,
  all,
}

class AppEventBus {
  static final AppEventBus instance = AppEventBus._internal();
  final StreamController<AppDataChangeEvent> _controller = StreamController<AppDataChangeEvent>.broadcast();

  AppEventBus._internal();

  Stream<AppDataChangeEvent> get stream => _controller.stream;

  void notify(AppDataChangeEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void notifyAll() {
    notify(AppDataChangeEvent.all);
  }
}

import 'package:event_bus/event_bus.dart';

class EventBusUtil {
  static final EventBusUtil of = EventBusUtil._();
  EventBusUtil._();

  final EventBus _eventBus = EventBus();

  EventBus get eventBus {
    return _eventBus;
  }

  Stream<T> on<T>() {
    return _eventBus.on();
  }

  void fire(dynamic event) {
    return _eventBus.fire(event);
  }

  void onDestroy() {
    eventBus.destroy();
  }
}


/// event
class EventRefreshComments {
  final String relType;
  EventRefreshComments(this.relType);
}

/// event
class EventRefreshMyPageList {}

import 'package:event_bus/event_bus.dart';

import '../page/search/search_screen.dart';
import '../page/search_tag/search_tag_screen.dart';

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
class EventRefreshPage {
  final String relType;

  EventRefreshPage(this.relType);
}

class EventRefreshNum {
  final int? commentCount;
  final int? likeCount;
  final int? favoriteCount;
  final int? viewCount;
  final int id;

  EventRefreshNum(this.id, {this.commentCount, this.likeCount, this.favoriteCount, this.viewCount});
}

/// event
class EventRefreshSearchResult {
  final SearchType searchType;

  EventRefreshSearchResult(this.searchType);
}

/// event
class EventResetMainTab {}

/// event
class EventRefreshFeedTabs {}

/// event
class EventLoginSuccess {}

class EventRefreshName{
  final String name;

  EventRefreshName(this.name);
}
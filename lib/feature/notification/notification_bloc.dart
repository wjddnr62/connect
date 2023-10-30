import 'package:connect/data/push_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/push_history.dart';
import 'package:connect/widgets/base_widget.dart';

class NotificationBloc extends BaseBloc {
  NotificationBloc() : super(PageInitState());

  int _page = -1;
  bool reachLast = false;
  final List<PushHistory> notifies = List();
  final int size = 15;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    debugPrint("$runtimeType receive event! $event");

    if (event is LoadNextPageEvent) {
      if (reachLast) {
        yield LastPageLoadState();
        return;
      }

      _page++;

      final history = await PushRepository.getPushHistory(_page, size);
      if (history is ServiceError) {
        yield ErrorOccurState(history);
        return;
      }

      notifies.addAll(history.contents);

      if (_page == history.page_info.total_page - 1) {
        reachLast = true;
      }

      yield PageRefreshState();
      return;
    }

    if (event is ReadHistoryEvent) {
      final update = await PushRepository.readUpdate(event.history);
      if (update is ServiceError) {
        debugPrint("fail !! ${update.code}  / ${update.message}");
      }
      event.history.isRead = true;
      yield PageRefreshState();
    }

    if (event is AllReadHistoryEvent) {
      await PushRepository.readAllUpdate();
    }

    return;
  }
}

// ignore: must_be_immutable
class PageInitState extends BaseBlocState {}

// ignore: must_be_immutable
class PageRefreshState extends BaseBlocState {
  final DateTime time = DateTime.now();

  @override
  get props => [time];
}

// ignore: must_be_immutable
class LastPageLoadState extends PageRefreshState {}

// ignore: must_be_immutable
class ErrorOccurState extends BaseBlocState {
  final ServiceError e;

  ErrorOccurState(this.e);

  @override
  get props => [e];
}

// ignore: must_be_immutable
class LoadNextPageEvent extends BaseBlocEvent {
  final DateTime time = DateTime.now();

  @override
  get props => [time];

  @override
  String get tag => null;
}

// ignore: must_be_immutable
class ReadHistoryEvent extends BaseBlocEvent {
  final PushHistory history;

  ReadHistoryEvent(this.history);

  @override
  get props => [history.notify.historyId];

  @override
  String get tag => null;
}

class AllReadHistoryEvent extends BaseBlocEvent {
  @override
  String get tag => null;
}

class NotificationPageResult {
  final String type;
  final bool isReadBeforeClick;

  NotificationPageResult({this.type, this.isReadBeforeClick});
}

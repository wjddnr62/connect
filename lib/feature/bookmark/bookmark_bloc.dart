import 'package:connect/data/bookmark_repository.dart';
import 'package:connect/models/bookmark.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/widgets/base_widget.dart';

import '../base_bloc.dart';

class BookmarkBloc extends BaseBloc {
  BookmarkBloc(BuildContext context) : super(BaseBookmarkState());

  bool isLoading = false;
  int selectTap = 0;
  List<MissionRenewal> missions = List();
  List<Mission> readingMissions = List();
  List<Mission> exerciseMissions = List();
  Bookmark bookmarks;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    yield CheckState();
    if (event is BookmarkInitEvent) {
      isLoading = true;
      yield LoadingState();
      missions = List();
      readingMissions = List();
      exerciseMissions = List();

      bookmarks = await BookmarkRepository.bookmarkInquiryList();
      if (bookmarks != null) {
        if (bookmarks.readings.length != 0) {
          bookmarks.readings.forEach((element) {
            readingMissions.add(element);
          });
        }

        if (bookmarks.exercises.length != 0) {
          bookmarks.exercises.forEach((element) {
            exerciseMissions.add(element);
          });
        }
      }

      isLoading = false;
      yield BookmarkInitState();
    }

    if (event is TapSelectEvent) {
      selectTap = event.selectIndex;
      yield TapSelectState();
    }
  }
}

class TapSelectEvent extends BaseBlocEvent {
  final int selectIndex;

  TapSelectEvent({this.selectIndex});
}

class LoadingState extends BaseBlocState {}

class TapSelectState extends BaseBlocState {}

class BookmarkInitEvent extends BaseBlocEvent {}

class BookmarkInitState extends BaseBlocState {}

class BaseBookmarkState extends BaseBlocState {}

class CheckState extends BaseBlocState {}

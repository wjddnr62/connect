import 'package:connect/feature/base_bloc.dart';
import 'package:connect/widgets/base_widget.dart';

class IntroBloc extends BaseBloc {
  IntroBloc(BuildContext context) : super(BaseIntroState());

  int swipeIndex = 0;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield LoadingState();

    if (event is SwipeIndexChangeEvent) {
      swipeIndex = event.index;

      yield SwipeIndexChangeState();
    }
  }
}

class SwipeIndexChangeEvent extends BaseBlocEvent {
  final int index;

  SwipeIndexChangeEvent({this.index});
}

class SwipeIndexChangeState extends BaseBlocState {}

class IntroInitEvent extends BaseBlocEvent {}

class BaseIntroState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

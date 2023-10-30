import 'package:connect/feature/base_bloc.dart';
import 'package:connect/widgets/base_widget.dart';

class SignUpSelectBloc extends BaseBloc {
  SignUpSelectBloc(BuildContext context) : super(BaseSignUpSelectState());

  bool isLoading = false;
  bool appleWeb = false;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield LoadingState();

    if (event is StartLoadingEvent) {
      isLoading = true;
      yield StartLoadingState();
    }

    if (event is StopLoadingEvent) {
      isLoading = false;
      yield StopLoadingState();
    }

    if (event is AppleLoginEvent) {
      if (event.type == 0) {
        appleWeb = true;
        yield AppleLoginState();
      } else if (event.type == 1) {
        appleWeb = false;
        isLoading = false;
        yield AppleLoginState();
      }
    }
  }
}

class AppleLoginEvent extends BaseBlocEvent {
  final int type;

  AppleLoginEvent({this.type});
}

class AppleLoginState extends BaseBlocState {}

class StartLoadingEvent extends BaseBlocEvent {}

class StartLoadingState extends BaseBlocState {}

class StopLoadingEvent extends BaseBlocEvent {}

class StopLoadingState extends BaseBlocState {}

class SignUpSelectInitEvent extends BaseBlocEvent {}

class BaseSignUpSelectState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

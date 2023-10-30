import 'package:connect/feature/base_bloc.dart';
import 'package:connect/widgets/base_widget.dart';

class FeedbackBloc extends BaseBloc {
  FeedbackBloc(BuildContext context) : super(BaseFeedBackState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is FeedBackInitEvent) {

      yield FeedBackInitState();
    }
  }

}

class FeedBackInitEvent extends BaseBlocEvent {}

class FeedBackInitState extends BaseBlocState {}

class BaseFeedBackState extends BaseBlocState {}
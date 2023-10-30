import 'package:connect/feature/base_bloc.dart';
import 'package:connect/widgets/base_widget.dart';

class ForgotPasswordBloc extends BaseBloc {
  ForgotPasswordBloc(BuildContext context) : super(BaseForgotPasswordState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) {
    // TODO: implement mapEventToState
  }
}

class BaseForgotPasswordState extends BaseBlocState {}

class ForgotPasswordInitEvent extends BaseBlocEvent {}
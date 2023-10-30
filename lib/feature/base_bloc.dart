import 'package:bloc/bloc.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BaseBloc extends Bloc<BaseBlocEvent, BaseBlocState> {
  final String _tag = 'BaseBloc';

  BaseBloc(BaseBlocState initialState) : super(initialState);

  @override
  void onError(Object error, StackTrace stacktrace) {
    Log.d(_tag, 'onError : $stacktrace');
    super.onError(error, stacktrace);
  }

}

@immutable
abstract class BaseBlocEvent extends Equatable {
  String get tag => null;

  @override
  List<Object> get props => [DateTime.now()];
}

@immutable
abstract class BaseBlocState extends Equatable {
  String get tag => null;

  @override
  List<Object> get props => [DateTime.now()];
}

class ShowError extends BaseBlocState {
  final ServiceError error;

  ShowError({this.error}) : assert(error != null);
}

class Load extends BaseBlocEvent {}

class Loading extends BaseBlocState {}

class GoHome extends BaseBlocState {}

class GoSplashToInitService extends BaseBlocState {}

import 'package:connect/feature/base_bloc.dart';
import 'package:flutter/material.dart';

import '../base_widget.dart';
import '../dialog/fullscreen_dialog.dart';

typedef CreateWidget = Widget Function(_LoadingBloc bloc);
typedef CreateAppBar = Widget Function(BuildContext context);

class LoadingContainer extends BlocStatefulWidget {
  final CreateWidget createWidget;
  final CreateAppBar createAppBar;

  LoadingContainer({this.createWidget, this.createAppBar})
      : assert(createWidget != null);
  @override
  BlocState<BaseBloc, BlocStatefulWidget> buildState() {
    return _LoadingState<LoadingContainer>(
      createAppBar:
          createAppBar != null ? (context) => createAppBar(context) : null,
      createWidget: (state) => createWidget(state),
    );
  }
}

class _LoadingState<T extends BlocStatefulWidget>
    extends BlocState<_LoadingBloc, T> {
  final CreateWidget createWidget;
  final CreateAppBar createAppBar;

  _LoadingState({this.createWidget, this.createAppBar});

  @override
  Widget blocBuilder(BuildContext context, state) {
    return Scaffold(
        appBar: createAppBar != null ? createAppBar(context) : null,
        body: Stack(children: <Widget>[
          createWidget(bloc),
          state is _ContentLoading ? FullscreenDialog() : Container(),
        ]));
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  _LoadingBloc initBloc() {
    return _LoadingBloc(_ContentLoading());
  }
}

class _LoadingBloc extends BaseBloc {
  _LoadingBloc(BaseBlocState initialState) : super(initialState);

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is _LoadContent) {
      yield _ContentLoading();
    }

    if (event is _CompleteToContentLoading) {
      yield _ContentLoaded();
    }
  }

  @override
  void add(BaseBlocEvent event) {
    super.add(event);
  }

  addLoadContentEvent() {
    add(_LoadContent());
  }

  addCompleteToContentLoadingEvent() {
    add(_CompleteToContentLoading());
  }
}

class _LoadContent extends BaseBlocEvent {}

class _CompleteToContentLoading extends BaseBlocEvent {}

class _ContentLoading extends BaseBlocState {}

class _ContentLoaded extends BaseBlocState {}

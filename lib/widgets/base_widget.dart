import 'package:connect/feature/base_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:connect/widgets/base_appbar.dart';
export 'package:flutter/widgets.dart';

abstract class BasicPage extends StatelessWidget {
  void handleArgument(BuildContext context);

  Widget buildWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    handleArgument(context);
    return buildWidget(context);
  }
}

abstract class BasicStatelessWidget extends StatelessWidget
    with WidgetsBindingObserver {
  const BasicStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    init(context);
    WidgetsBinding.instance.addObserver(this);
    return buildWidget(context);
  }

  init(BuildContext context) {}

  Widget buildWidget(BuildContext context);

  @override
  Future<bool> didPopRoute() {
    WidgetsBinding.instance.removeObserver(this);
    return super.didPopRoute();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }
}

abstract class BasicStatefulWidget extends StatefulWidget
    with WidgetsBindingObserver {
  const BasicStatefulWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    init();
    return buildState();
  }

  init() {}

  BasicState buildState();
}

abstract class BlocStatefulWidget extends StatefulWidget {
  const BlocStatefulWidget({Key key}) : super(key: key);

  @override
  State<BlocStatefulWidget> createState() {
    init();
    return buildState();
  }

  init() {}

  BlocState buildState();
}

abstract class BasicState<T extends BasicStatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @mustCallSuper
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    init(context);
    return buildWidget(context);
  }

  init(BuildContext context) {}

  Widget buildWidget(BuildContext context);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

enum StateCondition { AllChanged, TypeChanged }

abstract class BlocState<B extends BaseBloc, T extends BlocStatefulWidget>
    extends State<T> with WidgetsBindingObserver {
  B _bloc;
  var currState;
  var prevState;
  final StateCondition conditionType;

  BlocState({this.conditionType = StateCondition.TypeChanged});

  initState() {
    WidgetsBinding.instance.addObserver(this);
    _bloc = initBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    init(context);

    return BlocListener(
        cubit: _bloc,
        listenWhen: (previousState, currentState) =>
            _blocCondition(previousState, currentState),
        listener: (context, state) => blocListener(context, state),
        child: BlocBuilder(
            cubit: _bloc,
            builder: (context, state) => blocBuilder(context, state)));
  }

  init(BuildContext context) {}

  B initBloc();

  B get bloc => _bloc;

  blocListener(BuildContext context, dynamic state);

  Widget blocBuilder(BuildContext context, dynamic state);

  bool _blocCondition(dynamic previousState, dynamic currentState) {
    prevState = previousState;
    currState = currentState;

    bool ret = conditionType == StateCondition.AllChanged ||
        currentState != previousState;

    return ret;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

push(BuildContext context, Widget widget, {bool asDialog = false}) async {
  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => widget, fullscreenDialog: asDialog));
}

pop(BuildContext context) {
  Navigator.pop(context);
}

popWithResult(BuildContext context, result) {
  Navigator.of(context).pop(result);
}

popUntilNamed(BuildContext context, String name) {
  Navigator.of(context).popUntil((predicate) {
    if (predicate.settings.name == name) {
      return true;
    }
    return false;
  });
}

pushNamedAndRemoveUntil(BuildContext context, String name,
    {RoutePredicate predicate}) {
  Navigator.pushNamedAndRemoveUntil(
      context,
      name,
      predicate == null
          ? (value) {
              return false;
            }
          : predicate);
}

bool canPop(BuildContext context) => Navigator.canPop(context);

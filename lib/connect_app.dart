import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connect/data/clinic_repository.dart';
import 'package:connect/data/duration_repository.dart';
import 'package:connect/feature/evaluation/evaluation_provider.dart';
import 'package:connect/feature/home/MissionProvider.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/user_properties.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connect_config.dart';
import 'connect_firebase.dart';
import 'connect_routes.dart';
import 'data/contents_repository.dart';
import 'data/local/app_dao.dart';
import 'feature/base_bloc.dart';
import 'feature/splash/splash_page.dart';
import 'user_log/user_logger.dart';
import 'utils/connectivity/connectivity_monitor.dart';

class SettingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

SharedPreferences prefs;

mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initCrashlytics();

  Bloc.observer = _ConnectBlocSupervisor();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  InAppPurchaseConnection.enablePendingPurchases();

  HttpOverrides.global = SettingHttpOverrides();

  prefs = await SharedPreferences.getInstance();

  if (gProduction != 'prod-release') {
    if ((prefs.getString('set') ?? "DEV") == "DEV") {
      gFlavor = Flavor.DEV;
      if (kReleaseMode) {
        gProduction = 'dev-release';
      } else {
        gProduction = 'dev-debug';
      }
    } else if (prefs.getString('set') == "STAGE") {
      gFlavor = Flavor.STAGE;

      if (kReleaseMode) {
        gProduction = 'stage-release';
      } else {
        gProduction = 'stage-debug';
      }
    } else if (prefs.getString('set') == "PROD") {
      gFlavor = Flavor.PROD;
      if (kReleaseMode) {
        gProduction = 'prod-release';
      } else {
        gProduction = 'prod-debug';
      }
    }
  }

  runApp(ConnectApp());

  Timer timer = Timer.periodic(Duration(minutes: 1), (timer) async {
    if (await AppDao.accessToken != null) {
      String date =
          "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
      DurationRepository.durationUpdate(date);
    }
  });

  SystemChannels.lifecycle.setMessageHandler((message) {
    if (message == AppLifecycleState.paused.toString()) {
      timer.cancel();
    } else if (message == AppLifecycleState.resumed.toString()) {
      timer = Timer.periodic(Duration(minutes: 1), (timer) async {
        if (await AppDao.accessToken != null) {
          String date =
              "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
          DurationRepository.durationUpdate(date);
        }
      });
    }
    return null;
  });
}

_initCrashlytics() {
  // Crashlytics init
  Crashlytics.instance.enableInDevMode = false;
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
}

class _ConnectBlocSupervisor extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (transition.event is BaseBlocEvent) {
      Log.d('BLOC_SUPERVISOR',
          '[onTransition] : bloc = $bloc, transition.event = ${transition.event}');
      // Log.d('BLOC_SUPERVISOR',
      //     '[onTransition] : bloc = $bloc, transition.event.tag = ${transition.event.tag}');

      UserLogger.logEvent(blocEvent: transition.event);
    }

    if (transition.nextState is BaseBlocState) {
      Log.d('BLOC_SUPERVISOR',
          '[onTransition] : bloc = $bloc, transition.nextState = ${transition.nextState}');
      // Log.d('BLOC_SUPERVISOR',
      //     '[onTransition] : bloc = $bloc, transition.nextState.tag = ${transition.nextState.tag}');
      UserLogger.logState(blocState: transition.nextState);
    }
  }

  @override
  void onError(Cubit bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    Log.d('BLOC_SUPERVISOR',
        '[onError] : bloc = $bloc, error = $error, stacktrace = ${stacktrace.toString()}');
  }
}

/// Application
class ConnectApp extends StatelessWidget {
  final routeObserver = RouteObserver<PageRoute>();

  ConnectApp() {
    Log.d('ConnectApp', 'Flavor is $gFlavor');

    /// set user properties for user log on firebase
    UserProperties.productType();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ConnectivityMonitor()),
          ChangeNotifierProvider(create: (_) => ContentsRepository()),
          ChangeNotifierProvider(create: (_) => ClinicRepository()),
          ChangeNotifierProvider(
            create: (_) => MissionProvider()..init(),
          ),
          ChangeNotifierProvider(
            create: (_) => EvaluationProvider(),
          ),
          Provider.value(value: routeObserver)
        ],
        child: Phoenix(
          child: MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.cyan,
              accentColor: AppColors.orange,
            ),
            initialRoute: SplashPage.ROUTE_BEFORE_INTRO,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: gAnalytics),
              ScreenRouteObserver(),
              routeObserver
            ],
            routes: routes(context),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child,
              );
            },
          ),
        ));
  }
}

class ScreenRouteObserver extends NavigatorObserver {
  final _tag = 'ROUTE';

  /// to avoid logging duplicated.
  String _routeName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    Log.d(_tag,
        "=====================================================================>");
    Log.d(_tag, 'didPush:route = ${route?.settings?.name}');
    Log.d(_tag, 'didPush:previousRoute = ${previousRoute?.settings?.name}');
    Log.d(_tag,
        "=====================================================================>");

    /// to avoid logging duplicated.
    if (_routeName != route?.settings?.name) {
      UserLogger.screen(screen: '${route?.settings?.name}');
    }

    /// route name is null means that a page routed to front using page object not name
    /// ex> fullscreen popup or dialog.
    /// to avoid logging duplicated.
    if (route?.settings?.name != null) {
      _routeName = route?.settings?.name;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    Log.d(_tag,
        "<=====================================================================");
    Log.d(_tag, 'didPop:route = ${route?.settings?.name}');
    Log.d(_tag, 'didPop:previousRoute = ${previousRoute?.settings?.name}');
    Log.d(_tag,
        "<=====================================================================");

    /// to avoid logging duplicated.
    if (_routeName != previousRoute?.settings?.name) {
      UserLogger.screen(screen: '${previousRoute?.settings?.name}');
    }
    _routeName = previousRoute?.settings?.name;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    Log.d(_tag, 'didRemove:route = ${route?.settings?.name}');
    Log.d(_tag, 'didRemove:previousRoute = ${previousRoute?.settings?.name}');
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    Log.d(_tag, 'didReplace:newRoute = ${newRoute?.settings?.name}');
    Log.d(_tag, 'didReplace:oldRoute = ${oldRoute?.settings?.name}');

    /// to avoid logging twice.
    if (_routeName != newRoute?.settings?.name) {
      UserLogger.screen(screen: '${newRoute?.settings?.name}');
    }
    _routeName = newRoute?.settings?.name;
  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic> previousRoute) {
    Log.d(_tag, 'didStartUserGesture:route = ${route?.settings?.name}');
    Log.d(_tag,
        'didStartUserGesture:previousRoute = ${previousRoute?.settings?.name}');
  }

  @override
  void didStopUserGesture() {
    Log.d(_tag, 'didStopUserGesture');
  }
}

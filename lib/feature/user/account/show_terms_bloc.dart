import 'dart:collection';
import 'dart:convert';

import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/user_log/events.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShowTermsBloc extends BaseBloc {
  ShowTermsBloc() : super(TermsLoading());

  bool showAgree = false;
  Queue<Map> termsQueue = Queue();

  TermsType get type => termsQueue.isNotEmpty ? termsQueue.first['type'] : null;

  String get terms => termsQueue.isNotEmpty ? termsQueue.first['html'] : '';
  WebViewController _controller;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is TermsInit) {
      yield TermsLoading();
      showAgree = event.showAgree;
      // CALL SIGN UP
      if (event.terms == null) {
        assert(event.showAgree);
        termsQueue.addAll(await UserRepository.getTerms(type: TermsType.ALL));
        yield WebViewShow();
      }
      // CALL ONLY VIEWING (Payment, Home bottom...)
      else if (event.terms.length == 1 && event.terms.first['html'] == null) {
        assert(!event.showAgree);
        termsQueue.addAll(
            await UserRepository.getTerms(type: event.terms.first['type']));
        yield WebViewShow();
      }
      // CALL NEW TERMS AGREE
      else {
        assert(event.showAgree);
        termsQueue.addAll(event.terms);
        yield WebViewShow();
      }
    }

    if (event is FinishToLoadWebPage) {
      yield NextTermsShow();
    }
    if (event is TermsWebViewCreatedEvent) {
      _controller = event.controller;
      _loadHtml();
    }
    if (event is AgreeTerms) {
      yield TermsLoading();
      final current = termsQueue.removeFirst();
      if (await UserRepository.active) {
        var response = await UserRepository.agreeTerms(type: current['type']);
        if (response is ServiceError) {
          termsQueue.addFirst(current);
          yield ShowError(error: response);
          return;
        }
        yield termsQueue.isEmpty ? UpdatedAgreeTerms() : WebViewShow();
      } else
        yield termsQueue.isEmpty
            ? CompletedAgreeTermsOnSignup()
            : WebViewShow();

      if (termsQueue.isNotEmpty) _loadHtml();
    }
  }

  void _loadHtml() {
    _controller.loadUrl(Uri.dataFromString(terms,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}

class TermsInit extends BaseBlocEvent {
  final List<Map> terms;
  final bool showAgree;

  TermsInit({this.terms, this.showAgree});
}

class TermsLoading extends BaseBlocState {}

class NextTermsShow extends BaseBlocState {}

class UpdatedAgreeTerms extends BaseBlocState {}

class WebViewShow extends BaseBlocState {}

class AgreeTerms extends BaseBlocEvent {}

class CompletedAgreeTermsOnSignup extends BaseBlocState {
  @override
  String get tag => EventSign.SIGNUP_AGREE_TERMS;
}

class TermsWebViewCreatedEvent extends BaseBlocEvent {
  final WebViewController controller;

  TermsWebViewCreatedEvent(this.controller);
}

class FinishToLoadWebPage extends BaseBlocEvent {}

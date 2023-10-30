import 'package:connect/connect_config.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/container/loading_container.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContributorPage extends BasicPage {
  static const String ROUTE_NAME = '/contribute_page';
  static const String _webUrlPath = "ui/connect-contributors.html";

  static void push(BuildContext context) {
    Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return LoadingContainer(
        createAppBar: (context) => baseAppBar(context),
        createWidget: (bloc) => WebView(
            initialUrl: baseUrl + _webUrlPath,
            onWebViewCreated: (controller) {
              controller.clearCache();
            },
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (_) {
              bloc.addCompleteToContentLoadingEvent();
            },
            // navigationDelegate: (navigation) async {
            //   var url = navigation.url;
            //   if (url?.isNotEmpty == true &&
            //       url != _webUrlPath &&
            //       await canLaunch(url)) {
            //     launch(url);
            //     return NavigationDecision.prevent;
            //   }
            //   return NavigationDecision.navigate;
            // }
            ));
  }

  void handleArgument(BuildContext context) {}
}

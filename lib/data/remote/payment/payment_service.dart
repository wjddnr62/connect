import 'package:connect/models/payment.dart';
import 'package:http/http.dart' as http;

import '../base_service.dart';

class VerifyPaymentServiceForAndroid extends BaseService<PaymentResult> {
  final ReceiptForAndroid receiptAndroid;
  VerifyPaymentServiceForAndroid(this.receiptAndroid);

  @override
  Future<http.Response> request() async {
    return fetchPost(body: jsonEncode(receiptAndroid.toJson()));
  }

  @override
  setUrl() {
    return baseUrl + 'payment/api/v1/verify';
  }

  @override
  PaymentResult success(body) {
    PaymentResult ret = PaymentResult.fromJson(body);
    return ret;
  }
}

class VerifyPaymentServiceForIOS extends BaseService<PaymentResult> {
  final ReceiptForIOS receiptIOS;
  VerifyPaymentServiceForIOS(this.receiptIOS);

  @override
  Future<http.Response> request() async {
    return fetchPost(body: jsonEncode(receiptIOS.toJson()));
  }

  @override
  setUrl() {
    return baseUrl + 'payment/api/v1/appstore/subscriptions/purchase';
  }

  @override
  PaymentResult success(body) {
    PaymentResult ret = PaymentResult.fromJson(body);
    return ret;
  }
}

/// 무료 결제
/// Home 유저인 경우 무료로 3개월 사용할 수 있도록 함
class NeofectPaymentService extends BaseService<PaymentResult> {
  @override
  Future<http.Response> request() async {
    return fetchPost();
  }

  @override
  setUrl() {
    return baseUrl + 'payment/api/v1/neofect/subscriptions/purchase';
  }

  @override
  PaymentResult success(body) {
    PaymentResult ret = PaymentResult.fromJson(body);
    return ret;
  }
}

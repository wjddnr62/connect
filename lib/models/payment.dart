import 'dart:core';
import 'dart:core';

import 'package:connect/data/remote/base_service.dart';
import 'package:flutter/material.dart';

class ReceiptForAndroid {
  final String packageName;
  final String subscriptionId;
  final String purchaseToken;
  final String orderingUserId;
  final String discountCode;

  ReceiptForAndroid(
      {@required this.packageName,
      @required this.subscriptionId,
      @required this.purchaseToken,
      this.orderingUserId,
      this.discountCode})
      : assert(packageName != null),
        assert(subscriptionId != null),
        assert(purchaseToken != null);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['packageName'] = this.packageName;
    data['subscriptionId'] = this.subscriptionId;
    data['purchaseToken'] = this.purchaseToken;
    data['orderingUserId'] = this.orderingUserId;
    data['discountCode'] = this.discountCode;
    return data;
  }
}

class ReceiptForIOS {
  final String receipt;
  final double price;
  final String currencyCode;
  final String countryCode;
  final String discountCode;

  ReceiptForIOS(
      {@required this.receipt,
      @required this.price,
      @required this.currencyCode,
      this.countryCode,
      this.discountCode})
      : assert(receipt != null),
        assert(price != null),
        assert(currencyCode != null);

  factory ReceiptForIOS.fromJson(Map<String, dynamic> json) {
    return ReceiptForIOS(
      receipt: json['receipt'],
      price: json['price'],
      currencyCode: json['currencyCode'],
      countryCode: json['countryCode'],
      discountCode: json['discountCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['receipt'] = this.receipt;
    data['price'] = this.price;
    data['currencyCode'] = this.currencyCode;
    data['countryCode'] = this.countryCode;
    data['discountCode'] = this.discountCode;
    return data;
  }
}

class PaymentResult {
  final String orderId;
  final String transactionId;
  final String status;

  PaymentResult({this.orderId, this.transactionId, this.status});

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      orderId: json['orderId'],
      transactionId: json['transactionId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['transactionId'] = this.transactionId;
    data['status'] = this.status;
    return data;
  }
}

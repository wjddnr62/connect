import 'dart:async';
import 'dart:io';

import 'package:connect/data/remote/payment/payment_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/payment.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

import '../base_bloc.dart';

class PaymentDescriptionBloc extends BaseBloc {
  final _tag = "PaymentDescriptionBloc";

  PaymentDescriptionBloc(BuildContext context)
      : super(BasePaymentDescriptionState()) {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      Log.d(_tag, "onDone");
      _subscription.cancel();
    }, onError: (error) {
      Log.d(_tag, "onError");
      add(PaymentSubscriptionFailed(error));
    });
  }

  Future<void> finishTransactionForIOS() async {
    if (Platform.isIOS) {
      SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
      var transactions = await paymentQueue.transactions();

      await Future.forEach(transactions, (sk) async {
        if (sk.transactionIdentifier != null &&
            (sk.transactionState !=
                    SKPaymentTransactionStateWrapper.purchasing ||
                sk.transactionState !=
                    SKPaymentTransactionStateWrapper.restored)) {
          try {
            await paymentQueue.finishTransaction(sk);
          } catch (e) {
            Log.i(_tag, "Failed To finish Transaction");
          }
        }
      });
    }
    await Future.delayed(Duration(milliseconds: 100));
  }

  List<ProductDetails> _availableProducts;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  final Set<String> _productIds = {
    'com.neofect.connect.yearly_subscription',
    'com.neofect.connect.6_monthly_subscription',
    'com.neofect.connect.3_monthly_subscription',
    'com.neofect.connect.monthly_subscription'
  };

  var subscriptionItem;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield LoadingState();
    if (event is HomeUserPayment) {
      yield HomeUserPaymentSubscribing();

      dynamic response = await NeofectPaymentService().start();

      if (response is ServiceError) {
        ServiceError error = response;
        yield HomeUserPaymentFailure(message: error.message);
        return;
      }

      if (response is PaymentResult) {
        Log.d("paymentResult : ",
            "success to verify payment : " + response.toString());
      }

      appsflyer.saveLog(accountStart);
      await UserRepository.getProfile();
      yield HomeUserPaymentSuccess();
    }

    if (event is ConnectUserPayment) {
      yield ConnectUserPaymentState();
    }

    if (event is PaymentCheck) {
      yield PaymentCheckInProgress();
      //스토어를 이용할 수 있는지 확인
      final bool available =
          await InAppPurchaseConnection.instance.isAvailable();
      if (!available) {
        //스토어를 사용할 수 없음
        yield PaymentNotAvailable();
        return;
      } else {
        final ProductDetailsResponse response = await InAppPurchaseConnection
            .instance
            .queryProductDetails(_productIds);
        if (response.notFoundIDs.isNotEmpty) {
          //이용할 수 있는 상품이 없음
          yield PaymentProductNotFound();
        } else {
          _availableProducts = response.productDetails;

          PurchaseDetails uncompletedPurchase;
          if (uncompletedPurchase == null) yield PaymentAvailable();
        }
      }
    }

    if (event is PaymentCheckUncompletedPurchase) {
      yield PaymentSubscribing();
      PurchaseDetails uncompletedPurchase;
      try {
        uncompletedPurchase = await getUncompletedPurchase();
        yield* _mapReceiptVerificationEventToState(uncompletedPurchase, false);
      } catch (e) {
        Log.d(_tag, e.toString());
        yield PaymentSubscribeFailure(e.toString());
        return;
      }
      if (uncompletedPurchase == null)
        yield PaymentSubscribeFailure("not found pastPurchase");
    }

    //구독
    if (event is PaymentSubscribe) {
      for (int i = 0; i < _availableProducts.length; i++) {
        if (event.type == 0) {
          if (!_availableProducts[i].id.contains("_monthly") &&
              _availableProducts[i].id.contains("monthly")) {
            subscriptionItem = _availableProducts[i];
            add(PaymentSubscribeing());
            break;
          }
        } else if (event.type == 1) {
          if (_availableProducts[i].id.contains("3_monthly")) {
            subscriptionItem = _availableProducts[i];
            add(PaymentSubscribeing());
            break;
          }
        } else if (event.type == 2) {
          if (_availableProducts[i].id.contains("6_monthly")) {
            subscriptionItem = _availableProducts[i];
            add(PaymentSubscribeing());
            break;
          }
        } else if (event.type == 3) {
          if (_availableProducts[i].id.contains("yearly")) {
            subscriptionItem = _availableProducts[i];
            add(PaymentSubscribeing());
            break;
          }
        }
      }
    }

    if (event is PaymentSubscribeing) {
      try {
        await InAppPurchaseConnection.instance.buyNonConsumable(
            purchaseParam: new PurchaseParam(
                productDetails: subscriptionItem)); //, applicationUserName: ));
      } on PlatformException catch (e) {
//        yield PaymentSubscribeFailure(e.toString());
        if (Platform.isIOS) {
          Log.i(_tag, "Purchase Exception=" + e.toString());
          await finishTransactionForIOS();
          if (e.code == 'storekit_duplicate_product_object') {
            try {
              await InAppPurchaseConnection.instance.buyNonConsumable(
                  purchaseParam:
                      new PurchaseParam(productDetails: subscriptionItem));
            } on PlatformException catch (e) {
              yield PaymentSubscribeFailure(e.toString());
            }
          } else {
            yield PaymentSubscribeFailure(e.toString());
          }
        } else {
          yield PaymentSubscribeFailure(e.toString());
        }
      }
    }

    //구독 지연
    if (event is PaymentSubscriptionPending) {
      yield PaymentSubscribePending();
    }
    //구독 실패
    if (event is PaymentSubscriptionFailed) {
      yield PaymentSubscribeFailure(
          event.error.message + "(" + event.error.code + ")");
    }
    //구독 성공
    if (event is PaymentSubscriptionSucceed) {
      yield PaymentSubscribing();
      yield* _mapReceiptVerificationEventToState(event.purchaseDetails, false);
    }
  }

  Future<PurchaseDetails> getUncompletedPurchase() async {
    final QueryPurchaseDetailsResponse previousItemResponse =
        await InAppPurchaseConnection.instance.queryPastPurchases();
    if (previousItemResponse.error != null) {
      throw ("Failed to call queryPastPurchases");
    } else {
      Log.i(
          _tag,
          "pastPurchases size=" +
              previousItemResponse.pastPurchases.length.toString());
      for (PurchaseDetails purchaseDetails
          in previousItemResponse.pastPurchases) {
        Log.i(_tag, "pastPurchases state=" + purchaseDetails.status.toString());
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          final transactionDate = DateTime.fromMillisecondsSinceEpoch(
              int.parse(purchaseDetails.transactionDate),
              isUtc: true);
          final nowDate = DateTime.now().toUtc();
          Log.i(
              _tag,
              "transcationLocalDate=" +
                  DateFormat('yyyy-MM-dd – kk:mm')
                      .format(transactionDate.toLocal()) +
                  ", nowDate=" +
                  DateFormat('yyyy-MM-dd – kk:mm').format(nowDate.toLocal()));
          //28일 이내의 과거 목록 중 최근 정보를 보냄
          if (nowDate.difference(transactionDate).inDays <= 28) {
            Log.i(_tag, "find store purchase " + purchaseDetails.purchaseID);
            return purchaseDetails;
          }
        }
      }
    }
    return null;
  }

  Stream<BaseBlocState> _mapReceiptVerificationEventToState(
      PurchaseDetails purchaseDetails, bool checkPastPurchase) async* {
    dynamic response;
    if (Platform.isIOS) {
      for (var productInfo in _availableProducts) {
        if (productInfo.id == purchaseDetails.productID) {
          response = await VerifyPaymentServiceForIOS(ReceiptForIOS(
            receipt: purchaseDetails.verificationData.serverVerificationData,
            price: double.parse(productInfo.skProduct.price),
            currencyCode: productInfo.skProduct.priceLocale.currencyCode,
          )).start();
          break;
        }
      }
      //상품 매칭이 안 된 경우로 발생해서는 안 된다.
      if (response == null) {
        yield PaymentNotAvailable();
      }
    } else {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      response = await VerifyPaymentServiceForAndroid(ReceiptForAndroid(
        packageName: packageInfo.packageName,
        subscriptionId: purchaseDetails.productID,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData,
      )).start();
    }

    if (response is ServiceError) {
      ServiceError error = response;
      yield PaymentSubscribeFailure(error.message + "\n(" + error.code + ")");
      return;
    }

    if (response is PaymentResult) {
      if (response.status == "PAYMENT_EXPIRED") {
        if (checkPastPurchase) {
          yield PaymentAvailable();
          return;
        } else {
          yield PaymentSubscribeFailure("PAYMENT_EXPIRED");
        }
        Log.d(_tag, "PAYMENT_EXPIRED : " + response.toString());
      } else {
        appsflyer.saveLog(accountStart);
        await UserRepository.getProfile();
        yield PaymentSubscribeSuccess();
        Log.d(_tag, "success to verify payment : " + response.toString());
      }
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    Log.d(_tag, purchaseDetailsList.toString());
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      //android 는 acknowledgement 를 서버에서 호출하고 있다.
      //ios 는 구매를 진행하면 transaction 생성되고, 완료되지 않을 경우 동일상품에 대한 구매를 진행할 수 없다.
      if (Platform.isIOS && purchaseDetails.pendingCompletePurchase)
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          add(PaymentSubscriptionPending());
          break;
        case PurchaseStatus.purchased:
          add(PaymentSubscriptionSucceed(purchaseDetails));
          break;
        case PurchaseStatus.error:
          switch (purchaseDetails.error.message) {
            case 'BillingResponse.itemAlreadyOwned':
              //이미 구독된 상태 필요한 작업을 추가한다.
              add(PaymentCheckUncompletedPurchase());
              break;
            case 'BillingResponse.userCanceled':
              //사용자 취소에 대한 화면처리 없음
              break;
            default:
              add(PaymentSubscriptionFailed(purchaseDetails.error));
              break;
          }
          break;
      }
    });
  }
}

class ConnectUserPayment extends BaseBlocEvent {}

class ConnectUserPaymentState extends BaseBlocState {}

class HomeUserPayment extends BaseBlocEvent {}

class HomeUserPaymentSubscribing extends BaseBlocState {}

class HomeUserPaymentFailure extends BaseBlocState {
  final String message;

  HomeUserPaymentFailure({this.message});
}

class HomeUserPaymentSuccess extends BaseBlocState {}

class PaymentDescriptionInitEvent extends BaseBlocEvent {}

class BasePaymentDescriptionState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class PaymentSubscriptionPending extends BaseBlocEvent {}

class PaymentSubscriptionSucceed extends BaseBlocEvent {
  final PurchaseDetails purchaseDetails;

  PaymentSubscriptionSucceed(this.purchaseDetails);
}

class PaymentSubscriptionFailed extends BaseBlocEvent {
  final IAPError error;

  PaymentSubscriptionFailed(this.error);
}

class PaymentCheckUncompletedPurchase extends BaseBlocEvent {}

class PaymentAvailable extends BaseBlocState {}

class PaymentSubscribing extends BaseBlocState {}

class PaymentSubscribePending extends BaseBlocState {}

class PaymentSubscribeFailure extends BaseBlocState {
  final String errorMessage;

  PaymentSubscribeFailure(this.errorMessage);
}

class PaymentSubscribeSuccess extends BaseBlocState {}

class PaymentNotAvailable extends BaseBlocState {}

class PaymentSubscribe extends BaseBlocEvent {
  final int type;

  PaymentSubscribe({this.type});
}

class PaymentCheck extends BaseBlocEvent {}

class PaymentCheckInProgress extends BaseBlocState {}

class PaymentProductNotFound extends BaseBlocState {}

class PaymentSubscribeing extends BaseBlocEvent {}

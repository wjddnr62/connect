import 'dart:async';

import 'dart:io';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/remote/payment/payment_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/payment.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/store_kit_wrappers.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

class PaymentNoticeBloc extends BaseBloc {
  final _tag = "PaymentNoticeBloc";

  final Set<String> _productIds = {
    'com.neofect.connect.yearly_subscription',
    'com.neofect.connect.6_monthly_subscription',
    'com.neofect.connect.3_monthly_subscription',
    'com.neofect.connect.monthly_subscription'
  };

  final bool isNewHomeUser;
  List<ProductDetails> _availableProducts;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  PaymentNoticeBloc({this.isNewHomeUser}) : super(PaymentInitial()) {
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

  void dispose() {
    _subscription.cancel();
  }

  Future<void> finishTransactionForIOS() async {
    Log.d(_tag, "[finishTransactionForIOS] has been called");
    if (Platform.isIOS) {
      SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
      List<SKPaymentTransactionWrapper> transactions =
          await paymentQueue.transactions();

      await Future.forEach(transactions,
          (SKPaymentTransactionWrapper sk) async {
        Log.d(_tag,
            "SKPaymentTransactionWrapper originalTransaction=${sk.originalTransaction}, transactionState=${sk.transactionState},transactionIdentifier=${sk.transactionIdentifier}");
        if (kDebugMode && sk.transactionTimeStamp != null) {
          var dateTime = DateTime.fromMillisecondsSinceEpoch(
              sk.transactionTimeStamp.toInt() * 1000,
              isUtc: true);
          var localDateTime = dateTime.toLocal();
          var iso8601string = localDateTime.toIso8601String();
          Log.d(_tag, "Date=" + iso8601string);
        }
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

//  Future<void> checkPurchase() async {
//    SKPaymentQueueWrapper paymentQueue = SKPaymentQueueWrapper();
//    List<SKPaymentTransactionWrapper> paymentTransactions = await paymentQueue.transactions();
//    for(var transaction in paymentTransactions){
//      final state = transaction.transactionState;
//      if(transaction.payment.productIdentifier != "connect_basic_subscription"){
//        continue;
//      }
//      switch(state){
//        case SKPaymentTransactionStateWrapper.purchased:
//          //구매처리
//          break;
//        case SKPaymentTransactionStateWrapper.failed:
//          await paymentQueue.finishTransaction(transaction);
//          break;
//        case SKPaymentTransactionStateWrapper.restored:
//          //서버에서 아이템 관리하기 떄문에 복원이 필요하지 않다.
//          break;
//        case SKPaymentTransactionStateWrapper.purchasing:
//        case SKPaymentTransactionStateWrapper.deferred:
//          break;
//      }
//    }
//  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    ProductDetails subscriptionItem;

    if (isNewHomeUser) {
      yield* _mapNewHomeUserEventToState(event);
      return;
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
//          try {
//            uncompletedPurchase = await getUncompletedPurchase();
//            yield* _mapReceiptVerificationEventToState(uncompletedPurchase,true);
//          } catch (e) {
//            Log.d(_tag, e.toString());
//            yield PaymentSubscribeFailure(e.toString());
//            return;
//          }
          if (uncompletedPurchase == null) yield PaymentAvailable();
        }
      }
    }

    if (event is PaymentCheckUncompletedPurchase) {
      yield PaymentSubscribing();
      PurchaseDetails uncompletedPurchase;
      try {
        uncompletedPurchase = await getUncompletedPurchase(event.productId);
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
          if (_availableProducts[i].id.contains("yearly")) {
            subscriptionItem = _availableProducts[i];
            break;
          }
        } else if (event.type == 1) {
          if (_availableProducts[i].id.contains("6_monthly")) {
            subscriptionItem = _availableProducts[i];
            break;
          }
        } else if (event.type == 2) {
          if (_availableProducts[i].id.contains("3_monthly")) {
            subscriptionItem = _availableProducts[i];
            break;
          }
        } else if (event.type == 3) {
          if (!_availableProducts[i].id.contains("_monthly") &&
              _availableProducts[i].id.contains("monthly")) {
            subscriptionItem = _availableProducts[i];
            break;
          }
        }
      }
//      await finishTransactionOnErrorForIOS();
      Log.d(_tag, "Before call [buyNonConsumable] ${subscriptionItem.id}");
      try {
        await InAppPurchaseConnection.instance.buyNonConsumable(
            purchaseParam: new PurchaseParam(
          productDetails: subscriptionItem,
        )); //, applicationUserName: ));
      } on PlatformException catch (e) {
//        yield PaymentSubscribeFailure(e.toString());
        if (Platform.isIOS) {
          Log.i(_tag, "Purchase Exception=" + e.toString());
          await finishTransactionForIOS();
          if (e.code == 'storekit_duplicate_product_object') {
            // add(PaymentCheckUncompletedPurchase(subscriptionItem.id));
            try {
              await InAppPurchaseConnection.instance.buyNonConsumable(
                  purchaseParam:
                      new PurchaseParam(productDetails: subscriptionItem,sandboxTesting: true));
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
    if (event is PaymentStoreSubscriptionSucceed) {
      yield PaymentSubscribing();
      yield* _mapReceiptVerificationEventToState(event.purchaseDetails, false);
    }
  }

  Stream<BaseBlocState> _mapNewHomeUserEventToState(
      BaseBlocEvent event) async* {
    if (event is PaymentSubscribe) {
      yield PaymentSubscribing();

      dynamic response = await NeofectPaymentService().start();

      if (response is ServiceError) {
        ServiceError error = response;
        yield PaymentSubscribeFailure(error.message);
        return;
      }

      if (response is PaymentResult) {
        Log.d(_tag, "success to verify payment : " + response.toString());
      }
      await UserRepository.getProfile();
      yield PaymentSubscribeSuccess();
    }
  }

  Future<PurchaseDetails> getUncompletedPurchase(String productId) async {
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
          if ( nowDate.difference(transactionDate).inDays <= 28 ){
          //purchaseDetails.pendingCompletePurchase && purchaseDetails.productID == productId) {
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
        Log.d(_tag,
            "[mapReceiptVerificationEventToState]product.id=${productInfo.id},purchaseDetails.productID=${purchaseDetails.productID}");
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
      // if (Platform.isIOS ){
      //   await InAppPurchaseConnection.instance
      //       .completePurchase(purchaseDetails);
      // }
      if (response.status == "PAYMENT_EXPIRED") {
        if (checkPastPurchase) {
          yield PaymentAvailable();
          return;
        } else {
          yield PaymentSubscribeFailure("PAYMENT_EXPIRED");
        }
        Log.d(_tag, "PAYMENT_EXPIRED : " + response.toString());
      } else {
        await UserRepository.getProfile();
        yield PaymentSubscribeSuccess();
        Log.d(_tag, "success to verify payment : " + response.toString());
      }
    }
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      Log.d(_tag,
          "[_listenToPurchaseUpdated]purchaseDetails: status=${purchaseDetails.status.toString()}, transactionDate=${purchaseDetails.transactionDate}error.code=${purchaseDetails.error?.code}, error.message==${purchaseDetails.error?.message}");
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          add(PaymentSubscriptionPending());
          break;
        case PurchaseStatus.purchased:
          add(PaymentStoreSubscriptionSucceed(purchaseDetails));
          break;
        case PurchaseStatus.error:
          switch (purchaseDetails.error.message) {
            case 'BillingResponse.itemAlreadyOwned':
              //이미 구독된 상태 필요한 작업을 추가한다.
              add(PaymentCheckUncompletedPurchase(purchaseDetails.productID));
              return;
            case 'BillingResponse.userCanceled':
              //사용자 취소에 대한 화면처리 없음
              break;
            default:
              if (Platform.isIOS) {
                var error = purchaseDetails?.skPaymentTransaction?.error;
                if (error != null) {
                  Log.d(_tag,
                      "[_listenToPurchaseUpdated]iOS error: code=${error.code}, domain=${error.domain},userInfo=${error.userInfo.toString()}");
                }
              }
              add(PaymentSubscriptionFailed(purchaseDetails.error));
              break;
          }
          break;
      }
      //android 는 acknowledgement 를 서버에서 호출하고 있다.
      //ios 는 구매를 진행하면 transaction 생성되고, 완료되지 않을 경우 동일상품에 대한 구매를 진행할 수 없다.
      if (Platform.isIOS && purchaseDetails.pendingCompletePurchase) {
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
        Log.d(_tag,
            "[_listenToPurchaseUpdated]CompletePurchase has been called, pendingCompletePurchase: productID=${purchaseDetails.productID},purchaseDetails=${purchaseDetails.purchaseID}");
      }
    });
  }
}

abstract class PaymentEvent extends BaseBlocEvent {}

class PaymentCheck extends PaymentEvent {}

class PaymentSubscribe extends PaymentEvent {
  final bool isNewHomeUser;
  final int type;

  PaymentSubscribe(this.isNewHomeUser, {this.type});
}

class PaymentSubscriptionPending extends PaymentEvent {}

class PaymentStoreSubscriptionSucceed extends PaymentEvent {
  final PurchaseDetails purchaseDetails;

  PaymentStoreSubscriptionSucceed(this.purchaseDetails);
}

class PaymentSubscriptionFailed extends PaymentEvent {
  final IAPError error;

  PaymentSubscriptionFailed(this.error);
}

class PaymentCheckUncompletedPurchase extends PaymentEvent {
  final String  productId;

  PaymentCheckUncompletedPurchase(this.productId);
}

class PaymentCouponRegistrationSucceed extends PaymentEvent {}

class PaymentCouponRegistrationFailed extends PaymentEvent {
  final String errorMessage;

  PaymentCouponRegistrationFailed(this.errorMessage);
}

abstract class PaymentState extends BaseBlocState {}

class PaymentInitial extends PaymentState {}

class PaymentCheckInProgress extends PaymentState {}

class PaymentNotAvailable extends PaymentState {}

class PaymentPreviousProductError extends PaymentState {}

class PaymentProductNotFound extends PaymentState {}

class PaymentAvailable extends PaymentState {}

class PaymentSubscribing extends PaymentState {}

class PaymentSubscribePending extends PaymentState {}

class PaymentSubscribeFailure extends PaymentState {
  final String errorMessage;

  PaymentSubscribeFailure(this.errorMessage);
}

class PaymentSubscribeSuccess extends PaymentState {}

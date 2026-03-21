import 'dart:async';

import 'package:closerrr/core/services/custom_services.dart';
import 'package:closerrr/services/inapppurchase_services.dart';
import 'package:closerrr/src/controller/explore_controllers/explore_screen_controller.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart'
    as Influencer;
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseController extends GetxController {
  final Influencer.Profile profile;
  final openImagePicker;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  var subscriptions = <ProductDetails>[].obs;
  var isAvailable = false.obs;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late InAppPurchaseServices inAppPurchaseServices = InAppPurchaseServices();
  final ExploreScreenController exploreScreenController = Get.find();
  InAppPurchaseController(this.profile, this.openImagePicker);

  @override
  void onInit() {
    super.onInit();
    _initialize();
    _subscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _handlePurchase(purchaseDetailsList);
    });
  }

  Future<void> _initialize() async {
    isAvailable.value = await _inAppPurchase.isAvailable();
    if (isAvailable.value) {
      await _loadSubscriptions();
    }
  }

  Future<void> _handlePurchase(
      List<PurchaseDetails> purchaseDetailsList) async {
    kLog("purchaseDetailsList: ${purchaseDetailsList.first.status}");
    for (var purchaseDetails in purchaseDetailsList) {
      // if (purchaseDetails.status == PurchaseStatus.purchased) {
      //   if (purchaseDetails.pendingCompletePurchase) {
      final data = {
        "purchase_token":
            purchaseDetails.verificationData.serverVerificationData,
        "amount": subscriptions.first.price,
        "payment_method": "iap",
        "iap_id": subscriptions.first.id,
      };
      print(purchaseDetails);
      print(purchaseDetails.verificationData.serverVerificationData);
      // Hit Api
      await inAppPurchaseServices.createTransaction(data: data);
      await _inAppPurchase.completePurchase(purchaseDetails);
      // change the status from add friend to chat now
      exploreScreenController.influencers.value
          .firstWhere((element) => element.id == profile.userId)
          .isFriend
          .value = true;
    }
    //   } else if (purchaseDetails.status == PurchaseStatus.error) {
    //     // snackbar...
    //     kLog("Purchase error: ${purchaseDetails.error}");
    //   } else if (purchaseDetails.status == PurchaseStatus.canceled) {
    //     kLog("Purchase canceled: ${purchaseDetails.productID}");
    //   }
    // }
  }

  Future<void> _loadSubscriptions() async {
    Set<String> kSubscriptionIds = {'chat_enabled'};
    print("sksksksks");
    print(_inAppPurchase.isAvailable().then((value) => print(value)));
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kSubscriptionIds);

    if (response.notFoundIDs.isNotEmpty) {
      openImagePicker(response.notFoundIDs.toString());
      kLog("Subscription IDs not found: ${response.notFoundIDs}");
    }

    kLog("God it works seriously");
    kLog(response.notFoundIDs);
    kLog(response.productDetails);
    openImagePicker(response.productDetails.toString());
    openImagePicker(response.error.toString());
    kLog(response.error);
    subscriptions.value = response.productDetails;
  }

  Future<void> buySubscription(ProductDetails productDetails) async {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      kLog("Error while buying subscription: $e");
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}

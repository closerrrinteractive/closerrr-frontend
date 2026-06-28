import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/custom_services.dart';
import '../../../services/explore_services.dart';
import '../../models/explore/get_influencer_response.dart';
import '../../models/showcase/get_showcase.dart';
import '../chat/chat_controller.dart';

class ExploreScreenController extends GetxController {
  final ExploreScreenServices exploreServices = ExploreScreenServices();
  final exploreSearchController = TextEditingController();

  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxList<Influencer> influencers = <Influencer>[].obs;
  RxList<ShowcaseData> showcaseData = <ShowcaseData>[].obs;
  RxList<ShowcaseData> showcaseSlides = <ShowcaseData>[].obs;

  RxBool isShowcaseLoading = false.obs;

  Rxn<ShowcaseData> showcaseBannerImage = Rxn<ShowcaseData>();
  Rxn<ShowcaseData> showcaseProfileImage = Rxn<ShowcaseData>();

  RxBool acceptPpAndTAC = false.obs;

  RxString selectedCategory = 'Popular'.obs;

  void changeCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    currentPage.value = 1;
    influencers.clear();
    getInfluencers(name: exploreSearchController.text);
  }

  Future getInfluencers({String? name, String? influencerId}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final ChatController chatController = Get.find();
      final response = await exploreServices.getInfluencers(
          page: currentPage.value,
          limit: 10,
          sort: 'fullname:asc',
          name: name,
          category: chatController.isSearching.value ? 'All' : selectedCategory.value,
          influencerId: influencerId);

      return response.fold(
        (l) => kLog(l),
        (r) {
          if (influencerId != null) {
            return r.data.rows.first;
          }
          bool isFirstPage = currentPage.value == 1;
          if (isFirstPage) {
            influencers.clear();
          }
          influencers.addAll(r.data.rows);
          currentPage.value++;
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getInfluencerShowcase({
    required int id,
  }) async {
    showcaseBannerImage.value = null;
    showcaseProfileImage.value = null;
    showcaseSlides.clear();
    final response = await exploreServices.getInfluencerShowcase(id: id);
    response.fold(
      (l) => kLog(l),
      (r) {
        showcaseData.value.assignAll(r.data);
        showcaseSlides.value = showcaseData
            .where((element) => element.category == 'slider_image')
            .toList();
        showcaseBannerImage.value = showcaseData.firstWhereOrNull(
          (element) => element.category == 'banner_image',
        );
        showcaseProfileImage.value = showcaseData.firstWhereOrNull(
          (element) => element.category == 'profile_image',
        );
      },
    );
  }

  Future<bool> addFriend({required int influencerUserId}) async {
    final response = await exploreServices.removeFriend(id: influencerUserId);
    return response.fold(
      (l) {
        kLog(l);
        return false;
      },
      (_) => true,
    );
  }

  Future<void> updateShowcase(
      {required Map<String, dynamic> data,
      required String influencerId}) async {
    final response = await exploreServices.updateShowcase(data: data);
    response.fold(
      (l) {
        CustomLoader.hide();
        isShowcaseLoading.value = false;
        return kLog(l);
      },
      (r) {
        CustomLoader.hide();
        CustomSnackbar.show(
          title: 'Success',
          message: r['message'] ?? '',
          isError: false,
        );
        isShowcaseLoading.value = false;
        getInfluencerShowcase(id: int.parse(influencerId));
      },
    );
  }
}

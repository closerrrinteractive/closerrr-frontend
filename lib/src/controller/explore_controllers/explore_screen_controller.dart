import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/custom_services.dart';
import '../../../services/explore_services.dart';
import '../../models/explore/get_influencer_response.dart';
import '../../models/showcase/get_showcase.dart';

class ExploreScreenController extends GetxController {
  final ExploreScreenServices exploreServices = ExploreScreenServices();
  final exploreSearchController = TextEditingController();

  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxList<Influencer> influencers = <Influencer>[].obs;
  RxList<ShowcaseData> showcaseData = <ShowcaseData>[].obs;
  RxList<ShowcaseData> showcaseSlides = <ShowcaseData>[].obs;

  RxBool isShowcaseLoading = false.obs;

  RxBool acceptPpAndTAC = false.obs;

  Future getInfluencers({String? name, String? influencerId}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await exploreServices.getInfluencers(
          page: currentPage.value,
          limit: 10,
          sort: 'fullname:asc',
          name: name,
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
    final response = await exploreServices.getInfluencerShowcase(id: id);
    response.fold(
      (l) => kLog(l),
      (r) {
        showcaseData.value.assignAll(r.data);
        showcaseSlides.value = showcaseData
            .where((element) => element.category == 'slider_image')
            .toList();
      },
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

import 'package:closerrr/main.dart';
import 'package:get/get.dart';

class GoogleMapsController extends GetxController {
  final predictions = <dynamic>[].obs; // Observable list for predictions
  final selectedAddress = ''.obs; // Observable for the selected address
  final String kGoogleApiKey = "AIzaSyAqLR4qVMoRYj0DgJdEumfq5wSTeufRl_g";


  Future<void> fetchPredictions(String input) async {
    if (input.isEmpty) {
      predictions.clear(); // Clear predictions when input is empty
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&key=$kGoogleApiKey';

    try {
      final response = await httpService.get(url);
      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'OK') {
        predictions.value = data['predictions'];
      } else {
        print(
            "Error fetching predictions: ${data['status'] ?? 'Unknown error'}");
      }
    } catch (error) {
      print("Error fetching predictions: $error");
    }
  }
}

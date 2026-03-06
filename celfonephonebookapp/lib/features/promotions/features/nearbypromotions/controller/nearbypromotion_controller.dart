import 'package:celfonephonebookapp/features/promotions/features/nearbypromotions/service/nearbypromotion_services.dart';

import '../model/nearbypromotion_model.dart';

class NearbyPromotionController {
  final NearbyPromotionService _service = NearbyPromotionService();

  List<NearbyPromotionModel> profiles = [];

  Future<List<NearbyPromotionModel>> search(
    String pincode,
    String category,
  ) async {
    /// fetch from service using pincode
    final raw = await _service.searchProfiles(
      pincode: pincode,
      category: category,
    );

    final sentNumbers = await _service.getSentNumbers();

    /// FILTER BASED ON PREFIX AND PINCODE
    profiles = raw
        .where((e) {
          final recordPincode = e['pincode']?.toString() ?? "";
          final personPrefix = e['person_prefix']?.toString() ?? "";
          final businessPrefix = e['business_prefix']?.toString() ?? "";

          /// must match pincode
          if (recordPincode != pincode) return false;

          /// category conditions
          if (category == "Gents") {
            return personPrefix == "Mr." &&
                (e['person_name']?.toString().trim().isNotEmpty ?? false);
          }

          if (category == "Ladies") {
            return personPrefix == "Ms." &&
                (e['person_name']?.toString().trim().isNotEmpty ?? false);
          }
       

          if (category == "Firms") {
            return businessPrefix == "M/s." &&
                (e['business_name']?.toString().trim().isNotEmpty ?? false);
          }

          return false;
        })
        .map((e) {
          final mobile = e['mobile_number']?.toString() ?? "";

          return NearbyPromotionModel(
            /// SHOW ONLY PERSON NAME FOR GENTS/LADIES
            personName: category == "Firms"
                ? null
                : e['person_name']?.toString(),

            /// SHOW ONLY BUSINESS NAME FOR FIRMS
            businessName: category == "Firms"
                ? e['business_name']?.toString()
                : null,

            mobileNumber: mobile,

            pincode: e['pincode']?.toString() ?? "",

            isSent: sentNumbers.contains(mobile),
          );
        })
        .toList();

    sortProfiles();

    return profiles;
  }

  void sortProfiles() {
    profiles.sort((a, b) {
      if (a.isSent && !b.isSent) return 1;
      if (!a.isSent && b.isSent) return -1;
      return 0;
    });
  }

  Future<void> markAsSent(List<NearbyPromotionModel> selected) async {
    final sentNumbers = await _service.getSentNumbers();

    for (var profile in selected) {
      profile.isSent = true;
      if (!sentNumbers.contains(profile.mobileNumber)) {
        sentNumbers.add(profile.mobileNumber);
      }
    }

    await _service.saveSentNumbers(sentNumbers);

    sortProfiles();
  }

  String maskMobile(String number) {
    if (number.length <= 5) return number;
    return "${number.substring(0, 5)}XXXXX";
  }
}

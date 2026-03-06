import '../model/partner_model.dart';
import '../service/partner_services.dart';

class PartnerController {
  final PartnerServices _services = PartnerServices();

  Future<PartnerModel?> getPartnerProfile() async {
    final data = await _services.fetchProfile();

    if (data == null) return null;

    return PartnerModel.fromJson(data);
  }

  bool isLoggedIn() {
    return _services.isLoggedIn();
  }

  String getDisplayName(PartnerModel? model) {
    if (model != null && model.fullName.isNotEmpty) {
      return model.fullName;
    }

    final email = _services.getUserEmail();

    if (email != null) {
      return email.split('@')[0].toUpperCase();
    }

    return "GUEST PARTNER";
  }

  String getStatus(PartnerModel? model) {
    if (model != null) {
      return model.status;
    }
    return "Logged out";
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../service/contact_service.dart';
import '../service/referral_service.dart';
import '../service/sms_service.dart';
import '../model/referral_model.dart';

class ReferralController extends ChangeNotifier {
  final ReferralService referralService = ReferralService();
  final ContactService contactService = ContactService();
  final SmsService smsService = SmsService();

  final client = ReferralService().currentUser;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  int successfulReferrals = 0;
  int pendingReferrals = 0;
  int coupons = 0;


  final currentUserphone = ReferralService().currentUser?.phone ??'';



  List<ReferralModel> referrals = [];

  bool loading = false;

  ReferralController() {
    loadDashboard();
  }

  Future<void> pickContact() async {
    final Contact? contact = await contactService.pickContact();

    if (contact == null) return;

    nameController.text = contact.displayName;

    if (contact.phones.isNotEmpty) {
      phoneController.text = _normalizePhone(contact.phones.first.number);
    }

    notifyListeners();
  }

  String generateReferralCode() {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ123456789";

    final random = Random();

    return "CEL-${List.generate(6, (_) => chars[random.nextInt(chars.length)]).join()}";
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool validate() {
    final phone = phoneController.text.trim();

    if (nameController.text.trim().isEmpty) {
      return false;
    }

    if (phone.length < 10) {
      return false;
    }

    return true;
  }

  Future<void> loadDashboard() async {
    loading = true;

    notifyListeners();

    successfulReferrals = await referralService.getSuccessfulReferrals();

    pendingReferrals = await referralService.getPendingReferrals();

    coupons = await referralService.getCouponCount();

    referrals = await referralService.getMyReferrals();

    loading = false;

    notifyListeners();
  }

  Future<bool> alreadyReferred() async {
    final response = await referralService.client
        .from('referrals')
        .select('id')
        .eq('referrer_id', referralService.currentUser!.id)
        .eq('referred_phone', phoneController.text.trim());

    return (response as List).isNotEmpty;
  }

  Future<String?> submit() async {
    if (!validate()) {
      return "Please enter valid details.";
    }

    loading = true;
    notifyListeners();

    try {
      if (await alreadyReferred()) {
        loading = false;
        notifyListeners();
        return "You have already referred this person.";
      }

      final code = generateReferralCode();

      await referralService.addReferral(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        referralCode: code,
      );

      await smsService.sendInvitation(
        phone: phoneController.text.trim(),
        referralCode: code,
        referrerPhone: currentUserphone,
        friendName: nameController.text.trim(),
      );

      await loadDashboard();

      //clear the form
      nameController.clear();
      phoneController.clear();

      loading = false;
      notifyListeners();

      return null;
    } catch (e) {
      loading = false;
      notifyListeners();
      return e.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

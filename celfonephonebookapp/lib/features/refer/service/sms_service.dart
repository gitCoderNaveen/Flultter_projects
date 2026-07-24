import 'package:url_launcher/url_launcher.dart';

class SmsService {
  Future<void> sendInvitation({
    required String phone,
    required String referralCode,
    required String referrerPhone,
    required String friendName,
  }) async {
    final message = '''
Dear $friendName

I'm using CELFON BOOK. the Mobile number Finder and Dialer.

It Helps to Discover Businesses, Professionals and Services around you.

It Will be useful to you also.
Download the app and register using my Referral Code.

Referral Code:
$referrerPhone

https://play.google.com/store/apps/details?id=com.celfonphonebookapp
''';

    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {
        'body': message,
      },
    );

    await launchUrl(uri);
  }
}
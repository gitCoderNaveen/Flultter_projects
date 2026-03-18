import 'package:flutter/material.dart';

class MediaPartnerGuidePage extends StatelessWidget {
  const MediaPartnerGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        /// 🔥 LOGO + TAGLINE INSTEAD OF TITLE
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: "Cel",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: "fon",
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(
                              text: " Book",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
                      "Connects For Growth",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// 📄 GUIDE CONTENT
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            "How to Fill data by Media Partners.\n\n"
            "1. First Read help text displayed for every field,  and type as per that.\n"
            "2. In ADDRESS field, after a comma (,) type one blank space ( ). This will help text wrapping,  when long addresses are displayed.\n\n"
            "3. We have separate fields for CITY and PINCODE. so when you type, ADDRESS field,  do not type City and Pincode.\n\n"
            "4. For CITY name Type full correct names only like - Coimbatore, Bangalore,  Chennai etc don't use abbreviations (Cbe, Bgl etc).\n\n"
            "5. In ADDRESS field,  type all details needed by a post man or Courier Boy to find the location easily. Type in following order - Door number,  street,  flat number & building name,  Block / Main / Cross,  Land Mark, Near / Opp.  / next to etc\n\n"
            "6. When you type data for a BUSINESS,  if  the name of the CONTACT PERSON is not known,  leave it blank. Do not type Business name here. Or do not type Manager / Sales / Reception etc.\n\n"
            "7. MOBILE NUMBER is essential. However, if mobile is not available,  leave it blank.  Do not type - Landline Number, STD code etc.in this field\n\n"
            "8. There is seperate field for typing Landline Number at the end. If the mobile number is not typed, then land-line must be filled.\n\n"
            "9. For PRODUCT / SERVICE (Business) or PROFESSION (Person)  fields type specific meaningful names only.  Do not type BUSINESS or TRADER or INDUSTRY etc. do not type Generaly as - Cloth Store - type as Sarees,  Ladies wear,  Chudidhar - specific product they sell.  This will help buyers to find correct source when they want to buy.\n\n"

            "Celfon Book is designed to make your search fast, simple, and effective. Explore and grow with us!",

            style: TextStyle(fontSize: 16, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}

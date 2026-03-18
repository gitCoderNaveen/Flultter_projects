import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        /// 🔥 BRAND LOGO + TAGLINE
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

      /// 📄 BODY CONTENT
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            /// HEAD OFFICE
            Text(
              "Head Office :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Signpost Celfon. In Technology,\n"
              "Signpost Towers,  First Floor, \n"
              "46, Sidco Industrial Estate,  Pollachi Road.\n"
              "Coimbatore-641021.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 20),

            /// BRANCH OFFICE
            Text(
              "Branch Office :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Kalyan Nagar,\n"
              "HRBR Layout,\n"
              "Bangalore-560043.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            SizedBox(height: 20),

            /// MOBILE
            Text(
              "Mobile :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "+91 98436 57564",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),
            Text(
              "Directoy Enquiry: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "+91 97 86 88 90 92",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            /// WEBSITE
            Text(
              "Portal :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "www.signpostphonebook.in",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Mobile App :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "https://play.google.com/store/apps/details?id=com.celfonphonebookapp",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            /// EMAIL
            Text(
              "Email :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "signpostphonebook@gmail.com",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                        fontSize: 12, // 👈 slightly smaller for AppBar
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
        centerTitle: true,
      ),

      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
           "Signpost group was established in the year 1981 by founder Lion Dr Er  J. Shivakumaar, by publishing Maiden edition of Coimbatore Industrial Directory. It was published with the support of CODISSIA, Indian Chamber of Commerce etc in 1981.\n\n"
            "Based on the success of maiden directory,  and the need of industrialists  and entrepreneurs,  industrial directories on Madurai, Salem, Madras and Tamilnadu were printed and released till 1990. We also published 2 editions of Cinema directories in 1989 and 1990.\n\n"
            "We have grown with the technology and future releases were published in Floppy,  CD,  Ebook and Web formats till 2009.  Forseeing the technology Developments in smart mobile phones we have done lot of research to publish printed books in smart phones. In 2014, we got technical know-how from Manchester UK for digital editions creation. From 2014, we helped Lions clubs in India to save plenty of trees,  by publishing  their directories Digitaly.",
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
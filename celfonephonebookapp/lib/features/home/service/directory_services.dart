import 'package:celfonephonebookapp/features/home/model/directory_service_model.dart';
import 'package:flutter/material.dart';

class _DirectoryServiceCard extends StatelessWidget {
  final DirectoryService service;

  const _DirectoryServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final searchValues = service.searchValue
        .split(',')
        .map((e) => e.trim())
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (service.redirectUrl != null) {
            // 👉 Open external / playbook URL
            Navigator.pushNamed(
              context,
              '/webview',
              arguments: service.redirectUrl,
            );
          } else {
            // 👉 Navigate using first search value
            Navigator.pushNamed(
              context,
              '/search',
              arguments: searchValues.first,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 📕 Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  service.image,
                  width: 80,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // 📄 Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 6,
                      children: searchValues.map((value) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/search',
                              arguments: value,
                            );
                          },
                          child: Chip(
                            label: Text(value),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

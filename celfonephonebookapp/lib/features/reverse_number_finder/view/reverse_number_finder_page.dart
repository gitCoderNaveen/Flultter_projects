import 'package:flutter/material.dart';
import '../controller/reverse_number_controller.dart';
import '../model/reverse_number_model.dart';

class ReverseNumberFinderPage extends StatefulWidget {
  const ReverseNumberFinderPage({super.key});

  @override
  State<ReverseNumberFinderPage> createState() =>
      _ReverseNumberFinderPageState();
}

class _ReverseNumberFinderPageState extends State<ReverseNumberFinderPage> {
  final TextEditingController _mobileController = TextEditingController();
  final ReverseNumberController _controller = ReverseNumberController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ReverseNumberModel> results = [];
  bool isLoading = false;

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return "Mobile number is required";
    }

    final regex = RegExp(r'^[6-9]\d{9}$');

    if (!regex.hasMatch(value)) {
      return "Enter valid Indian mobile number (10 digits, starts with 6-9)";
    }

    return null;
  }

  void _search() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final data = await _controller.findByMobile(_mobileController.text.trim());

    setState(() {
      results = data;
      isLoading = false;
    });

    if (results.isNotEmpty) {
      _showResultModal(results.first);
      _mobileController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Data Found")));
    }
  }

  void _showResultModal(ReverseNumberModel item) {
    bool showMore = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text("The number is Registered in the Name of:"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isNotEmpty ? item.name : 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("Mobile: ${item.mobile}"),
                  const SizedBox(height: 10),

                  if (showMore) ...[
                    const Divider(),
                    Text("Address: ${item.address}"),
                    if (item.email.isNotEmpty) Text("Email: ${item.email}"),
                    Text("City: ${item.city}"),
                    Text("Pincode: ${item.pincode}"),
                    if (item.landline.isNotEmpty)
                      Text("Landline: ${item.landline}"),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      showMore = !showMore;
                    });
                  },
                  child: Text(showMore ? "Hide" : "More"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    setState(() {
                      _mobileController.clear;
                      _formKey.currentState?.reset();
                      results = [];
                    });
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reverse Number Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: _validateMobile,
                decoration: const InputDecoration(
                  labelText: 'Enter Indian Mobile Number',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isLoading ? null : _search,
                child: const Text('Find'),
              ),
              const SizedBox(height: 20),

              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:celfonephonebookapp/features/search/service/discount_greeting_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../model/discount_greeting_model.dart';

class DiscountGreetingCardWidget extends StatefulWidget {
  final DiscountGreetingCard card;

  const DiscountGreetingCardWidget({super.key, required this.card});

  @override
  State<DiscountGreetingCardWidget> createState() =>
      _DiscountGreetingCardWidgetState();
}

class _DiscountGreetingCardWidgetState extends State<DiscountGreetingCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  late ConfettiController _confettiController;

  bool isClaimed = false;

  Duration remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    if (widget.card.claimedAt != null) {
      isClaimed = true;
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _startTimer();
  }

  void _startTimer() {
    remaining = widget.card.expiryDate.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = widget.card.expiryDate.difference(DateTime.now());

      if (diff.isNegative) {
        _timer.cancel();
        if (mounted) Navigator.pop(context);
      }

      setState(() {
        remaining = diff;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Color parseColor(String color) {
    try {
      return Color(int.parse(color.replaceAll('#', '0xff')));
    } catch (_) {
      return Colors.blue.shade50;
    }
  }

  String formatDuration(Duration d) {
    if (d.isNegative) return "Expired";

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = parseColor(widget.card.backgroundColor);

    return Scaffold(
      body: FadeTransition(
        opacity: _controller,
        child: SafeArea(
          child: Stack(
            children: [
              //party popper
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.05,
                  numberOfParticles: 30,
                  gravity: 0.2,
                ),
              ),

              /// BACKGROUND
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgColor, bgColor.withOpacity(.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Celfon Discount Card",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              /// CONTENT
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// TITLE
                      Text(
                        widget.card.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// MESSAGE
                      Text(
                        widget.card.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 35),

                      /// TIMER
                      Column(
                        children: [
                          const Text(
                            "Offer ends in",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatDuration(remaining),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// CLAIM BUTTON
                      SizedBox(
                        width: 220,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isClaimed
                                ? Colors.grey
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isClaimed
                              ? null
                              : () async {
                                  /// Play confetti
                                  _confettiController.play();

                                  /// Update database
                                  await DiscountGreetingService().claimDiscount(
                                    widget.card.id,
                                  );

                                  /// Disable button
                                  setState(() {
                                    isClaimed = true;
                                  });
                                },
                          child: Text(
                            isClaimed ? "Claimed" : widget.card.buttonText,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// CLOSE BUTTON
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// DISCOUNT RIBBON
              Positioned(
                top: 40,
                left: -50,
                child: Transform.rotate(
                  angle: -0.75,
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: const Text(
                      "SPECIAL DISCOUNT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

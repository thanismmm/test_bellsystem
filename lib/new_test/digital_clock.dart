import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final deviceWidth = MediaQuery.of(context).size.width;
    // final devicehight = MediaQuery.of(context).size.height;

    String formattedTime = "${_now.hour.toString().padLeft(2, '0')}:"
        "${_now.minute.toString().padLeft(2, '0')}:"
        "${_now.second.toString().padLeft(2, '0')}";
    String formattedDate = "${_now.day.toString().padLeft(2, '0')}/"
        "${_now.month.toString().padLeft(2, '0')}/"
        "${_now.year}";

    return Center(
      child: SizedBox(
        width: deviceWidth,
        height: 120,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Digital time with glow effect
              Text(
                formattedTime,
                style: GoogleFonts.orbitron(
                  textStyle: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                    color: Colors.cyanAccent.shade400,
                    shadows: [
                      Shadow(
                        blurRadius: 16,
                        color: Colors.cyanAccent.shade100,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Date in a modern style
              Text(
                formattedDate,
                style: GoogleFonts.robotoMono(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 2,
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

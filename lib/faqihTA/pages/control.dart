import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart'; // ✅ Tambah ini

class AturDerajatPage extends StatefulWidget {
  final bool manualMode;
  const AturDerajatPage({super.key, required this.manualMode});

  @override
  State<AturDerajatPage> createState() => _AturDerajatPageState();
}

class _AturDerajatPageState extends State<AturDerajatPage> {
  int mode = 1;
  bool sideView = false;
  final db = FirebaseDatabase.instance.ref(); // 

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = LinearGradient(
      colors: isDark
          ? const [Color.fromARGB(0, 28, 28, 39), Color.fromARGB(6, 36, 36, 53)]
          : const [Color.fromARGB(69, 223, 246, 246), Color.fromARGB(82, 203, 241, 245)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 248, 246, 246),
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(gradient: gradient),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      "Manual Control",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildCurtain(isDark),
              const SizedBox(height: 25),
              _controlPanel(isDark),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurtain(bool isDark) {
    double targetAngle;
    double thickness;
    double spacing;

    if (mode == 0) {
      targetAngle = 15; // tertutup rapat
      thickness = 10;
      spacing = 2;
    } else if (mode == 1) {
      targetAngle = 75; // sedang
      thickness = 6;
      spacing = 6;
    } else {
      targetAngle = 130; // terbuka
      thickness = 8;
      spacing = 4;
    }

    const int blades = 14;
    const double width = 240;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      tween: Tween(begin: 0, end: targetAngle),
      builder: (context, angle, _) {
        return Container(
          width: 270,
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A33) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(blades, (i) {
              return Container(
                margin: EdgeInsets.only(bottom: i == blades - 1 ? 0 : spacing),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(angle * pi / 180),
                  child: Container(
                    width: width,
                    height: thickness,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.shade300,
                          Colors.grey.shade500,
                          Colors.grey.shade200,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.15),
                        ),
                        BoxShadow(
                          spreadRadius: -4,
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _controlPanel(bool isDark) {
    bool locked = !widget.manualMode;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                mode == 0
                    ? "Tirai Tertutup"
                    : mode == 1
                        ? "Posisi Sedang"
                        : "Tirai Terbuka",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _btn("Tutup", 0, isDark, locked),
                  _btn("Sedang", 1, isDark, locked),
                  _btn("Buka", 2, isDark, locked),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                locked
                    ? "Mode otomatis aktif — kontrol dinonaktifkan"
                    : "Mode manual aktif — kontrol menyala",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(String t, int v, bool isDark, bool locked) {
    bool active = mode == v;

    return GestureDetector(
      onTap: locked
          ? null
          : () {
              setState(() => mode = v);

              // ✅ kirim command ke ESP32 via Firebase
              String cmd = v == 0
                  ? "0"
                  : v == 1
                      ? "45"
                      : "90";

              db.child("SmartCurtain/manualControl").set(cmd);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active
              ? (isDark
                  ? const Color.fromARGB(255, 7, 48, 120)
                  : Colors.blue)
              : (isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05)),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: active
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

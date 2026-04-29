import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/weather.dart';
import 'package:lottie/lottie.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final weatherService = WeatherService();

  Map<String, dynamic>? current;
  List? forecast;
  bool willRain = false;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    current = await weatherService.getCurrentWeather();
    forecast = await weatherService.getForecast();
    willRain = await weatherService.willRainSoon();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textMain = isDark ? Colors.white : Colors.black87;
    final textSub = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.07);
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.25)
        : Colors.black.withOpacity(0.18);

    if (current == null || forecast == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color.fromARGB(0, 13, 17, 23),
                        const Color.fromARGB(6, 27, 35, 48)
                      ]
                    : [
                        const Color.fromARGB(30, 142, 197, 252),
                        const Color.fromARGB(20, 224, 195, 252)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ICON CUACA (Lottie)
                  Container(
                    height: 130,
                    width: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Lottie.asset(
                        willRain ? 'assets/hujan.json' : 'assets/sunny.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),


                  const SizedBox(height: 18),

                  // TEMPERATURE
                  Text(
                    "${current!["main"]["temp"].round()}°C",
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),

                  // DESCRIPTION
                  Text(
                    current!["weather"][0]["description"]
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: textSub,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // MAIN INFO CARD
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          children: [
                            _infoRow(
                                "Feels Like",
                                "${current!["main"]["feels_like"].round()}°C",
                                textMain,
                                textSub),
                            _infoRow(
                                "Kelembapan",
                                "${current!["main"]["humidity"]}%",
                                textMain,
                                textSub),
                            _infoRow(
                                "Kecepatan Angin",
                                "${current!["wind"]["speed"]} m/s",
                                textMain,
                                textSub),
                            _infoRow(
                                "Awan",
                                "${current!["clouds"]["all"]}%",
                                textMain,
                                textSub),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // FORECAST TITLE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ramalan Singkat",
                      style: TextStyle(
                        color: textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // HOURLY FORECAST
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (ctx, i) {
                        final item = forecast![i];
                        final temp = item["main"]["temp"].round();
                        final time = item["dt_txt"].substring(11, 16);

                        return Container(
                          width: 85,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud, color: textMain, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                "$temp°C",
                                style: TextStyle(
                                  color: textMain,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                time,
                                style: TextStyle(
                                  color: textSub,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 35),

                  // WARNING RAIN CARD
                  if (willRain)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.redAccent.withOpacity(0.15)
                            : Colors.redAccent.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 32,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Diperkirakan hujan dalam 3–6 jam ke depan.\n"
                              "Tirai sebaiknya menutup otomatis.",
                              style: TextStyle(
                                color: textMain,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 45),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      String title, String value, Color textMain, Color textSub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: textSub, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              color: textMain,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

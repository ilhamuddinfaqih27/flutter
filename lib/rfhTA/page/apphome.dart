import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 

class Apphome extends StatefulWidget {
  const Apphome({super.key});

  @override
  State<Apphome> createState() => _ApphomeState();
}

class _ApphomeState extends State<Apphome> {
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456), 
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 50, 11, 157).withValues(alpha: 0.3),
              Colors.blue[300]!
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              const SizedBox(height: 30),
              
              // AREA MAPS
              Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 31, 30, 30).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                // Gunakan ClipRRect agar peta tidak keluar dari border radius container
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GoogleMap(
                    initialCameraPosition: _initialPosition,
                    mapType: MapType.normal,
                    // Menambahkan Marker (Alat 1)
                    markers: {
                      const Marker(
                        markerId: MarkerId('alat_1'),
                        position: LatLng(-6.2088, 106.8456),
                        infoWindow: InfoWindow(title: 'Alat 1'),
                      ),
                    },
                    // Pengaturan tambahan agar Maps menyatu dengan UI
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false, 
                  ),
                ),
              ),

              const SizedBox(height: 90),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            _buildLiquidBox("Lokasi 1", context),
                            const SizedBox(width: 20),
                            _buildLiquidBox("Lokasi 2", context),
                          ],
                        ),
                      ),
                      const DataCard(title: "Suhu", value: "28°C"),
                      const DataCard(title: "Kelembaban", value: "70%"),
                      const DataCard(title: "Kecepatan Angin", value: "5 m/s"),
                      const DataCard(title: "Tekanan Udara", value: "1012 hPa"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidBox(String text, BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 31, 30, 30).withValues(alpha: 0.3),
                  const Color.fromARGB(255, 31, 30, 30).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color.fromARGB(255, 31, 30, 30).withValues(alpha: 0.4),
                  width: 1.5),
            ),
            child: InkWell(
              onTap: () {},
              child: Center(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DataCard extends StatelessWidget {
  final String title;
  final String value;

  const DataCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w600)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
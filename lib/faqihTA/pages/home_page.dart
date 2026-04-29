import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

import '../widgets/upnav.dart';
import '../widgets/drawer.dart';
import '../widgets/botnav.dart';
import 'control.dart';
import 'cuaca.dart';
import 'profile_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final db = FirebaseDatabase.instance.ref();
  final user = FirebaseAuth.instance.currentUser;

  int selectedIndex = 0;
  bool modeOtomatis = true;
  bool powerStatus = true; // ✅ Tambahan: status ON/OFF sistem

  String profileUrl = "";

  double suhu = 0;
  double kelembapan = 0;
  double intensitas = 0;
  String lastAction = "-";

  late AnimationController fadeCtrl;

  @override
  void initState() {
    super.initState();
    fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    loadUserProfile();
    listenDB();
  }

  Future<void> loadUserProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    setState(() {
      profileUrl = doc.data()?["photoUrl"] ?? "";
    });
  }

  void listenDB() {
    
    db
        .child("SmartCurtain/suhu")
        .onValue
        .listen(
          (e) => setState(
            () => suhu = double.tryParse("${e.snapshot.value}") ?? 0,
          ),
        );

    db
        .child("SmartCurtain/kelembaban")
        .onValue
        .listen(
          (e) => setState(
            () => kelembapan = double.tryParse("${e.snapshot.value}") ?? 0,
          ),
        );

    db
        .child("SmartCurtain/lux")
        .onValue
        .listen(
          (e) => setState(
            () => intensitas = double.tryParse("${e.snapshot.value}") ?? 0,
          ),
        );

    db
        .child("SmartCurtain/lastAction")
        .onValue
        .listen((e) => setState(() => lastAction = "${e.snapshot.value}"));

    // ✅ Power listener baru
    db.child("SmartCurtain/power").onValue.listen((event) {
      final val = "${event.snapshot.value}";
      setState(() {
        powerStatus = val == "ON";
      });
    });

    // ✅ Mode listener sinkron biar app tahu mode yang aktif dari IoT
    db.child("SmartCurtain/mode").onValue.listen((event) {
      final val = "${event.snapshot.value}";
      setState(() {
        modeOtomatis = val == "Otomatis";
      });
    });
  }

  // ✅ Fungsi tambahan untuk ubah power ON/OFF
  void _handlePowerChange(bool value) async {
    setState(() => powerStatus = value);
    await db.child("SmartCurtain/power").set(value ? "ON" : "OFF");
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeUI(),
      const WeatherPage(),
      AturDerajatPage(manualMode: !modeOtomatis),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(isDark ? 'assets/dark.jpg' : 'assets/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [
                      Color(0xAA1C1C27),
                      Color(0x88242435),
                      Color(0x662B2B45),
                    ]
                  : const [
                      Color(0x99A6E3E9),
                      Color(0x55387793),
                      Color(0x552A9090),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: DrawerMenu(
            // Tambahan parameter power control
            powerStatus: powerStatus,
            onPowerChange: _handlePowerChange,

            modeOtomatis: modeOtomatis,
            onModeChange: (v) {
              setState(() => modeOtomatis = v);
              db.child("SmartCurtain/mode").set(v ? "Otomatis" : "Manual");
            },
            onManualTap: () {
              setState(() => modeOtomatis = false);
              db.child("SmartCurtain/mode").set("Manual");
            },
            onLogout: () async {
              if (Navigator.canPop(context)) Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          body: Column(
            children: [
              const SizedBox(height: 45),
              UpNav(
                profileUrl: profileUrl,
                onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                onProfileTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProfilePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 0.1);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              ),
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: selectedIndex,
            onTap: (i) => setState(() => selectedIndex = i),
          ),
        ),
      ],
    );
  }

  Widget _homeUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 10, left: 22, right: 22),
      child: Column(
        children: [
          const SizedBox(height: 15),
          FadeTransition(opacity: fadeCtrl, child: _yoloContainer()),
          const SizedBox(height: 28),
          FadeTransition(opacity: fadeCtrl, child: _sensorSection()),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  Widget _yoloContainer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              const Text(
                "Human Detection",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              const SizedBox(height: 22),
              Container(
                height: 210,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: MJPEGStreamScreen(
                    streamUrl: 'http://172.20.10.2:5000/video',
                    fit: BoxFit.cover,
                    showLiveIcon: true,
                    showWatermark: false,
                    blurSensitiveContent: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sensorSection() {
    return Column(
      children: [
        _sensorCard(Icons.thermostat, "Suhu", "$suhu °C", Colors.orange),
        _sensorCard(
          Icons.water_drop,
          "Kelembapan",
          "$kelembapan %",
          Colors.blue,
        ),
        _sensorCard(
          Icons.wb_sunny_rounded,
          "Intensitas Cahaya",
          "$intensitas lux",
          Colors.yellow.shade700,
        ),
        _sensorCard(
          Icons.history_rounded,
          "Posisi Tirai",
          lastAction,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _sensorCard(IconData icon, String title, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromARGB(255, 8, 8, 8).withOpacity(0.06)
            : Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.25),
          child: Icon(icon, size: 28, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: SizedBox(
          width: 130,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

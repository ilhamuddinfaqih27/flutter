import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/theme_provider.dart';
import '../pages/login_page.dart';

class DrawerMenu extends StatelessWidget {
  final bool powerStatus; // ✅ tambahan
  final ValueChanged<bool> onPowerChange; // ✅ tambahan
  final bool modeOtomatis;
  final ValueChanged<bool> onModeChange;
  final VoidCallback onManualTap;
  final VoidCallback onLogout;

  const DrawerMenu({
    super.key,
    required this.powerStatus, // ✅ tambahan
    required this.onPowerChange, // ✅ tambahan
    required this.modeOtomatis,
    required this.onModeChange,
    required this.onManualTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width * 0.70,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(26),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.window, size: 55, color: Colors.white),
                          Text(
                            "Smart Curtain",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ SWITCH BARU UNTUK POWER
                    SwitchListTile(
                      title: const Text("Power Sistem"),
                      secondary: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                      value: powerStatus,
                      onChanged: null,
                    ),

                    // EXISTING
                    SwitchListTile(
                      title: const Text("Mode Otomatis"),
                      secondary: const Icon(Icons.autorenew),
                      value: modeOtomatis,
                      onChanged: onModeChange,
                    ),

                    ListTile(
                      leading: const Icon(Icons.handyman),
                      title: const Text("Mode Manual"),
                      trailing: !modeOtomatis
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: onManualTap,
                    ),

                    const Divider(),

                    SwitchListTile(
                      title: const Text("Dark Mode"),
                      secondary: Icon(
                        themeProv.isDark ? Icons.dark_mode : Icons.light_mode,
                      ),
                      value: themeProv.isDark,
                      onChanged: themeProv.toggleTheme,
                    ),

                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text("Logout"),
                      onTap: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),

                    const Spacer(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

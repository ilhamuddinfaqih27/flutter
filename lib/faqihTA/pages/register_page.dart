import 'dart:io';
import 'dart:ui';
import 'package:app_iot/faqihTA/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nicknameC = TextEditingController();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  File? _image;
  bool isLoading = false;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> register() async {
    if (emailC.text.isEmpty ||
        passC.text.isEmpty ||
        nicknameC.text.isEmpty ||
        nameC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data terlebih dahulu")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ Buat akun baru
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      String imageUrl = "";

      
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile/${userCred.user!.uid}.jpg');
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        'nickname': nicknameC.text.trim(),
        'name': nameC.text.trim(),
        'email': emailC.text.trim(),
        'photoUrl': imageUrl,
      });

      // Navigasi ke login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Register gagal.";
      if (e.code == 'email-already-in-use') {
        msg = "Email sudah terdaftar. Gunakan email lain.";
      } else if (e.code == 'weak-password') {
        msg = "Password terlalu lemah (minimal 6 karakter).";
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFFB0A4FF),
        Color(0xFF8FD3F4),
        Color.fromARGB(255, 63, 138, 161),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        const Color.fromARGB(255, 13, 13, 13).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: const Color.fromARGB(255, 10, 10, 10)
                            .withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Daftar Akun",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 13, 13, 13)
                              .withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: pickImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor:
                              const Color.fromARGB(255, 5, 4, 4).withOpacity(0.3),
                          backgroundImage:
                              _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(Icons.camera_alt_rounded,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.9))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildInput(nicknameC, "Nama Panggilan", Icons.person),
                      const SizedBox(height: 15),
                      _buildInput(nameC, "Nama Lengkap", Icons.badge),
                      const SizedBox(height: 15),
                      _buildInput(emailC, "Email", Icons.email),
                      const SizedBox(height: 15),
                      _buildInput(passC, "Password", Icons.lock,
                          isPassword: true),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.85),
                          foregroundColor: const Color(0xFF6C63FF),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 16,
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.purple)
                            : const Text(
                                "Daftar Akun",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          );
                        },
                        child: Text(
                          "Sudah punya akun? Masuk",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: c,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.9)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

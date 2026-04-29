import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;

  Future<void> getUserData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (mounted) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);
    try {
      final ref =
          FirebaseStorage.instance.ref().child('users/${user!.uid}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photoUrl': url});
      await getUserData();
    } catch (e) {
      debugPrint('Gagal upload foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengunggah foto')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _editProfileDialog() async {
    final nameCtrl = TextEditingController(text: userData!['name']);
    final nickCtrl = TextEditingController(text: userData!['nickname']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nickCtrl, decoration: const InputDecoration(labelText: "Nickname")),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nama Lengkap")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({
                'nickname': nickCtrl.text,
                'name': nameCtrl.text,
              });
              Navigator.pop(ctx);
              await getUserData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diperbarui')),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isDark ? 'assets/dark.jpg' : 'assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.25)),
          SafeArea(
            child: userData == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 26),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 62,
                                      backgroundColor: Colors.white,
                                      backgroundImage: userData!['photoUrl'] != ''
                                          ? NetworkImage(userData!['photoUrl'])
                                          : null,
                                      child: userData!['photoUrl'] == ''
                                          ? const Icon(Icons.person, size: 70, color: Colors.black87)
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: GestureDetector(
                                        onTap: _pickAndUploadPhoto,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ],
                                          ),
                                          child: Icon(Icons.edit, size: 18, color: Colors.purple.shade700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  userData!['nickname'],
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData!['name'],
                                  style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                                ),
                                Text(
                                  userData!['email'],
                                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                const SizedBox(height: 30),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple.shade600.withOpacity(0.85),
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      onPressed: _editProfileDialog,
                                      icon: const Icon(Icons.edit, color: Colors.white),
                                      label: const Text("Edit Profil", style: TextStyle(fontSize: 17, color: Colors.white)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                  ),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginPage()),
                                      (route) => false,
                                    );
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                  label: const Text("Logout", style: TextStyle(fontSize: 17, color: Colors.white)),
                                ),
                                if (isLoading) const Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: CircularProgressIndicator(color: Colors.white),
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
        ],
      ),
    );
  }
}

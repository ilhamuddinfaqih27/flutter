import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
import 'firebase_options.dart';
// import 'faqihTA/pages/login_page.dart';
// import 'faqihTA/controllers/mode_provider.dart';
// import 'faqihTA/controllers/theme_provider.dart';
import 'rfhTA/navigator/navigate.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartTiraiApp());
}

class SmartTiraiApp extends StatelessWidget {
  const SmartTiraiApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProv, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Smart Curtain",
            themeMode: themeProv.themeMode,
    */

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Pantau Cuaca",
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const AuthWrapper(),
    );

    /*
        },
      ),
    );
    */
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const Navigate();
        }

        return const Navigate();

        /*
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        return const LoginPage();
        */
      },
    );
  }
}
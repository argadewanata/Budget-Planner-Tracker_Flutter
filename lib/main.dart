import 'package:budgetplannertracker/pages/auth_page.dart';
import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:budgetplannertracker/widgets/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:budgetplannertracker/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Travel Budget Tracker",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue[600],
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue[800],
            unselectedItemColor: Colors.blue[200],
          ),
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeController(),
          '/login': (context) => const AuthPage(authType: AuthType.login),
          '/register': (context) => const AuthPage(authType: AuthType.register),
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  const HomeController({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;

    return StreamBuilder(
      stream: auth.onAuthStateChanged(),
      builder: (context, snapshot) {
        print("[DEBUG] snapshot: $snapshot");
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn =
              snapshot.hasData && auth.getCurrentUser() != null;
          print("[DEBUG] signedIn: $signedIn");
          return signedIn
              ? const HomePage()
              : const AuthPage(authType: AuthType.login);
        }
        return Container();
      },
    );
  }
}

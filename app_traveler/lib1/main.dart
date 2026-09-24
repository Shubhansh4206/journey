import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Wakes up the native Android side before initializing Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Your actual Supabase URL and Anon Key
  const supabaseUrl = 'https://sbfchxjiybmaddvrkhws.supabase.co';
  const supabaseAnonKey = 'sb_publishable_zmCVKeTr_em3CGKaJsPvUA_9qYDWdwn';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Journey Traveler',
      debugShowCheckedModeBanner: false, // Removes the debug banner on the top right
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Map View Placeholder',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
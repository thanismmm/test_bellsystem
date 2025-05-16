import 'package:bell_system_test/new_test/schedule_provider.dart';
import 'package:bell_system_test/page/new_login.dart';
import 'package:bell_system_test/page/schedule_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAGC9BFFnbnc3lYIBu0M-jh-0yLdcTtqdg",
      appId: "1:627690937522:android:836f77b5d7890111ccfdab",
      messagingSenderId: "627690937522",
      projectId: "fireset-f5daa",
      databaseURL: "https://fireset-f5daa-default-rtdb.asia-southeast1.firebasedatabase.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ScheduleProvider(),
      child: MaterialApp(
        title: 'School Bell Schedules',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
        // Add any additional async operations here
        future: Future.delayed(const Duration(seconds: 2)), // Simulate loading
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
              return ScheduleScreen();
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      ),
    );
  }
}
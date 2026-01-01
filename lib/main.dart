import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_db/view/splash_screen.dart';
import 'package:hive_db/model/person_model.dart';

void main() async {
  await Hive.initFlutter();
  // Initializes Hive for Flutter.
  // Sets up Hive's internal storage directory. (Apps Document Directory)
  // Required before using any Hive functionality.
  // This version is used specially for Flutter apps.

  Hive.registerAdapter(PersonAdapter());
  // Hive stores only basic data types by default (int, string, bool, etc.).
  // For custom classes like Person, Hive needs a TypeAdapter.
  // PersonAdapter converts your Person object into binary data and back.

  await Hive.openBox<Person>('persons');
  // Opens a Hive box (database) named "persons".
  // A box in Hive = a table or storage container.
  // This stores objects of type Person.

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Hive DB Tutorial",
      home: SplashScreen(),
    );
  }
}

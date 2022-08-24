import 'package:better_bus_v2/views/common/decorations.dart';
import 'package:flutter/material.dart';
import 'package:better_bus_v2/views/home_page/home_page.dart';
import 'package:flutter/services.dart';
import 'package:better_bus_v2/views/widget/example.dart' as example;

void main() {
  example.main();
  return;

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        backgroundColor: const Color(0xdde4e4e4),


        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
          ),
          bodySmall: TextStyle(fontSize: 13),
        ),


        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),


        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
            borderSide: BorderSide(
              color: Colors.lightGreen.shade500,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: CustomDecorations.borderRadius,
            borderSide: BorderSide(color: Colors.lightGreen.shade400, width: 2),
          ),
          labelStyle: const TextStyle(
            fontSize: 25,
          ),
        ),
      ),
      locale: Locale("fr"),
      home: const HomePage(),
    );
  }
}

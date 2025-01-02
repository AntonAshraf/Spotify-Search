import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/search_screen.dart';

Future<void> main() async {
    await dotenv.load(fileName: ".env");
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                    color: Colors.green,
                ),
                primarySwatch: Colors.green,
                visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: ArtistSearchScreen(),
        );
    }
}

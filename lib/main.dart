import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/list_student_page.dart';
import 'utils/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('fr')],
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const ListStudentPage(),
    );
  }
}

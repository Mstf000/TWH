import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:twh/presentation/viewmodel/auth_viewmodel.dart';

import 'app/theme.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/form_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // ✅ Initializes Firebase
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  runApp(const TWHApp());
}

class TWHApp extends StatelessWidget {
  const TWHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FormDataProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TWH Wellness',
            theme: appTheme,
            locale: Locale(localeProvider.locale),
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

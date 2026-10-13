import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_navigator.dart';
import 'widgets/truck_loader.dart';
import 'utils/constants.dart';
import 'network/session_manager.dart';
import 'screens/login_screen.dart';
import 'screens/login_webview_screen.dart';
import 'screens/lista_inventario_screen.dart';
import 'screens/quebra_screen.dart';
import 'screens/home_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Minha Loja | Operações',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        primaryColor: const Color(Constants.primaryRed),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(Constants.primaryRed),
          primary: const Color(Constants.primaryRed),
        ),
        scaffoldBackgroundColor: const Color(Constants.bgGray),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(Constants.primaryRed),
          foregroundColor: Colors.white,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        datePickerTheme:
            const DatePickerThemeData(backgroundColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashDecider(),
        '/login': (ctx) => const LoginScreen(),
        '/login_webview': (ctx) => const LoginWebViewScreen(),
        '/inventario': (ctx) => const ListaInventarioScreen(),
        '/quebra': (ctx) => const QuebraScreen(),
        '/home': (ctx) => const HomeHubScreen(),
      },
    );
  }
}

/// Decide a tela inicial com base na sessão.
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final session = await SessionManager.create();
    if (session.isLoggedIn()) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(Constants.primaryRed),
      body: Center(
        child: TruckLoader(),
      ),
    );
  }
}

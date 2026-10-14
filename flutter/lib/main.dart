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
import 'screens/quebras_menu_screen.dart';
import 'screens/precificacao_menu_screen.dart';
import 'screens/home_hub_screen.dart';
import 'precificacao/screens/etiquetas/etiquetas_screen.dart';
import 'precificacao/screens/papeletas/papeletas_diarias_screen.dart';
import 'recebimento/screens/home_screen.dart';
import 'recebimento/screens/detalhes_viagem_screen.dart';
import 'recebimento/screens/itens_screen.dart';
import 'recebimento/screens/fotos_recebimento_screen.dart';
import 'recebimento/screens/imagens_recebimento_screen.dart';
import 'recebimento/screens/profile_screen.dart';
import 'precificacao/core/session_manager.dart' as prec_session;
import 'precificacao/network/api_client.dart' as prec_api;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final precSession = await prec_session.SessionManager.getInstance();
  prec_api.ApiClient.instance.init(precSession);
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
        '/quebras': (ctx) => const QuebrasMenuScreen(),
        '/precificacao': (ctx) => const PrecificacaoMenuScreen(),
        '/precificacao_etiquetas': (ctx) => const EtiquetasScreen(),
        '/precificacao_papeletas': (ctx) => const PapeletasDiariasScreen(),
        '/recebimento': (ctx) => const HomeScreen(),
        '/detalhes': (ctx) => const DetalhesViagemScreen(),
        '/itens': (ctx) => const ItensScreen(),
        '/fotos': (ctx) => const FotosRecebimentoScreen(),
        '/imagens': (ctx) => const ImagensRecebimentoScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/quebra': (ctx) => const QuebraScreen(),
        '/quebra_consulta': (ctx) => const QuebraScreen(apenasConsulta: true),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/constants.dart';
import '../network/session_manager.dart';

/// Home com dois acessos: Inventário Rotativo e Quebras.
class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  String _nome = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final session = await SessionManager.create();
    if (!mounted) return;
    setState(() => _nome = session.getUserName() ?? '');
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Sair do aplicativo'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sim')),
        ],
      ),
    );
    if (sair == true && mounted) SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Minha Loja | Operações',
              style: TextStyle(
                  color: Color(Constants.invTextDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_nome.isNotEmpty) ...[
                Text('Olá, $_nome',
                    style: const TextStyle(
                        color: Color(Constants.invTextSecondary), fontSize: 14)),
                const SizedBox(height: 20),
              ],
              _badge(
                titulo: 'Inventário Rotativo',
                subtitulo: 'Contagem e ajuste de estoque',
                child: SvgPicture.asset(
                  'assets/drawables/ic_inventario.svg',
                  width: 48,
                  height: 48,
                  colorFilter: const ColorFilter.mode(
                      Color(Constants.primaryRed), BlendMode.srcIn),
                ),
                onTap: () => Navigator.of(context).pushNamed('/inventario'),
              ),
              const SizedBox(height: 20),
              _badge(
                titulo: 'Quebras',
                subtitulo: 'Registro de itens quebrados',
                child: const Icon(Icons.report_gmailerrorred_outlined,
                    size: 48, color: Color(Constants.primaryRed)),
                onTap: () => Navigator.of(context).pushNamed('/quebra'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required String titulo,
    required String subtitulo,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(Constants.borderColor)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 56, height: 56, child: Center(child: child)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          color: Color(Constants.invTextDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitulo,
                      style: const TextStyle(
                          color: Color(Constants.invTextSecondary),
                          fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Color(Constants.invTextSecondary)),
          ],
        ),
      ),
    );
  }
}
